# 🚀 Project Name

A modern web application built with:

- 🌐 **.NET 8.0 Web API** — RESTful backend service  
- 💡 **.NET 8.0 Blazor WebAssembly** + **Fluent UI** — beautiful, responsive front-end

---

## 📁 Project Structure

📁 project-root/ 
├── 📁 src/
├── 📄 main.js
└── 📄 utils.js 
├── 📁 docs/
└── 📄 README.md 
├── 📄 .gitignore 
└── 📄 package.json


## 🚀 Getting Started



(x) Central Package Management
https://devblogs.microsoft.com/dotnet/introducing-central-package-management/

- Directory.Build.props
- Directory.Packages.props
- .NET version is referenced in only one place --> Directory.Build.props

(#) Cake build tool
https://cakebuild.net/

- build.cake
- build.cake.md

```shell
dotnet cake
```

```shell
dotnet cake --Target
```

(#) git-tag script

(#) version script

(#) .NET version global.json configuration
