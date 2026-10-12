# Copilot Session – McGruff Reference Discovery
**Date:** 2026-07-29  
**Workspace:** `U:\`  
**Repos in scope:** Forms, Renewal.WebAPI, WebAPI, WebAPI.External, WebUI

---

## Session Summary

This session created a repeatable tool to inventory every McGruff class, interface, setting, and configuration reference across all source repositories, with Azure DevOps deep-links to each line of code.

---

## Conversation

### Turn 1 – User Request

> Create a document that identifies the use of McGruff classes and settings and create a list of source code locations. Provide a list of links via Azure DevOps to code where these references are. Make the process repeatable.

### Turn 1 – Actions Taken

1. **Searched all source files** for the string `McGruff` across every `.cs`, `.config`, `.json`, `.xml`, `.csproj`, `.yml`, `.sql`, `.ps1`, and `.md` file in the workspace.

2. **Identified Azure DevOps org/project** from `README.md` and `.nuspec` files:
   - Org: `fcsamerica`
   - Project: `AgentPro`
   - DevOps URL base: `https://dev.azure.com/fcsamerica/AgentPro/_git/`

3. **Mapped workspace folders to DevOps repo names:**

   | Workspace Folder | DevOps Repo |
   |---|---|
   | `Forms\` | `Forms` |
   | `Renewal.WebAPI\` | `Renewal` |
   | `WebAPI\` | `WebAPI` |
   | `WebAPI.External\` | `External` |
   | `WebUI\` | `WebUI` |

4. **Created** `U:\Find-McGruffReferences.ps1` – a repeatable PowerShell script that scans the workspace and writes `McGruff-References.md`.

5. **Created** `U:\McGruff-References.md` – initial report with **880 total references** across 5 repos.

**Reference counts by repo (initial run):**

| Repository | Matches |
|---|---|
| External | 161 |
| Forms | 404 |
| Renewal | 53 |
| WebAPI | 261 |
| WebUI | 1 |
| **Total** | **880** |

**Categories identified in the report:**

- Settings Interfaces (`ISettings.cs`) – `McGruffAppName`, `McGruffAuditInfoServiceEndpoint`, `McGruffAuthenticationEndpoint`
- Settings Classes – concrete implementations and `SettingService` loading from `AppSettings`
- McGruff Implementation Classes – `McGruffWrapper`, `McGruffProxyHandler`, `McGruffClientFactory`
- McGruff Interfaces – `IMcGruffWrapper`, `IMcGruffClientFactory`
- Dependency Injection Registration – `UnityConfig.cs` registrations
- Configuration Files – `Web.config` / `app.config` keys and `McGruffSettings` sections
- NuGet Package References – `packages.config` entries
- Tests – unit/integration test helpers and stubs
- QA / Postman Collections – token acquisition flows using McGruff
- Using Directives – `using FCSAmerica.IdentityAccessManagement.McGruffCompatibility` etc.

**NuGet packages identified:**

| Package | Version |
|---|---|
| `FCSAmerica.IdentityAccessManagement.McGruffCompatibility` | 1.0.20050.39906 |
| `FCSAmerica.McGruff.TokenGenerator` | 4.0.1 |

---

### Turn 2 – User Request

> Add a list to exclude files by name and extension with or without a full or partial path. Add a way to sort references by FIFO, Folder, Solution.

### Turn 2 – Actions Taken

Updated `U:\Find-McGruffReferences.ps1` with two new parameters:

#### `-ExcludePatterns [string[]]`

Accepts any number of wildcard patterns matched against **both** the bare filename and the repo-relative path. A file is excluded if any pattern matches either.

**Pattern examples:**

| Pattern | What it excludes |
|---|---|
| `"packages.config"` | All `packages.config` files (exact filename match) |
| `"*.postman_collection.json"` | All Postman collection JSON files |
| `"QA/"` | All files under any `QA/` folder |
| `"obj/"`, `"bin/"` | Build output folders |
| `"WebAPI.External/source/External.WebApi.IntegrationTests"` | A specific project folder |

Excluded files are reported on the console and in the Markdown report header and summary table.

#### `-SortBy [FIFO | Folder | Solution]`

Controls the order files appear within each report section:

| Value | Behaviour |
|---|---|
| `FIFO` *(default)* | Filesystem discovery order (`Get-ChildItem` traversal order) |
| `Folder` | Alphabetical by directory path then filename |
| `Solution` | Grouped by repo/solution name first, then alphabetical by folder |

**Usage examples:**

```powershell
# Default – no exclusions, FIFO order
.\Find-McGruffReferences.ps1

# Exclude QA and build artefacts, sort by folder
.\Find-McGruffReferences.ps1 -SortBy Folder `
    -ExcludePatterns "QA/","obj/","bin/","packages.config","*.postman_collection.json","*.postman_environment.json"

# Sort by solution/repo grouping
.\Find-McGruffReferences.ps1 -SortBy Solution

# Custom branch and org
.\Find-McGruffReferences.ps1 -Branch "develop" -AzureDevOpsOrg "fcsamerica"
```

---

## Files Created / Modified

| File | Description |
|---|---|
| `U:\Find-McGruffReferences.ps1` | Repeatable PowerShell scanner – run to regenerate the report |
| `U:\McGruff-References.md` | Generated Markdown report with Azure DevOps line-level links |
| `U:\McGruff-References-Session-2026-07-29.md` | This session log |

---

## Script Parameters Reference

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-WorkspaceRoot` | `string` | Script directory (`U:\`) | Root of the multi-repo workspace |
| `-OutputFile` | `string` | `<WorkspaceRoot>\McGruff-References.md` | Path for the generated report |
| `-AzureDevOpsOrg` | `string` | `fcsamerica` | Azure DevOps organisation name |
| `-AzureDevOpsProject` | `string` | `AgentPro` | Azure DevOps project name |
| `-Branch` | `string` | `main` | Branch name used in DevOps permalinks |
| `-ExcludePatterns` | `string[]` | *(empty)* | Wildcard patterns to exclude files |
| `-SortBy` | `FIFO\|Folder\|Solution` | `FIFO` | Sort order within report sections |

---

## Repo-to-DevOps Mapping

Update the `$RepoMap` hashtable near the top of `Find-McGruffReferences.ps1` if repos are renamed or new ones are added:

```powershell
$RepoMap = [ordered]@{
    "Forms"          = "Forms"
    "Renewal.WebAPI" = "Renewal"
    "WebAPI.External"= "External"
    "WebAPI"         = "WebAPI"
    "WebUI"          = "WebUI"
}
```

---

## Key McGruff Source Locations (Quick Reference)

| File | Repo | Purpose |
|---|---|---|
| `Source/WebAPI/App_Start/MessageHandlers/McGruffProxyHandler.cs` | WebAPI | Proxy handler that injects McGruff service token into outbound requests |
| `Source/WebAPI/Helpers/Infrastructure/McGruffWrapper.cs` | WebAPI | Wraps `McGruff.TokenGenerator.SecurityContext`; provides authenticated HTTP client |
| `Source/WebAPI/Helpers/Infrastructure/IMcGruffWrapper.cs` | WebAPI | Interface for the wrapper (used for DI and testing) |
| `Source/WebAPI.Common/Infrastructure/McGruffClientFactory.cs` | Renewal | Factory that creates `HttpClient` instances authenticated via McGruff token |
| `Source/WebAPI.Common/Infrastructure/IMcGruffClientFactory.cs` | Renewal | Interface for the factory |
| `Source/FormGeneration/Services/CustomerInfoVaultWrapper.cs` | Forms | Uses `McGruff.TokenGenerator.SecurityContext` to call CIV (Customer Info Vault) |
| `Source/WebAPI.Common/Interfaces/ISettings.cs` | WebAPI | Declares `McGruffAppName`, `McGruffAuditInfoServiceEndpoint`, `McGruffAuthenticationEndpoint` |
| `Source/WebAPI.Common/Settings.cs` | WebAPI | Concrete settings implementation |
| `Source/WebAPI.Common/SettingService.cs` | WebAPI | Loads McGruff settings from `ConfigurationManager.AppSettings` |
| `Source/Common/ISettings.cs` | Forms | Same three McGruff settings on the Forms API settings interface |
| `Source/WebAPI/Web.config` | Forms | `McGruffAppName=APFORMAPI`; endpoint keys per partner (FCSA, NWFCS) |
| `Source/WebAPI/Web.config` | WebAPI | `McGruffAppName=APWebAPI`; endpoint keys |
| `Source/WebAPI/App_Start/UnityConfig.cs` | WebAPI | Registers `IMcGruffWrapper → McGruffWrapper` |
| `Source/WebAPI/App_Start/UnityConfig.cs` | Renewal | Registers `IMcGruffClientFactory → McGruffClientFactory` |
