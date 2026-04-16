param(
    [Parameter(Mandatory = $true)]
    [string]$SessionId,
    [Parameter(Mandatory = $true)]
    [string]$TaskSummary,
    [string]$BacklogItemId,
    [ValidateSet('product', 'dad-system-repair')]
    [string]$BacklogWorkstream = 'product',
    [ValidateSet('artifact', 'verified_decision', 'risk_disposition')]
    [string]$BacklogSessionWarrant = 'artifact',
    [ValidateSet('normal', 'remote-visible', 'config-runtime-sensitive', 'measurement-sensitive', 'destructive', 'provenance-compliance-sensitive')]
    [string]$BacklogRiskClass = 'normal',
    [string]$BacklogAcceptanceSignal,
    [ValidateSet('small', 'medium', 'large')]
    [string]$Scope = 'medium',
    [ValidateSet('autonomous', 'hybrid', 'supervised')]
    [string]$Mode = 'hybrid',
    [string]$Root = ".",
    [int]$MaxTurns = 0,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Set-ObjectField {
    param(
        [object]$Object,
        [string]$Name,
        $Value
    )

    if ($Object.PSObject.Properties.Match($Name).Count -gt 0) {
        $Object.$Name = $Value
    }
    else {
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    }
}

function Get-ArrayValue {
    param($Value)

    if ($null -eq $Value) {
        return @()
    }

    return @($Value)
}

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString('o')
}

function New-BacklogObject {
    return [ordered]@{
        schema_version = "dad-v2-backlog"
        policy = [ordered]@{
            max_now_items = 1
            allow_active_session_without_backlog_link = $false
        }
        items = @()
    }
}

function Load-Backlog {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return [PSCustomObject](New-BacklogObject)
    }

    return Get-Content -Path $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Save-Backlog {
    param(
        [string]$Path,
        [object]$Backlog
    )

    $json = $Backlog | ConvertTo-Json -Depth 30
    [System.IO.File]::WriteAllText($Path, $json, (New-Object System.Text.UTF8Encoding($true)))
}

function Get-NextBacklogId {
    param([object]$Backlog)

    $today = Get-Date -Format 'yyyy-MM-dd'
    $prefix = "BL-$today-"
    $max = 0

    foreach ($item in Get-ArrayValue $Backlog.items) {
        if ($item.id -match ('^' + [regex]::Escape($prefix) + '(\d{3})$')) {
            $max = [Math]::Max($max, [int]$Matches[1])
        }
    }

    return "{0}{1:D3}" -f $prefix, ($max + 1)
}

if ($MaxTurns -le 0) {
    switch ($Scope) {
        'small' { $MaxTurns = 2 }
        'medium' { $MaxTurns = 5 }
        'large' { $MaxTurns = 10 }
    }
}

$resolvedRoot = (Resolve-Path $Root).Path
$dialogueRoot = Join-Path $resolvedRoot "Document\dialogue"
$sessionsRoot = Join-Path $dialogueRoot "sessions"
$targetDir = Join-Path $sessionsRoot $SessionId
$statePath = Join-Path $dialogueRoot "state.json"
$sessionStatePath = Join-Path $targetDir "state.json"
$backlogPath = Join-Path $dialogueRoot "backlog.json"

if (Test-Path -LiteralPath $statePath) {
    $existingRootState = Get-Content -Path $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($existingRootState.session_status -eq "active" -and [string]$existingRootState.session_id -ne $SessionId) {
        throw "Active session '$($existingRootState.session_id)' must be closed or superseded before opening '$SessionId'."
    }
}

$backlog = Load-Backlog -Path $backlogPath
$backlogItems = Get-ArrayValue $backlog.items
$nowItems = @($backlogItems | Where-Object { $_.status -eq "now" })
$promotedItems = @($backlogItems | Where-Object { $_.status -eq "promoted" })
if ($promotedItems.Count -gt 0) {
    throw "Backlog already has a promoted item '$($promotedItems[0].id)'. Close or repair the active session linkage before creating a new session."
}

$timestamp = Get-Timestamp
$linkedItem = $null
if (-not [string]::IsNullOrWhiteSpace($BacklogItemId)) {
    $matches = @($backlogItems | Where-Object { $_.id -eq $BacklogItemId })
    if ($matches.Count -ne 1) {
        throw "Backlog item not found: $BacklogItemId"
    }

    $linkedItem = $matches[0]
    if ($linkedItem.status -in @('promoted', 'done', 'dropped', 'blocked')) {
        throw "Backlog item '$BacklogItemId' cannot be promoted from status '$($linkedItem.status)'."
    }
}
else {
    if ($nowItems.Count -gt 0) {
        throw ("A backlog 'now' item already exists ('{0}'). Pass -BacklogItemId to promote it instead of auto-bootstrapping another session candidate." -f $nowItems[0].id)
    }

    if ([string]::IsNullOrWhiteSpace($BacklogAcceptanceSignal)) {
        $BacklogAcceptanceSignal = "Session '$SessionId' closes with a concrete validated outcome recorded in its packets and summary."
    }

    $BacklogItemId = Get-NextBacklogId -Backlog $backlog
    $linkedItem = [PSCustomObject][ordered]@{
        id = $BacklogItemId
        title = $TaskSummary
        status = "next"
        workstream = $BacklogWorkstream
        desired_outcome = $TaskSummary
        session_warrant = $BacklogSessionWarrant
        acceptance_signal = $BacklogAcceptanceSignal
        risk_class = $BacklogRiskClass
        recommended_scope = $Scope
        introduced_by_session_id = $null
        active_session_id = $null
        closed_by_session_id = $null
        derived_from_ids = @()
        blocked_by = @()
        why_not_now = ""
        evidence_refs = @()
        session_history = @()
        notes = @()
        created_at = $timestamp
        updated_at = $timestamp
        last_reviewed_at = $timestamp
    }

    $backlog.items = @($backlogItems + $linkedItem)
}

if ((Test-Path $targetDir) -and -not $Force) {
    throw "Session directory already exists: $targetDir"
}

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

Set-ObjectField -Object $linkedItem -Name "status" -Value "promoted"
Set-ObjectField -Object $linkedItem -Name "active_session_id" -Value $SessionId
Set-ObjectField -Object $linkedItem -Name "updated_at" -Value $timestamp
Set-ObjectField -Object $linkedItem -Name "last_reviewed_at" -Value $timestamp
$history = Get-ArrayValue $linkedItem.session_history
$history += [PSCustomObject]@{
    session_id = $SessionId
    status = "active"
    started_at = $timestamp
    ended_at = $null
}
Set-ObjectField -Object $linkedItem -Name "session_history" -Value @($history)
Save-Backlog -Path $backlogPath -Backlog $backlog

$state = [ordered]@{
    protocol_version = "dad-v2"
    session_id = $SessionId
    session_status = "active"
    superseded_by = $null
    closed_reason = $null
    relay_mode = "user-bridged"
    mode = $Mode
    scope = $Scope
    current_turn = 0
    max_turns = $MaxTurns
    last_agent = $null
    task_summary = $TaskSummary
    origin_backlog_id = $BacklogItemId
    contract_status = "proposed"
    contract_checkpoints = [ordered]@{}
    packets = @()
    decisions = @()
    meta_improvements = @()
}

$json = $state | ConvertTo-Json -Depth 20
$enc = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($statePath, $json, $enc)
[System.IO.File]::WriteAllText($sessionStatePath, $json, $enc)

Write-Output "Created DAD session '$SessionId'."
Write-Output "Linked backlog item: $BacklogItemId"
Write-Output "Session dir: $targetDir"
Write-Output "State: $statePath"
