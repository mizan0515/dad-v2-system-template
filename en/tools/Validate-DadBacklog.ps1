param(
    [string]$Root = "."
)

$ErrorActionPreference = "Stop"

function Add-Issue {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$Message
    )

    $List.Add($Message) | Out-Null
}

function Add-Warning {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$Message
    )

    $List.Add($Message) | Out-Null
}

function Get-ArrayValue {
    param($Value)

    if ($null -eq $Value) {
        return @()
    }

    return @($Value)
}

$resolvedRoot = (Resolve-Path $Root).Path
$dialogueRoot = Join-Path $resolvedRoot "Document\dialogue"
$backlogPath = Join-Path $dialogueRoot "backlog.json"
$rootStatePath = Join-Path $dialogueRoot "state.json"
$sessionsRoot = Join-Path $dialogueRoot "sessions"

$issues = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $backlogPath)) {
    if (-not (Test-Path -LiteralPath $rootStatePath)) {
        Write-Output "No backlog or live DAD session state found under Document/dialogue. Backlog validation skipped."
        return
    }

    Add-Issue -List $issues -Message "backlog.json not found: $backlogPath"
}
else {
    $backlog = Get-Content -Path $backlogPath -Raw -Encoding UTF8 | ConvertFrom-Json

    if ($backlog.schema_version -ne "dad-v2-backlog") {
        Add-Issue -List $issues -Message "backlog.json schema_version must be 'dad-v2-backlog'."
    }

    $policy = $backlog.policy
    $maxNowItems = if ($policy.max_now_items) { [int]$policy.max_now_items } else { 1 }
    if ($maxNowItems -lt 1) {
        Add-Issue -List $issues -Message "backlog.json policy.max_now_items must be >= 1."
    }

    $items = Get-ArrayValue $backlog.items
    $ids = New-Object System.Collections.Generic.HashSet[string]
    $allowedStatuses = @("now", "next", "later", "blocked", "promoted", "done", "dropped")
    $allowedWorkstreams = @("product", "dad-system-repair")
    $allowedWarrants = @("artifact", "verified_decision", "risk_disposition")
    $allowedScopes = @("small", "medium", "large")
    $allowedRiskClasses = @("normal", "remote-visible", "config-runtime-sensitive", "measurement-sensitive", "destructive", "provenance-compliance-sensitive")

    foreach ($item in $items) {
        if ([string]::IsNullOrWhiteSpace([string]$item.id)) {
            Add-Issue -List $issues -Message "Every backlog item must have a non-empty id."
            continue
        }
        if (-not $ids.Add([string]$item.id)) {
            Add-Issue -List $issues -Message "Duplicate backlog item id '$($item.id)'."
        }
        if ($allowedStatuses -notcontains [string]$item.status) {
            Add-Issue -List $issues -Message "Backlog item '$($item.id)' has invalid status '$($item.status)'."
        }
        if ($allowedWorkstreams -notcontains [string]$item.workstream) {
            Add-Issue -List $issues -Message "Backlog item '$($item.id)' has invalid workstream '$($item.workstream)'."
        }
        if ($allowedWarrants -notcontains [string]$item.session_warrant) {
            Add-Issue -List $issues -Message "Backlog item '$($item.id)' has invalid session_warrant '$($item.session_warrant)'."
        }
        if ($allowedScopes -notcontains [string]$item.recommended_scope) {
            Add-Issue -List $issues -Message "Backlog item '$($item.id)' has invalid recommended_scope '$($item.recommended_scope)'."
        }
        if ($allowedRiskClasses -notcontains [string]$item.risk_class) {
            Add-Issue -List $issues -Message "Backlog item '$($item.id)' has invalid risk_class '$($item.risk_class)'."
        }

        if ([string]::IsNullOrWhiteSpace([string]$item.title) -or [string]::IsNullOrWhiteSpace([string]$item.desired_outcome) -or [string]::IsNullOrWhiteSpace([string]$item.acceptance_signal)) {
            Add-Issue -List $issues -Message "Backlog item '$($item.id)' must keep title, desired_outcome, and acceptance_signal non-empty."
        }

        $blockedBy = Get-ArrayValue $item.blocked_by
        if ($item.status -eq "blocked") {
            if ($blockedBy.Count -eq 0) {
                Add-Issue -List $issues -Message "Blocked backlog item '$($item.id)' must include blocked_by."
            }
            if ([string]::IsNullOrWhiteSpace([string]$item.why_not_now)) {
                Add-Issue -List $issues -Message "Blocked backlog item '$($item.id)' must include why_not_now."
            }
        }

        if ($item.status -eq "done" -and [string]::IsNullOrWhiteSpace([string]$item.closed_by_session_id)) {
            Add-Issue -List $issues -Message "Done backlog item '$($item.id)' must include closed_by_session_id."
        }

        if ($item.status -eq "promoted" -and [string]::IsNullOrWhiteSpace([string]$item.active_session_id)) {
            Add-Issue -List $issues -Message "Promoted backlog item '$($item.id)' must include active_session_id."
        }

        if ($item.status -ne "promoted" -and -not [string]::IsNullOrWhiteSpace([string]$item.active_session_id)) {
            Add-Issue -List $issues -Message "Only promoted backlog items may keep active_session_id. Item '$($item.id)' is '$($item.status)'."
        }

        if ($item.status -eq "done" -and -not [string]::IsNullOrWhiteSpace([string]$item.closed_by_session_id)) {
            $closedStatePath = Join-Path $sessionsRoot ([string]$item.closed_by_session_id)
            $closedStatePath = Join-Path $closedStatePath "state.json"
            if (-not (Test-Path -LiteralPath $closedStatePath)) {
                Add-Issue -List $issues -Message "Done backlog item '$($item.id)' points to missing session state '$closedStatePath'."
            }
        }

        if ($item.workstream -eq "product") {
            $metaText = ("{0}`n{1}" -f [string]$item.title, [string]$item.desired_outcome).ToLowerInvariant()
            if ($metaText -match 'wording|summary/state sync|state/summary sync|closure seal|validator-noise|sync only|seal only') {
                Add-Issue -List $issues -Message "Product backlog item '$($item.id)' reads like meta-only ceremony. Keep wording/sync/seal cleanup out of product backlog."
            }
        }

        $outcomeText = [string]$item.desired_outcome
        if ($outcomeText.Length -lt 20 -or $outcomeText -match '^\s*(review|sync|cleanup|finalize|verify)\b') {
            Add-Warning -List $warnings -Message "Backlog item '$($item.id)' has an abstract desired_outcome. Prefer a concrete outcome statement."
        }

        $acceptanceText = [string]$item.acceptance_signal
        if ($acceptanceText.Length -lt 20 -or $acceptanceText -match '^\s*(done|completed|finished)\s*$') {
            Add-Warning -List $warnings -Message "Backlog item '$($item.id)' has a weak acceptance_signal. Prefer an observable completion signal."
        }
    }

    $rootState = $null
    if (Test-Path -LiteralPath $rootStatePath) {
        $rootState = Get-Content -Path $rootStatePath -Raw -Encoding UTF8 | ConvertFrom-Json
    }

    $nowItems = @($items | Where-Object { $_.status -eq "now" })
    $promotedItems = @($items | Where-Object { $_.status -eq "promoted" })
    $activeSessionExists = $null -ne $rootState -and $rootState.session_status -eq "active" -and -not [string]::IsNullOrWhiteSpace([string]$rootState.session_id)

    if ($activeSessionExists) {
        if ([string]::IsNullOrWhiteSpace([string]$rootState.origin_backlog_id)) {
            Add-Issue -List $issues -Message "Active root state must include origin_backlog_id."
        }
        if ($promotedItems.Count -ne 1) {
            Add-Issue -List $issues -Message "Exactly one promoted backlog item must exist while an active session is open."
        }
        if ($nowItems.Count -gt 0) {
            Add-Issue -List $issues -Message "No separate backlog 'now' item is allowed while an active session exists."
        }
        if ($promotedItems.Count -eq 1) {
            $activeItem = $promotedItems[0]
            if ($activeItem.id -ne $rootState.origin_backlog_id) {
                Add-Issue -List $issues -Message "Active root state origin_backlog_id '$($rootState.origin_backlog_id)' does not match promoted backlog item '$($activeItem.id)'."
            }
            if ($activeItem.active_session_id -ne $rootState.session_id) {
                Add-Issue -List $issues -Message "Promoted backlog item '$($activeItem.id)' must point to active session '$($rootState.session_id)'."
            }
        }

        $sessionStatePath = Join-Path $sessionsRoot ([string]$rootState.session_id)
        $sessionStatePath = Join-Path $sessionStatePath "state.json"
        if (-not (Test-Path -LiteralPath $sessionStatePath)) {
            Add-Issue -List $issues -Message "Active session state not found: $sessionStatePath"
        }
        else {
            $sessionState = Get-Content -Path $sessionStatePath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ([string]$sessionState.origin_backlog_id -ne [string]$rootState.origin_backlog_id) {
                Add-Issue -List $issues -Message "Active session state origin_backlog_id does not match root state."
            }
        }
    }
    else {
        if ($promotedItems.Count -gt 0) {
            Add-Issue -List $issues -Message "Promoted backlog items are not allowed without an active session."
        }
        if ($nowItems.Count -gt $maxNowItems) {
            Add-Issue -List $issues -Message "Backlog contains $($nowItems.Count) 'now' items, exceeding policy.max_now_items=$maxNowItems."
        }
    }

    $nextItems = @($items | Where-Object { $_.status -eq "next" })
    $laterItems = @($items | Where-Object { $_.status -eq "later" })
    if ($nextItems.Count -gt 3) {
        Add-Warning -List $warnings -Message "Backlog has more than 3 'next' items. Keep the near-term queue short."
    }
    if ($laterItems.Count -gt 7) {
        Add-Warning -List $warnings -Message "Backlog has more than 7 'later' items. Trim low-value candidates before backlog drift grows."
    }
}

if ($issues.Count -gt 0) {
    Write-Output "DAD backlog validation failed:"
    foreach ($issue in $issues) {
        Write-Output "- $issue"
    }
    exit 1
}

if ($warnings.Count -gt 0) {
    Write-Output "DAD backlog validation warnings:"
    foreach ($warning in $warnings) {
        Write-Output "- $warning"
    }
}

Write-Output "DAD backlog validation passed."
