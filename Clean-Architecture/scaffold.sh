#!/bin/bash

# Usage: ./scaffold.sh <ProjectName>

# Exit on error
set -e

#!/bin/bash
set -e

# Get the directory this script is in
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Load environment variables
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "Error: .env file not found in $SCRIPT_DIR"
    exit 1
fi

# Check required env vars
if [ -z "$DOTNET_VERSION" ] || [ -z "$BASE_DIR" ]; then
    echo "Error: DOTNET_VERSION and BASE_DIR must be defined in the .env file."
    exit 1
fi

# Get project name from first argument
ProjectName="$1"
if [ -z "$ProjectName" ]; then
    echo "Error: Project name is required. Usage: ./scaffold.sh <ProjectName>"
    exit 1
fi

# Full project path
ProjectPath="$BASE_DIR/$ProjectName"

# Create directory structure
mkdir -p "$ProjectPath/src"

# Move into the project directory
cd "$ProjectPath"

# Create a new solution
dotnet new sln --name "$ProjectName"

# Create projects
cd src
dotnet new webapi -o Api --framework "$DOTNET_VERSION"
dotnet new classlib -o Application --framework "$DOTNET_VERSION"
dotnet new classlib -o Domain --framework "$DOTNET_VERSION"
dotnet new classlib -o Infrastructure --framework "$DOTNET_VERSION"
dotnet new classlib -o Sql --framework "$DOTNET_VERSION"

mkdir -p Api/wwwroot

#cd "$SCRIPT_DIR"

# Assuming script is run from same directory where templates exists
TemplateDir="$SCRIPT_DIR/templates/$DOTNET_VERSION"

cp -v "$TemplateDir/Api/Api.csproj" "$ProjectPath/src/Api/"
cp -v "$TemplateDir/Application/Application.csproj" "$ProjectPath/src/Application/"
cp -v "$TemplateDir/Domain/Domain.csproj" "$ProjectPath/src/Domain/"
cp -v "$TemplateDir/Infrastructure/Infrastructure.csproj" "$ProjectPath/src/Infrastructure/"
cp -v "$TemplateDir/Sql/Sql.csproj" "$ProjectPath/src/Sql/"

# Root-level shared files
cp -v "$TemplateDir/Directory.Build.props" "$ProjectPath/"
cp -v "$TemplateDir/Directory.Packages.props" "$ProjectPath/"
cp -v "$TemplateDir/global.json" "$ProjectPath/"
cp -v "$TemplateDir/build.cake" "$ProjectPath/"
cp -v "$TemplateDir/build.cake.md" "$ProjectPath/"
cp -v "$TemplateDir/git-tag.sh" "$ProjectPath/"
cp -v "$TemplateDir/git-tag.md" "$ProjectPath/"
cp -v "$TemplateDir/version.sh" "$ProjectPath/"

# Add all projects to solution
cd "$ProjectPath"
dotnet sln add $(find . -name "*.csproj")

# Add packages to each project
cd src/Api
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

cd ../Application
dotnet add package FluentValidation
dotnet add package FluentValidation.DependencyInjectionExtensions

cd ../Domain
dotnet add package Ardalis.SmartEnum --version 8.2.0

cd ../Infrastructure
dotnet add package Dapper --version 2.1.66
dotnet add package Microsoft.Data.Sqlite --version 9.0.3

# Finalize
cd "$ProjectPath"
dotnet clean
dotnet build

dotnet new tool-manifest
dotnet tool install Cake.Tool --version 5.0.0

echo "✅ Solution and projects created successfully in $ProjectPath"

