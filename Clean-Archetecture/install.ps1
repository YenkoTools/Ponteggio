# Script to copy scaffold.ps1 to a user-specified root directory

# Prompt the user for the root directory
$RootDirectory = Read-Host "Please enter the root directory where scaffold.ps1 should be installed"

# Verify that the directory exists
if (-not (Test-Path -Path $RootDirectory)) {
    Write-Error "The specified directory does not exist. Please provide a valid directory."
    exit 1
}

# Define the source and destination paths
$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$SourcePath = Join-Path -Path $ScriptDir -ChildPath "scaffold.ps1"
$DestinationPath = Join-Path -Path $RootDirectory -ChildPath "scaffold.ps1"

# Copy the scaffold.ps1 file to the specified directory
try {
    Copy-Item -Path $SourcePath -Destination $DestinationPath -Force
    Write-Host "scaffold.ps1 has been successfully copied to $RootDirectory"
} catch {
    Write-Error "An error occurred while copying the file: $_"
}
