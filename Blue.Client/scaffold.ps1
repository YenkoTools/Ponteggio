# Helper script to generate a new .NET project
# Example command-line usage:
# .\scaffold.ps1 -ProjectName "Yenko"

# Define parameters
param (
    [string]$ProjectName
)

# Verify that ProjectName is provided
if (-not $ProjectName) {
    Write-Error "The parameter -ProjectName is required. Please provide a valid project name."
    exit 1
}

# Set the current directory to a variable
$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# Create directory structure
New-Item -Path "$ProjectName/src" -ItemType Directory -Force

# Navigate to the base directory
Set-Location -Path $ProjectName

# Create a new solution
dotnet new sln --name $ProjectName

# Navigate to the src directory
Set-Location -Path "src"

# Create the projects
dotnet new fluentblazorwasm -o Client

