$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$promptScript = Join-Path $repoRoot "scripts\atcoder-prompt.ps1"
$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDir = Split-Path -Parent $profilePath

New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

$markerStart = "# >>> atcoder prompt >>>"
$markerEnd = "# <<< atcoder prompt <<<"
$importLine = ". `"$promptScript`""
$block = "$markerStart`r`n$importLine`r`n$markerEnd"

if (Test-Path -LiteralPath $profilePath) {
    $content = Get-Content -Raw -LiteralPath $profilePath
}
else {
    $content = ""
}

$pattern = "(?s)$([regex]::Escape($markerStart)).*?$([regex]::Escape($markerEnd))"
if ($content -match $pattern) {
    $content = [regex]::Replace($content, $pattern, $block)
}
elseif ($content.Trim()) {
    $content = $content.TrimEnd() + "`r`n`r`n" + $block
}
else {
    $content = $block
}

Set-Content -Encoding UTF8 -LiteralPath $profilePath -Value $content
. $promptScript

Write-Host "installed AtCoder prompt:" $profilePath
Write-Host "current contest is shown under:" $repoRoot
