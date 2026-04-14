param(
    [string]$Root = ".",
    [Parameter(Mandatory = $true)]
    [string]$Namespace,
    [switch]$AllowTemplateNamespace
)

$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

if ($Namespace -notmatch '^[a-z0-9][a-z0-9-]*$') {
    throw "Namespace must match ^[a-z0-9][a-z0-9-]*$."
}

if ($Namespace.EndsWith('-')) {
    throw "Namespace must not end with '-'."
}

if ($Namespace -eq 'dadtpl' -and -not $AllowTemplateNamespace) {
    throw "The template namespace 'dadtpl' is reserved for the template source. Pick a project-specific prefix such as 'acg'."
}

$repoRoot = (Resolve-Path -LiteralPath $Root).Path
$skillsRoot = Join-Path $repoRoot ".agents\skills"
if (-not (Test-Path -LiteralPath $skillsRoot)) {
    throw "Skills source directory not found: $skillsRoot"
}

$coreSkillSuffixes = @(
    'dialogue-start',
    'repeat-workflow',
    'repeat-workflow-auto'
)

function Get-CoreSkillDirectory([string]$Suffix) {
    $candidates = @(Get-ChildItem -Path $skillsRoot -Directory | Where-Object {
            $_.Name -eq $Suffix -or $_.Name -match ("^[a-z0-9][a-z0-9-]*-" + [regex]::Escape($Suffix) + "$")
        })

    if ($candidates.Count -ne 1) {
        throw "Expected exactly one skill directory for suffix '$Suffix', found $($candidates.Count)."
    }

    return $candidates[0]
}

$nameMap = [ordered]@{}
foreach ($suffix in $coreSkillSuffixes) {
    $currentDir = Get-CoreSkillDirectory -Suffix $suffix
    $nameMap[$currentDir.Name] = "$Namespace-$suffix"
}

$textFiles = @(Get-ChildItem -Path $repoRoot -Recurse -File -Include *.md,*.yaml,*.yml,*.txt,*.ps1,*.sh)
$orderedKeys = @($nameMap.Keys | Sort-Object Length -Descending)

function Test-HasBom([byte[]]$Bytes) {
    return $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF
}

function Test-RequiresNoBom([string]$Path) {
    $normalized = [System.IO.Path]::GetFullPath($Path).Replace('/', '\')
    return $normalized -match '\\\.agents\\skills\\[^\\]+\\SKILL\.md$' -or
        $normalized -match '\\\.agents\\skills\\[^\\]+\\agents\\openai\.ya?ml$'
}

foreach ($file in $textFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $updated = $text

    foreach ($oldName in $orderedKeys) {
        $newName = $nameMap[$oldName]
        $updated = $updated.Replace("`$$oldName", "`$$newName")
        $updated = $updated.Replace("name: $oldName", "name: $newName")
        $updated = $updated.Replace("/$oldName", "/$newName")
        $updated = $updated.Replace("`/$oldName", "`/$newName")
        $updated = $updated.Replace("# /$oldName", "# /$newName")
    }

    if ($updated -cne $text) {
        $targetEncoding = if (Test-RequiresNoBom -Path $file.FullName) {
            $utf8NoBom
        }
        elseif (Test-HasBom -Bytes $bytes) {
            $utf8Bom
        }
        else {
            $utf8NoBom
        }

        [System.IO.File]::WriteAllText($file.FullName, $updated, $targetEncoding)
    }
}

foreach ($oldName in $orderedKeys) {
    $newName = $nameMap[$oldName]
    if ($oldName -eq $newName) {
        continue
    }

    $oldPath = Join-Path $skillsRoot $oldName
    $newPath = Join-Path $skillsRoot $newName
    if (Test-Path -LiteralPath $newPath) {
        throw "Target skill directory already exists: $newPath"
    }

    Move-Item -LiteralPath $oldPath -Destination $newPath
}

Write-Output "Applied Codex skill namespace '$Namespace' to core DAD skills."
foreach ($oldName in $orderedKeys) {
    Write-Output "- $oldName -> $($nameMap[$oldName])"
}
