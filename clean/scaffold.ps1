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
dotnet new webapi -o Api --framework net8.0
dotnet new classlib -o Application --framework net8.0
dotnet new classlib -o Domain --framework net8.0
dotnet new classlib -o Infrastructure --framework net8.0
dotnet new classlib -o Sql --framework net8.0

# Navigate back up to the base directory
Set-Location -Path $ScriptDir/$ProjectName

New-Item -Path "./src/Api/wwwroot" -ItemType Directory -Force

# Copy 
Copy-Item -Path "$ScriptDir/Ponteggio/clean/Api.csproj" -Destination "$ScriptDir/$ProjectName/src/Api/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/Application.csproj" -Destination "$ScriptDir/$ProjectName/src/Application/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/Domain.csproj" -Destination "$ScriptDir/$ProjectName/src/Domain/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/Infrastructure.csproj" -Destination "$ScriptDir/$ProjectName/src/Infrastructure/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/Sql.csproj" -Destination "$ScriptDir/$ProjectName/src/Sql/" -Force

Copy-Item -Path "$ScriptDir/Ponteggio/clean/Directory.Build.props" -Destination "$ScriptDir/$ProjectName/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/Directory.Packages.props" -Destination "$ScriptDir/$ProjectName/" -Force

Copy-Item -Path "$ScriptDir/Ponteggio/clean/build.cake" -Destination "$ScriptDir/$ProjectName/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/build.cake.md" -Destination "$ScriptDir/$ProjectName/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/git-tag.ps1" -Destination "$ScriptDir/$ProjectName/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/git-tag.md" -Destination "$ScriptDir/$ProjectName/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/version.ps1" -Destination "$ScriptDir/$ProjectName/" -Force
Copy-Item -Path "$ScriptDir/Ponteggio/clean/global.json" -Destination "$ScriptDir/$ProjectName/" -Force

# Add projects to the solution
dotnet sln add (Get-ChildItem -Recurse -Filter "*.csproj" | ForEach-Object { $_.FullName })

Set-Location -Path $ScriptDir/$ProjectName/src/Api

dotnet add package FluentValidation --version 11.11.0
dotnet add package FluentValidation.DependencyInjectionExtensions --version 11.11.0
dotnet add package Microsoft.AspNetCore.OpenApi --version 8.0.14
dotnet add package Serilog.AspNetCore --version 9.0.0
dotnet add package Serilog.Enrichers.ClientInfo
dotnet add package Serilog.Enrichers.Environment
dotnet add package Serilog.Enrichers.Thread
dotnet add package Serilog.Settings.Configuration
dotnet add package Serilog.Sinks.Async
dotnet add package Serilog.Sinks.File
dotnet add package Serilog.Sinks.Seq
dotnet add package Swashbuckle.AspNetCore --version 8.1.0

Set-Location -Path $ScriptDir/$ProjectName/src/Application
dotnet add package FluentValidation
dotnet add package FluentValidation.DependencyInjectionExtensions

Set-Location -Path $ScriptDir/$ProjectName/src/Domain
dotnet add package Ardalis.SmartEnum --version 8.2.0

Set-Location -Path $ScriptDir/$ProjectName/src/Infrastructure
dotnet add package Dapper --version 2.1.66
dotnet add package Microsoft.Data.Sqlite --version 9.0.3

Set-Location -Path $ScriptDir/$ProjectName
dotnet clean
dotnet build

dotnet new tool-manifest
dotnet tool install Cake.Tool --version 5.0.0

Write-Host "Solution and projects created successfully in $ProjectName"
