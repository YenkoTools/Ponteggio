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

# Create the API directory structure
mkdir -p "$ProjectPath/$ProjectName.Api/src"

# Create the Client directory structure
mkdir -p "$ProjectPath/$ProjectName.Client/src"

# Move into the API project src directory
cd "$ProjectPath/$ProjectName.Api"

# Create a new solution
dotnet new sln --name "$ProjectName.Api"

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

cp -v "$TemplateDir/Api/Api.csproj" "$ProjectPath/$ProjectName.Api/src/Api/"
cp -v "$TemplateDir/Application/Application.csproj" "$ProjectPath/$ProjectName.Api/src/Application/"
cp -v "$TemplateDir/Domain/Domain.csproj" "$ProjectPath/$ProjectName.Api/src/Domain/"
cp -v "$TemplateDir/Infrastructure/Infrastructure.csproj" "$ProjectPath/$ProjectName.Api/src/Infrastructure/"
cp -v "$TemplateDir/Sql/Sql.csproj" "$ProjectPath/$ProjectName.Api/src/Sql/"

# Root-level shared files
cp -v "$TemplateDir/Directory.Build.props" "$ProjectPath/$ProjectName.Api/"
cp -v "$TemplateDir/Directory.Packages.props" "$ProjectPath/$ProjectName.Api/"
cp -v "$TemplateDir/global.json" "$ProjectPath/$ProjectName.Api/"
cp -v "$TemplateDir/build.cake" "$ProjectPath/$ProjectName.Api/"
cp -v "$TemplateDir/build.cake.md" "$ProjectPath/$ProjectName.Api/"
cp -v "$TemplateDir/git-tag.sh" "$ProjectPath/"
cp -v "$TemplateDir/git-tag.md" "$ProjectPath/"
cp -v "$TemplateDir/version.sh" "$ProjectPath/$ProjectName.Api/"

# Move into the Client project directory
cd "$ProjectPath/$ProjectName.Client"

# Create a new solution
dotnet new sln --name "$ProjectName.Client"

# Create projects
cd src
dotnet new fluentblazorwasm -o Client

cd "$ProjectPath/$ProjectName.Client"
dotnet sln add $(find . -name "*.csproj")

# Add all projects to solution
cd "$ProjectPath/$ProjectName.Api"
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

# Sanity Build
cd "$ProjectPath/$ProjectName.Api"
dotnet clean
dotnet build

dotnet new tool-manifest
dotnet tool install Cake.Tool --version 5.0.0

# chmod bash scripts
cd "$ProjectPath/$ProjectName.Api"
chmod +x version.sh
cd "$ProjectPath"
chmod +x git-tag.sh

# Push new project to GitHib
git init
git add .
git commit -m "Initial project commit"
gh repo create $ProjectName --private --source=. --remote=origin --push

git tag -a v0.0.1 -m "Initial project commit"
git push origin v0.0.1

echo "✅ Solution and projects created successfully in $ProjectPath"

