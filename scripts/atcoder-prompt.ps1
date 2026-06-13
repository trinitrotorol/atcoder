$script:AtCoderRepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$script:AtCoderCurrentFile = Join-Path $script:AtCoderRepoRoot ".atcoder-current"
$script:AtCoderDebugFile = Join-Path $script:AtCoderRepoRoot ".atcoder-debug"

function Test-AtCoderRepoLocation {
    $location = (Get-Location).Path
    $root = $script:AtCoderRepoRoot

    if ($location -ne $root -and -not $location.StartsWith($root + [IO.Path]::DirectorySeparatorChar)) {
        return $false
    }

    return $true
}

function Get-AtCoderPromptContest {
    if (-not (Test-AtCoderRepoLocation)) {
        return $null
    }

    if (Test-Path -LiteralPath $script:AtCoderCurrentFile) {
        $contest = (Get-Content -Raw -LiteralPath $script:AtCoderCurrentFile).Trim()
        if ($contest) {
            return $contest
        }
    }

    $contestsDir = Join-Path $root "contests"
    if (-not (Test-Path -LiteralPath $contestsDir)) {
        return $null
    }

    $latest = Get-ChildItem -LiteralPath $contestsDir -Directory |
        Sort-Object Name |
        Select-Object -Last 1

    if ($latest) {
        return $latest.Name
    }

    return $null
}

function Test-AtCoderPromptDebug {
    if (-not (Test-AtCoderRepoLocation)) {
        return $false
    }

    return Test-Path -LiteralPath $script:AtCoderDebugFile
}

function Test-AtCoderPromptColor {
    try {
        return [bool]$Host.UI.SupportsVirtualTerminal
    }
    catch {
        return $false
    }
}

function global:prompt {
    $path = (Get-Location).Path
    $contest = Get-AtCoderPromptContest
    $debug = Test-AtCoderPromptDebug
    $level = ">" * ($nestedPromptLevel + 1)

    if (Test-AtCoderPromptColor) {
        $esc = [char]27
        $cyan = "$esc[36m"
        $yellow = "$esc[33m"
        $reset = "$esc[0m"
        $segments = ""
        if ($contest) {
            $segments += "$cyan [$contest]$reset"
        }
        if ($debug) {
            $segments += "$yellow [DEBUG]$reset"
        }

        return "PS $path$segments$level "
    }

    $segments = ""
    if ($contest) {
        $segments += " [$contest]"
    }
    if ($debug) {
        $segments += " [DEBUG]"
    }

    return "PS $path$segments$level "
}
