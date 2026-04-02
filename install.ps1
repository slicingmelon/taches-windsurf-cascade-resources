#Requires -Version 5.1
<#
.SYNOPSIS
    TACHES Windsurf Cascade Resources - Installer

.DESCRIPTION
    Installs, uninstalls, or updates TACHES workflows, skills, and rules
    into the Windsurf global directory (~/.codeium/windsurf/).

.PARAMETER Action
    install   - Download and install (default)
    uninstall - Remove all installed files
    update    - Re-download and overwrite existing files

.EXAMPLE
    # Remote install (one-liner):
    irm https://raw.githubusercontent.com/slicingmelon/taches-windsurf-cascade-resources/main/install.ps1 | iex

    # With explicit action:
    irm https://raw.githubusercontent.com/slicingmelon/taches-windsurf-cascade-resources/main/install.ps1 -OutFile install.ps1; .\install.ps1 -Action update

.NOTES
    Installs to: $HOME\.codeium\windsurf\
    Restart Windsurf after install/update/uninstall for changes to take effect.
#>

param(
    [ValidateSet("install", "uninstall", "update")]
    [string]$Action = "install"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$REPO     = "slicingmelon/taches-windsurf-cascade-resources"
$BRANCH   = "main"
$BASE_URL = "https://raw.githubusercontent.com/$REPO/$BRANCH"
$API_URL  = "https://api.github.com/repos/$REPO/git/trees/${BRANCH}?recursive=1"

$WINDSURF_DIR = Join-Path $env:USERPROFILE ".codeium\windsurf"
$MANIFEST     = Join-Path $WINDSURF_DIR "taches-install-manifest.json"

$TARGET_DIRS = @{
    "workflows" = Join-Path $WINDSURF_DIR "global_workflows"
    "skills"    = Join-Path $WINDSURF_DIR "skills"
    "rules"     = Join-Path $WINDSURF_DIR "global_rules"
}

function Write-Header {
    Write-Host ""
    Write-Host "  TACHES Windsurf Cascade Resources" -ForegroundColor Cyan
    Write-Host "  https://github.com/$REPO" -ForegroundColor DarkGray
    Write-Host ""
}

function Get-RepoTree {
    Write-Host "  Fetching file list from GitHub..." -ForegroundColor DarkGray
    try {
        $response = Invoke-RestMethod -Uri $API_URL -Headers @{ "User-Agent" = "taches-installer" }
        return $response.tree | Where-Object { $_.type -eq "blob" }
    } catch {
        Write-Host "  ERROR: Could not fetch repo tree. Check your internet connection." -ForegroundColor Red
        Write-Host "  $_" -ForegroundColor DarkGray
        exit 1
    }
}

function Get-WindsurfFiles($tree) {
    return $tree | Where-Object { $_.path -match "^windsurf/(workflows|skills|rules)/" }
}

function Install-Files($files) {
    $installed = @()

    foreach ($file in $files) {
        $path = $file.path

        # Determine target dir
        if ($path -match "^windsurf/workflows/(.+)$") {
            $rel = $Matches[1]
            $dest = Join-Path $TARGET_DIRS["workflows"] $rel.Replace("/", "\")
        } elseif ($path -match "^windsurf/skills/(.+)$") {
            $rel = $Matches[1]
            $dest = Join-Path $TARGET_DIRS["skills"] $rel.Replace("/", "\")
        } elseif ($path -match "^windsurf/rules/(.+)$") {
            $rel = $Matches[1]
            $dest = Join-Path $TARGET_DIRS["rules"] $rel.Replace("/", "\")
        } else {
            continue
        }

        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        $url = "$BASE_URL/$path"
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -Headers @{ "User-Agent" = "taches-installer" } | Out-Null
            $installed += $dest
            Write-Host "  + $path" -ForegroundColor Green
        } catch {
            Write-Host "  ! Failed: $path" -ForegroundColor Yellow
            Write-Host "    $_" -ForegroundColor DarkGray
        }
    }

    return $installed
}

function Save-Manifest($installedFiles) {
    $manifest = @{
        installed_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        repo         = $REPO
        branch       = $BRANCH
        files        = $installedFiles
    }
    $manifest | ConvertTo-Json -Depth 10 | Set-Content $MANIFEST -Encoding UTF8
    Write-Host ""
    Write-Host "  Manifest saved: $MANIFEST" -ForegroundColor DarkGray
}

function Invoke-Install {
    Write-Header
    Write-Host "  Action: INSTALL" -ForegroundColor White

    if (Test-Path $MANIFEST) {
        Write-Host ""
        Write-Host "  Already installed. Use -Action update to refresh." -ForegroundColor Yellow
        Write-Host "  Or use -Action uninstall to remove first." -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }

    # Create target dirs
    foreach ($dir in $TARGET_DIRS.Values) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    $tree  = Get-RepoTree
    $files = Get-WindsurfFiles $tree

    Write-Host "  Installing $($files.Count) files..." -ForegroundColor White
    Write-Host ""

    $installed = Install-Files $files
    Save-Manifest $installed

    Write-Host ""
    Write-Host "  Installed $($installed.Count) files." -ForegroundColor Cyan
    Write-Host "  Restart Windsurf for changes to take effect." -ForegroundColor White
    Write-Host ""
}

function Invoke-Update {
    Write-Header
    Write-Host "  Action: UPDATE" -ForegroundColor White

    $tree  = Get-RepoTree
    $files = Get-WindsurfFiles $tree

    Write-Host "  Updating $($files.Count) files..." -ForegroundColor White
    Write-Host ""

    $installed = Install-Files $files
    Save-Manifest $installed

    Write-Host ""
    Write-Host "  Updated $($installed.Count) files." -ForegroundColor Cyan
    Write-Host "  Restart Windsurf for changes to take effect." -ForegroundColor White
    Write-Host ""
}

function Invoke-Uninstall {
    Write-Header
    Write-Host "  Action: UNINSTALL" -ForegroundColor White

    if (-not (Test-Path $MANIFEST)) {
        Write-Host ""
        Write-Host "  No manifest found. Nothing to uninstall." -ForegroundColor Yellow
        Write-Host "  (Expected: $MANIFEST)" -ForegroundColor DarkGray
        Write-Host ""
        exit 0
    }

    $manifest = Get-Content $MANIFEST -Raw | ConvertFrom-Json
    $removed  = 0
    $missing  = 0

    Write-Host ""
    foreach ($file in $manifest.files) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Host "  - $file" -ForegroundColor Red
            $removed++

            # Clean up empty directories
            $dir = Split-Path $file -Parent
            while ($dir -ne $WINDSURF_DIR -and (Test-Path $dir) -and (Get-ChildItem $dir -Force).Count -eq 0) {
                Remove-Item $dir -Force
                $dir = Split-Path $dir -Parent
            }
        } else {
            $missing++
        }
    }

    Remove-Item $MANIFEST -Force
    Write-Host ""
    Write-Host "  Removed $removed files ($missing already missing)." -ForegroundColor Cyan
    Write-Host "  Restart Windsurf for changes to take effect." -ForegroundColor White
    Write-Host ""
}

# Entry point
switch ($Action) {
    "install"   { Invoke-Install }
    "update"    { Invoke-Update }
    "uninstall" { Invoke-Uninstall }
}
