param(
    [ValidateSet('list', 'add', 'set-status', 'resolve', 'block', 'drop')]
    [string]$Action = 'list',
    [string]$Id,
    [string]$Title,
    [string]$DesiredOutcome,
    [ValidateSet('product', 'dad-system-repair')]
    [string]$Workstream = 'product',
    [ValidateSet('artifact', 'verified_decision', 'risk_disposition')]
    [string]$SessionWarrant = 'artifact',
    [string]$AcceptanceSignal,
    [ValidateSet('normal', 'remote-visible', 'config-runtime-sensitive', 'measurement-sensitive', 'destructive', 'provenance-compliance-sensitive')]
    [string]$RiskClass = 'normal',
    [ValidateSet('small', 'medium', 'large')]
    [string]$RecommendedScope = 'medium',
    [ValidateSet('now', 'next', 'later')]
    [string]$Status = 'next',
    [string[]]$BlockedBy,
    [string]$WhyNotNow,
    [string[]]$EvidenceRefs,
    [string[]]$DerivedFromIds,
    [string]$SessionId,
    [string]$Root = ".",
    [switch]$Json
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

function Get-BacklogItem {
    param(
        [object]$Backlog,
        [string]$ItemId
    )

    return @(Get-ArrayValue $Backlog.items | Where-Object { $_.id -eq $ItemId })
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

function Complete-SessionHistory {
    param(
        [object]$Item,
        [string]$TargetSessionId,
        [string]$StatusValue
    )

    if ([string]::IsNullOrWhiteSpace($TargetSessionId)) {
        return
    }

    $history = Get-ArrayValue $Item.session_history
    $updated = $false
    foreach ($entry in $history) {
        if ($entry.session_id -eq $TargetSessionId -and [string]::IsNullOrWhiteSpace([string]$entry.ended_at)) {
            Set-ObjectField -Object $entry -Name "status" -Value $StatusValue
            Set-ObjectField -Object $entry -Name "ended_at" -Value (Get-Timestamp)
            $updated = $true
        }
    }

    if (-not $updated) {
        $history += [PSCustomObject]@{
            session_id = $TargetSessionId
            status = $StatusValue
            started_at = $null
            ended_at = Get-Timestamp
        }
    }

    Set-ObjectField -Object $Item -Name "session_history" -Value @($history)
}

$resolvedRoot = (Resolve-Path $Root).Path
$dialogueRoot = Join-Path $resolvedRoot "Document\dialogue"
$backlogPath = Join-Path $dialogueRoot "backlog.json"
$statePath = Join-Path $dialogueRoot "state.json"

if (-not (Test-Path -LiteralPath $dialogueRoot)) {
    throw "Document/dialogue not found: $dialogueRoot"
}

$backlog = Load-Backlog -Path $backlogPath
$items = Get-ArrayValue $backlog.items
$rootState = $null
if (Test-Path -LiteralPath $statePath) {
    $rootState = Get-Content -Path $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
}
$activeSessionExists = $null -ne $rootState -and $rootState.session_status -eq "active" -and -not [string]::IsNullOrWhiteSpace([string]$rootState.session_id)

switch ($Action) {
    'list' {
        if ($Json) {
            Write-Output ($backlog | ConvertTo-Json -Depth 30)
            break
        }

        if ($items.Count -eq 0) {
            Write-Output "Backlog is empty."
            break
        }

        foreach ($item in $items | Sort-Object status, id) {
            Write-Output ("[{0}] {1} {2}" -f $item.status.ToUpperInvariant(), $item.id, $item.title)
        }
        break
    }

    'add' {
        if ([string]::IsNullOrWhiteSpace($Title) -or [string]::IsNullOrWhiteSpace($DesiredOutcome) -or [string]::IsNullOrWhiteSpace($AcceptanceSignal)) {
            throw "Action 'add' requires -Title, -DesiredOutcome, and -AcceptanceSignal."
        }
        if ($activeSessionExists -and $Status -eq 'now') {
            throw "Cannot create a separate backlog 'now' item while an active session exists."
        }
        if (($items | Where-Object { $_.status -eq 'now' }).Count -gt 0 -and $Status -eq 'now') {
            throw "A backlog 'now' item already exists. Resolve or reprioritize it first."
        }

        if ([string]::IsNullOrWhiteSpace($Id)) {
            $Id = Get-NextBacklogId -Backlog $backlog
        }
        elseif (($items | Where-Object { $_.id -eq $Id }).Count -gt 0) {
            throw "Backlog item already exists: $Id"
        }

        $timestamp = Get-Timestamp
        $newItem = [ordered]@{
            id = $Id
            title = $Title
            status = $Status
            workstream = $Workstream
            desired_outcome = $DesiredOutcome
            session_warrant = $SessionWarrant
            acceptance_signal = $AcceptanceSignal
            risk_class = $RiskClass
            recommended_scope = $RecommendedScope
            introduced_by_session_id = $null
            active_session_id = $null
            closed_by_session_id = $null
            derived_from_ids = @(Get-ArrayValue $DerivedFromIds)
            blocked_by = @()
            why_not_now = ""
            evidence_refs = @(Get-ArrayValue $EvidenceRefs)
            session_history = @()
            notes = @()
            created_at = $timestamp
            updated_at = $timestamp
            last_reviewed_at = $timestamp
        }

        if ($Status -eq 'later' -and -not [string]::IsNullOrWhiteSpace($WhyNotNow)) {
            $newItem.why_not_now = $WhyNotNow
        }

        $backlog.items = @($items + [PSCustomObject]$newItem)
        Save-Backlog -Path $backlogPath -Backlog $backlog
        Write-Output "Added backlog item '$Id'."
        break
    }

    'set-status' {
        if ([string]::IsNullOrWhiteSpace($Id)) {
            throw "Action 'set-status' requires -Id."
        }

        $item = @(Get-BacklogItem -Backlog $backlog -ItemId $Id)
        if ($item.Count -ne 1) {
            throw "Backlog item not found: $Id"
        }
        $item = $item[0]

        if ($item.status -in @('promoted', 'done', 'dropped')) {
            throw "Cannot change status with 'set-status' from '$($item.status)'. Use a session closeout or a dedicated resolution action."
        }
        if ($activeSessionExists -and $Status -eq 'now') {
            throw "Cannot set a backlog item to 'now' while an active session exists."
        }
        $otherNowItems = @($items | Where-Object { $_.status -eq 'now' -and $_.id -ne $Id })
        if ($Status -eq 'now' -and $otherNowItems.Count -gt 0) {
            throw "A different backlog 'now' item already exists: $($otherNowItems[0].id)"
        }

        Set-ObjectField -Object $item -Name "status" -Value $Status
        if ($Status -ne 'blocked') {
            Set-ObjectField -Object $item -Name "blocked_by" -Value @()
        }
        if ($Status -in @('now', 'next')) {
            Set-ObjectField -Object $item -Name "why_not_now" -Value ""
        }
        elseif ($Status -eq 'later' -and -not [string]::IsNullOrWhiteSpace($WhyNotNow)) {
            Set-ObjectField -Object $item -Name "why_not_now" -Value $WhyNotNow
        }

        Set-ObjectField -Object $item -Name "updated_at" -Value (Get-Timestamp)
        Set-ObjectField -Object $item -Name "last_reviewed_at" -Value (Get-Timestamp)
        Save-Backlog -Path $backlogPath -Backlog $backlog
        Write-Output "Updated backlog item '$Id' to status '$Status'."
        break
    }

    'resolve' {
        if ([string]::IsNullOrWhiteSpace($Id) -or [string]::IsNullOrWhiteSpace($SessionId)) {
            throw "Action 'resolve' requires -Id and -SessionId."
        }

        $item = @(Get-BacklogItem -Backlog $backlog -ItemId $Id)
        if ($item.Count -ne 1) {
            throw "Backlog item not found: $Id"
        }
        $item = $item[0]

        Set-ObjectField -Object $item -Name "status" -Value "done"
        Set-ObjectField -Object $item -Name "active_session_id" -Value $null
        Set-ObjectField -Object $item -Name "closed_by_session_id" -Value $SessionId
        Set-ObjectField -Object $item -Name "blocked_by" -Value @()
        Set-ObjectField -Object $item -Name "why_not_now" -Value ""
        Set-ObjectField -Object $item -Name "updated_at" -Value (Get-Timestamp)
        Set-ObjectField -Object $item -Name "last_reviewed_at" -Value (Get-Timestamp)
        Complete-SessionHistory -Item $item -TargetSessionId $SessionId -StatusValue "done"
        Save-Backlog -Path $backlogPath -Backlog $backlog
        Write-Output "Resolved backlog item '$Id' as done."
        break
    }

    'block' {
        if ([string]::IsNullOrWhiteSpace($Id) -or [string]::IsNullOrWhiteSpace($WhyNotNow) -or (Get-ArrayValue $BlockedBy).Count -eq 0) {
            throw "Action 'block' requires -Id, -WhyNotNow, and at least one -BlockedBy value."
        }

        $item = @(Get-BacklogItem -Backlog $backlog -ItemId $Id)
        if ($item.Count -ne 1) {
            throw "Backlog item not found: $Id"
        }
        $item = $item[0]

        Set-ObjectField -Object $item -Name "status" -Value "blocked"
        Set-ObjectField -Object $item -Name "active_session_id" -Value $null
        Set-ObjectField -Object $item -Name "blocked_by" -Value @(Get-ArrayValue $BlockedBy)
        Set-ObjectField -Object $item -Name "why_not_now" -Value $WhyNotNow
        Set-ObjectField -Object $item -Name "updated_at" -Value (Get-Timestamp)
        Set-ObjectField -Object $item -Name "last_reviewed_at" -Value (Get-Timestamp)
        if (-not [string]::IsNullOrWhiteSpace($SessionId)) {
            Complete-SessionHistory -Item $item -TargetSessionId $SessionId -StatusValue "blocked"
        }
        Save-Backlog -Path $backlogPath -Backlog $backlog
        Write-Output "Blocked backlog item '$Id'."
        break
    }

    'drop' {
        if ([string]::IsNullOrWhiteSpace($Id)) {
            throw "Action 'drop' requires -Id."
        }

        $item = @(Get-BacklogItem -Backlog $backlog -ItemId $Id)
        if ($item.Count -ne 1) {
            throw "Backlog item not found: $Id"
        }
        $item = $item[0]

        Set-ObjectField -Object $item -Name "status" -Value "dropped"
        Set-ObjectField -Object $item -Name "active_session_id" -Value $null
        if (-not [string]::IsNullOrWhiteSpace($SessionId)) {
            Set-ObjectField -Object $item -Name "closed_by_session_id" -Value $SessionId
            Complete-SessionHistory -Item $item -TargetSessionId $SessionId -StatusValue "dropped"
        }
        Set-ObjectField -Object $item -Name "updated_at" -Value (Get-Timestamp)
        Set-ObjectField -Object $item -Name "last_reviewed_at" -Value (Get-Timestamp)
        Save-Backlog -Path $backlogPath -Backlog $backlog
        Write-Output "Dropped backlog item '$Id'."
        break
    }
}
