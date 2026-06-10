$ErrorActionPreference = "Stop"

$Distro = $env:ATCODER_WSL_DISTRO
if (-not $Distro) {
    $Distro = "Ubuntu"
}

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ($Root -match '^([A-Za-z]):\\(.*)$') {
    $Drive = $Matches[1].ToLowerInvariant()
    $Rest = $Matches[2].Replace('\', '/')
    $WslRoot = "/mnt/$Drive/$Rest"
} else {
    $WslRoot = (& wsl -d $Distro -- wslpath -a "$Root").Trim()
}
$EscapedWslRoot = $WslRoot.Replace("'", "'\''")

& wsl -d $Distro -- bash -lc "cd '$EscapedWslRoot' && chmod +x scripts/*.sh && ./scripts/setup-linux.sh"
exit $LASTEXITCODE
