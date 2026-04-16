param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path -LiteralPath $Root).Path
$skillsRoot = Join-Path $repoRoot ".agents\skills"

if (-not (Test-Path -LiteralPath $skillsRoot)) {
    Write-Output "Codex skill metadata validation failed:"
    Write-Output "- Missing .agents/skills under repo root: $repoRoot"
    exit 1
}

$issues = New-Object System.Collections.Generic.List[string]
$skillDirs = @(Get-ChildItem -Path $skillsRoot -Directory | Sort-Object Name)
$coreSkillSuffixes = @(
    'dialogue-start',
    'repeat-workflow',
    'repeat-workflow-auto'
)
$coreNamespacePrefixes = New-Object System.Collections.Generic.List[string]

function Test-HasBom([byte[]]$Bytes) {
    return $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF
}

foreach ($skillDir in $skillDirs) {
    $skillName = $skillDir.Name
    $skillDoc = Join-Path $skillDir.FullName "SKILL.md"
    $metadataPath = Join-Path $skillDir.FullName "agents\openai.yaml"

    if (-not (Test-Path -LiteralPath $skillDoc)) {
        $issues.Add("Missing SKILL.md for skill '$skillName'.") | Out-Null
        continue
    }

    if (-not (Test-Path -LiteralPath $metadataPath)) {
        $issues.Add("Missing agents/openai.yaml for skill '$skillName'.") | Out-Null
        continue
    }

    $skillDocBytes = [System.IO.File]::ReadAllBytes($skillDoc)
    if (Test-HasBom -Bytes $skillDocBytes) {
        $issues.Add("$skillDoc must be UTF-8 without BOM so Codex Desktop sees YAML frontmatter at byte 0.") | Out-Null
    }

    $skillDocText = Get-Content -Path $skillDoc -Raw -Encoding UTF8
    if (-not $skillDocText.StartsWith("---")) {
        $issues.Add("$skillDoc must start with frontmatter delimiter '---' at byte 0.") | Out-Null
    }

    if ($skillDocText.Contains([char]0xFFFD)) {
        $issues.Add("$skillDoc contains replacement characters.") | Out-Null
    }

    if ($skillDocText -match '[^\u0009\u000A\u000D\u0020-\u007E]') {
        $issues.Add("$skillDoc contains non-ASCII text. Keep Codex SKILL.md runtime files ASCII-safe because they must remain UTF-8 without BOM.") | Out-Null
    }

    $nameMatch = [regex]::Match($skillDocText, '(?m)^name:\s*([a-z0-9][a-z0-9-]*)\s*$')
    if (-not $nameMatch.Success) {
        $issues.Add("$skillDoc is missing a frontmatter name field.") | Out-Null
    }
    elseif ($nameMatch.Groups[1].Value -ne $skillName) {
        $issues.Add("$skillDoc frontmatter name must match folder name '$skillName'.") | Out-Null
    }

    foreach ($suffix in $coreSkillSuffixes) {
        if ($skillName -eq $suffix) {
            $issues.Add("Core DAD skill '$skillName' must be namespaced. Use Set-CodexSkillNamespace.ps1 before registration.") | Out-Null
            continue
        }

        if ($skillName -match ('^([a-z0-9][a-z0-9-]*)-' + [regex]::Escape($suffix) + '$')) {
            $coreNamespacePrefixes.Add($matches[1]) | Out-Null
        }
    }

    $metadataBytes = [System.IO.File]::ReadAllBytes($metadataPath)
    if (Test-HasBom -Bytes $metadataBytes) {
        $issues.Add("$metadataPath must be UTF-8 without BOM for Codex/Desktop metadata loading.") | Out-Null
    }

    $text = Get-Content -Path $metadataPath -Raw -Encoding UTF8
    if ($text.Contains([char]0xFFFD)) {
        $issues.Add("$metadataPath contains replacement characters.") | Out-Null
    }

    if ([regex]::Matches($text, '(?m)^---\s*$').Count -gt 0) {
        $issues.Add("$metadataPath must stay a single YAML document without document separators.") | Out-Null
    }

    if ($text -match '[^\u0009\u000A\u000D\u0020-\u007E]') {
        $issues.Add("$metadataPath contains non-ASCII metadata text. Keep Codex skill metadata ASCII-safe.") | Out-Null
    }

    if (-not [regex]::IsMatch($text, 'display_name:\s*".+"')) {
        $issues.Add("$metadataPath is missing interface.display_name.") | Out-Null
    }

    if (-not [regex]::IsMatch($text, 'short_description:\s*".+"')) {
        $issues.Add("$metadataPath is missing interface.short_description.") | Out-Null
    }

    if (-not [regex]::IsMatch($text, 'default_prompt:\s*".*\$' + [regex]::Escape($skillName) + '.*"')) {
        $issues.Add("$metadataPath default_prompt must reference `$${skillName}.") | Out-Null
    }

    if (-not [regex]::IsMatch($text, 'allow_implicit_invocation:\s*false')) {
        $issues.Add("$metadataPath must set allow_implicit_invocation: false.") | Out-Null
    }
}

$uniqueCorePrefixes = @($coreNamespacePrefixes | Select-Object -Unique)
if ($uniqueCorePrefixes.Count -gt 1) {
    $issues.Add("Core DAD skills must share one namespace prefix. Found: $($uniqueCorePrefixes -join ', ').") | Out-Null
}

foreach ($suffix in $coreSkillSuffixes) {
    $matchingCoreSkills = @($skillDirs | Where-Object { $_.Name -match ('^[a-z0-9][a-z0-9-]*-' + [regex]::Escape($suffix) + '$') })
    if ($matchingCoreSkills.Count -ne 1) {
        $issues.Add("Expected exactly one namespaced core DAD skill for suffix '$suffix', found $($matchingCoreSkills.Count).") | Out-Null
    }
}

if ($issues.Count -gt 0) {
    Write-Output "Codex skill metadata validation failed:"
    foreach ($issue in $issues) {
        Write-Output "- $issue"
    }
    exit 1
}

Write-Output "Codex skill metadata validation passed for $($skillDirs.Count) skills."
