### ------------------------
### Update version.json
### ------------------------

# Fetch the latest tags from the remote repository
git fetch --tags

# Get the most recent git tag for the current branch
$gitTag = git describe --tags --abbrev=0

Set-Location -Path "$PSScriptRoot"
$commitHash = & git rev-parse --short HEAD

# Get the build host
if ($IsWindows) {
    $computerName = $env:COMPUTERNAME
    $currentUser = $env:USERNAME
} elseif ($IsLinux) {
    $computerName = (hostname)
    $currentUser = whoami
} else {
    throw "Unsupported OS"
}

$midnight = (Get-Date).Date
$now = Get-Date
$minutesSinceMidnight = ($now - $midnight).TotalMinutes
$buildTick = [math]::Round($minutesSinceMidnight)

# Get the current date and time, including timezone
$buildDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"

# Get the current date in YYYYMMDD format
$date = Get-Date -Format "yyyyMMdd"

# Combine date and number of commits to form a unique build number
$buildNumber = "$date.$buildTick"

# Print the build number
Write-Output "Build Number: $buildNumber"

# Get the current git branch
$gitBranch = git rev-parse --abbrev-ref HEAD
# Get the current git HEAD
$gitHead = git rev-parse HEAD

$json = @{
    "BuildNumber" = $BuildNumber
    "BuildDate"   = $buildDate
    "BuildHost"   = $computerName
    "CommitHash"  = $commitHash
    "CurrentUser" = $currentUser
    "GitBranch"   = $gitBranch
    "GitHead"     = $gitHead
    "GitTag"      = $gitTag
} | ConvertTo-Json

Set-Content -Path "$PSScriptRoot\src\Api\wwwroot\version.json" -Value $json