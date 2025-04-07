// Install SSH.NET as a Cake Tool
#tool nuget:?package=SSH.NET&version=2024.0.0
// Install SSH.NET as a Cake Addin
#addin nuget:?package=SSH.NET&version=2024.0.0
// Install System.Text.Json as a Cake Addin
#addin nuget:?package=System.Text.Json&version=8.0.5
// Install System.Text.Json as a Cake Tool
#tool nuget:?package=System.Text.Json&version=8.0.5

var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");
var version = Argument("packageVersion", "1.0.0");
var prerelease = Argument("prerelease", "");

string packageVersion = String.Empty;
//////////////////////////////////////////////////////////////////////
// TASKS
//////////////////////////////////////////////////////////////////////
Setup(context =>
{
    if (BuildSystem.IsLocalBuild && string.IsNullOrEmpty(prerelease))
    {
        prerelease = "-local";
        // configuration = "Debug";
    }

    try
    {
        var processSettings = new ProcessSettings
        {
            Arguments = "-ExecutionPolicy Bypass -File ./version.ps1"
        };
        StartProcess("pwsh", processSettings);

        var jsonContent = System.IO.File.ReadAllText("src/Api/wwwroot/version.json");
        var versionDto = System.Text.Json.JsonSerializer.Deserialize<VersionDto>(jsonContent);

        if (versionDto.GitTag.StartsWith("v"))
        {
            versionDto.GitTag = versionDto.GitTag.Substring(1);
        }

        packageVersion = $"{versionDto.BuildNumber}-{versionDto.GitTag}";

        Information($"Package Version: {packageVersion}");
    }
    catch (Exception ex)
    {
        Information($"Error setting up version: {ex.Message}");
    }
});

Task("Clean")
    .Does(() =>
    {
        CleanDirectory("artifacts");
        CleanDirectory($"src/Api/bin/{configuration}");
        CleanDirectory("src/Api/obj/");
        CleanDirectory($"src/Application/bin/{configuration}");
        CleanDirectory("src/Application/obj/");
        CleanDirectory($"src/Domain/bin/{configuration}");
        CleanDirectory("src/Domain/obj/");
        CleanDirectory($"src/Infrastructure/bin/{configuration}");
        CleanDirectory("src/Infrastructure/obj/");
        CleanDirectory($"src/Sql/bin/{configuration}");
        CleanDirectory("src/Sql/obj/");

    });

Task("Restore")
    .IsDependentOn("Clean")
    .Description("Restoring the solution dependencies")
    .Does(() =>
    {
        var projects = GetFiles("./**/*.csproj");

        foreach (var project in projects)
        {
            Information($"Building {project.ToString()}");
            DotNetRestore(project.ToString());
        }
    });

Task("Build")
    .IsDependentOn("Clean")
    .IsDependentOn("Restore")
    .Does(() =>
    {
        var projects = GetFiles("./**/*.csproj");

        foreach (var project in projects)
        {
            var buildSettings = new DotNetBuildSettings()
            {
                Configuration = configuration,
                NoRestore = true
            };
            DotNetBuild(project.FullPath, buildSettings);
        }
    });


Task("Test")
    .IsDependentOn("Build")
    .Does(() =>
    {
        var testSettings = new DotNetTestSettings
        {
            Configuration = configuration,
            NoBuild = true,
        };

        var projects = GetFiles("./tests/*/*.csproj");
        foreach (var project in projects)
        {
            Information($"Running Tests : {project.ToString()}");
            DotNetTest(project.ToString(), testSettings);
        }
    });

Task("Publish")
.Does(() =>
{
    DotNetPublish("src/Api/Api.csproj", new DotNetPublishSettings
    {
        Configuration = configuration,
        OutputDirectory = "./artifacts/",
        NoBuild = true,
    });

    var zipFilePath = $"./artifacts/{packageVersion}.zip";
    var sourceDirectory = "./artifacts/";
    Information($"Creating zip file: {zipFilePath}");
    Zip(sourceDirectory, zipFilePath);
});


//////////////////////////////////////////////////////////////////////
// EXECUTION
//////////////////////////////////////////////////////////////////////

Task("Default")
       .IsDependentOn("Clean")
       .IsDependentOn("Restore")
       .IsDependentOn("Build")
       .IsDependentOn("Test")
       .IsDependentOn("Publish");

RunTarget(target);

public class VersionDto
{
    public string BuildDate { get; set; }
    public string BuildHost { get; set; }
    public string BuildNumber { get; set; }
    public string CommitHash { get; set; }
    public string CurrentUser { get; set; }
    public string GitBranch { get; set; }
    public string GitHead { get; set; }
    public string GitTag { get; set; }
}
