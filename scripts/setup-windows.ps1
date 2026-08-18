#Requires -RunAsAdministrator
<#
.SYNOPSIS
    DuneBox one-shot Windows installer — preps, installs, and launches both apps.

.DESCRIPTION
    Targets any Windows 10/11 PC with an Nvidia GPU (tested on the Lenovo
    ThinkCentre M720Q + Quadro P620). Designed to run unattended: every step
    is non-interactive except a single GitHub sign-in (required because
    DuneBox-sandcam and DuneBox-docs are private repos — only DuneBox itself
    is public).

    What it does (~5 min):
      1. Installs Git, GitHub CLI, Python 3.12, and uv (via winget, silent)
      2. Authenticates GitHub (token if provided, else one browser sign-in)
      3. Clones DuneBox + DuneBox-sandcam
      4. Installs sandcam's Python dependencies (uv sync)
      5. Fetches the pre-built DuneBox app (release → CI artifact → triggers a
         build and waits, in that order) so no Visual Studio is ever needed
      6. Checks the Nvidia driver and creates desktop shortcuts
      7. Optionally launches sandcam right away (-Launch)

.PARAMETER Launch
    Start DuneBox-sandcam automatically once setup finishes.

.PARAMETER NoBuildWait
    Don't trigger/wait for a cloud build if no DuneBox binary exists yet.
    sandcam still installs fully; DuneBox can be fetched later via run.bat.

.PARAMETER Token
    A GitHub PAT with `repo` scope (required to clone the private repos). When
    set, sign-in is fully non-interactive. Falls back to $env:GH_TOKEN /
    $env:GITHUB_TOKEN.

.EXAMPLE
    # Fully unattended on a box that already has a token in the environment:
    $env:GH_TOKEN = "ghp_xxx"; .\setup-windows.ps1 -Launch

.EXAMPLE
    # Normal use — one browser sign-in, everything else automatic:
    .\setup-windows.ps1 -Launch

.NOTES
    Author: Manaiakalani (https://github.com/Manaiakalani)
    Project: DuneBox — https://github.com/Manaiakalani/DuneBox-docs
#>
[CmdletBinding()]
param(
    [switch]$Launch,
    [switch]$NoBuildWait,
    [string]$Token
)

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"   # faster, quieter downloads

# ── Configuration ──────────────────────────────────────────────────────────────
$INSTALL_DIR   = "$HOME\DuneBox"
$DUNEBOX_DIR   = "$INSTALL_DIR\DuneBox"
$SANDCAM_DIR   = "$INSTALL_DIR\DuneBox-sandcam"
$REPO_OWNER    = "Manaiakalani"
$WORKFLOW_NAME = "Build & Release"
$ARTIFACT_NAME = "DuneBox-windows-x64"
$WINGET_ARGS   = @(
    "--silent", "--accept-source-agreements", "--accept-package-agreements",
    "--disable-interactivity"
)

# ── Helpers ────────────────────────────────────────────────────────────────────
function Write-Step($num, $msg) {
    Write-Host "`n[$num] " -ForegroundColor Cyan -NoNewline
    Write-Host $msg -ForegroundColor White
    Write-Host ("-" * 60) -ForegroundColor DarkGray
}
function Test-Command($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Sync-Path {
    # Re-read PATH (machine + user) so freshly-installed tools resolve in-session.
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = ($machine, $user, "$HOME\.local\bin",
                 "$env:LocalAppData\Programs\Python\Python312",
                 "$env:LocalAppData\Programs\Python\Python312\Scripts",
                 "$env:ProgramFiles\GitHub CLI") -join ";"
}
function Install-IfMissing($cmd, $wingetId, $label) {
    if (Test-Command $cmd) {
        Write-Host "  [ok] $label already installed" -ForegroundColor Green
        return
    }
    Write-Host "  [..] Installing $label..." -ForegroundColor Yellow
    winget install --id $wingetId -e @WINGET_ARGS | Out-Null
    Sync-Path
    if (-not (Test-Command $cmd)) {
        throw "$label did not install correctly. Re-run this script or install $label manually."
    }
    Write-Host "  [ok] $label installed" -ForegroundColor Green
}

# ── Banner ─────────────────────────────────────────────────────────────────────
Write-Host @"

  ============================================================
            DuneBox Setup (Windows) - unattended
       Installs + configures + launches both sandbox apps.
       No Visual Studio needed. ~5 minutes, minimal clicks.
  ============================================================
"@ -ForegroundColor Cyan

if (-not (Test-Command "winget")) {
    Write-Host "ERROR: winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $INSTALL_DIR)) { New-Item -Path $INSTALL_DIR -ItemType Directory -Force | Out-Null }

# ── Step 1: Core tooling ───────────────────────────────────────────────────────
Write-Step 1 "Core tools (Git, GitHub CLI, Python, uv)"
Install-IfMissing "git"    "Git.Git"            "Git"
if (Test-Command "git") {
    git lfs install --skip-repo 2>$null | Out-Null
    Write-Host "  [ok] Git LFS enabled" -ForegroundColor Green
}
Install-IfMissing "gh"     "GitHub.cli"         "GitHub CLI"
Install-IfMissing "python" "Python.Python.3.12" "Python 3.12"
if (Test-Command "uv") {
    Write-Host "  [ok] uv already installed" -ForegroundColor Green
} else {
    Write-Host "  [..] Installing uv..." -ForegroundColor Yellow
    # Prefer winget for supply-chain safety; fall back to official installer.
    $uvInstalled = $false
    try {
        winget install --id Astral-sh.uv -e @WINGET_ARGS | Out-Null
        Sync-Path
        if (Test-Command "uv") { $uvInstalled = $true }
    } catch {}
    if (-not $uvInstalled) {
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        Sync-Path
    }
    Write-Host "  [ok] uv installed" -ForegroundColor Green
}

# Visual C++ Redistributable — the pre-built Magic-Sand.exe links against it.
# Without it the app exits instantly with 0xC0000135 (STATUS_DLL_NOT_FOUND).
if (Test-Path "$env:WINDIR\System32\VCRUNTIME140_1.dll") {
    Write-Host "  [ok] Visual C++ Redistributable already installed" -ForegroundColor Green
} else {
    Write-Host "  [..] Installing Visual C++ Redistributable..." -ForegroundColor Yellow
    winget install --id "Microsoft.VCRedist.2015+.x64" -e @WINGET_ARGS | Out-Null
    Write-Host "  [ok] Visual C++ Redistributable installed" -ForegroundColor Green
}

# Kinect v2 runtime is not on winget. The committed C++ settings default to v2,
# so warn if Kinect20.dll is missing rather than inventing a package id.
if (Test-Path "$env:WINDIR\System32\Kinect20.dll") {
    Write-Host "  [ok] Kinect v2 runtime already installed" -ForegroundColor Green
} else {
    Write-Host "  [!!] Kinect20.dll not found. Install Kinect Runtime 2.0 from" -ForegroundColor Yellow
    Write-Host "       https://www.microsoft.com/download/details.aspx?id=44559" -ForegroundColor Gray
}

# ── Step 2: GitHub authentication ──────────────────────────────────────────────
Write-Step 2 "GitHub sign-in (required for private repos)"
if (-not $Token) {
    if     ($env:GH_TOKEN)     { $Token = $env:GH_TOKEN }
    elseif ($env:GITHUB_TOKEN) { $Token = $env:GITHUB_TOKEN }
}
$authed = $false
try { gh auth status 2>$null | Out-Null; $authed = ($LASTEXITCODE -eq 0) } catch { $authed = $false }

if ($authed) {
    Write-Host "  [ok] Already signed in to GitHub" -ForegroundColor Green
} elseif ($Token) {
    Write-Host "  [..] Signing in with supplied token..." -ForegroundColor Yellow
    $Token | gh auth login --hostname github.com --git-protocol https --with-token
    Write-Host "  [ok] Signed in (token)" -ForegroundColor Green
} else {
    Write-Host "  [..] One-time browser sign-in (required to clone DuneBox-sandcam and DuneBox-docs)." -ForegroundColor Yellow
    Write-Host "       A code will appear - paste it into the browser that opens." -ForegroundColor Gray
    gh auth login --hostname github.com --git-protocol https --web
}
gh auth setup-git 2>$null | Out-Null   # let git use gh credentials for clones

# ── Step 3: Clone repos ────────────────────────────────────────────────────────
Write-Step 3 "Clone repositories"
function Sync-Repo($name, $dir) {
    if (Test-Path "$dir\.git") {
        Write-Host "  [..] Updating $name..." -ForegroundColor Yellow
        Push-Location $dir; git pull --quiet; Pop-Location
    } else {
        Write-Host "  [..] Cloning $name..." -ForegroundColor Yellow
        git clone "https://github.com/$REPO_OWNER/$name.git" $dir --quiet
    }
    Write-Host "  [ok] $name ready" -ForegroundColor Green
}
Sync-Repo "DuneBox"         $DUNEBOX_DIR
Sync-Repo "DuneBox-sandcam" $SANDCAM_DIR

# ── Step 4: sandcam Python dependencies ────────────────────────────────────────
Write-Step 4 "sandcam dependencies"
Push-Location $SANDCAM_DIR
uv sync --extra kinect-v2
Pop-Location
$sandcamSettings = Join-Path $SANDCAM_DIR "sandcam-settings.json"
if (-not (Test-Path $sandcamSettings)) {
    $example = Join-Path $SANDCAM_DIR "sandcam-settings.example.json"
    if (Test-Path $example) {
        Copy-Item $example $sandcamSettings
    }
    $cfg = @{
        sensor_type     = "kinect_v2_sdk"
        sensor_fallback = "mouse_simulator"
    }
    if (Test-Path $sandcamSettings) {
        try {
            $existing = Get-Content $sandcamSettings -Raw | ConvertFrom-Json
            $existing.sensor_type = "kinect_v2_sdk"
            if (-not $existing.sensor_fallback) { $existing | Add-Member sensor_fallback "mouse_simulator" }
            $existing | ConvertTo-Json -Depth 8 | Set-Content $sandcamSettings -Encoding utf8
        } catch {
            $cfg | ConvertTo-Json | Set-Content $sandcamSettings -Encoding utf8
        }
    } else {
        $cfg | ConvertTo-Json | Set-Content $sandcamSettings -Encoding utf8
    }
    Write-Host "  [ok] First-run settings: kinect_v2_sdk (existing files are left alone)" -ForegroundColor Green
} else {
    Write-Host "  [ok] Existing sandcam-settings.json left unchanged" -ForegroundColor Green
}
Write-Host "  [ok] sandcam dependencies installed" -ForegroundColor Green

# ── Step 5: DuneBox pre-built binary ───────────────────────────────────────────
Write-Step 5 "DuneBox app (pre-built, no Visual Studio)"

function Expand-IntoBin($zip) {
    if (-not (Test-Path "$DUNEBOX_DIR\bin")) { New-Item "$DUNEBOX_DIR\bin" -ItemType Directory | Out-Null }
    # Strip the Mark-of-the-Web from the archive *before* extracting so the MOTW
    # does not propagate onto the extracted files (SmartScreen/SAC otherwise
    # blocks the unsigned exe).
    Unblock-File -Path $zip -ErrorAction SilentlyContinue
    $tmp = Join-Path $env:TEMP "dunebox-extract"
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $tmp | Out-Null
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    $dest = "$DUNEBOX_DIR\bin"
    if (-not (Test-Path $dest)) { New-Item $dest -ItemType Directory | Out-Null }
    Get-ChildItem $tmp -Recurse -File | Where-Object { $_.Extension -in ".exe", ".dll" } | ForEach-Object {
        Copy-Item $_.FullName -Destination $dest -Force
    }
    $data = Get-ChildItem $tmp -Recurse -Directory -Filter data | Select-Object -First 1
    if ($data) {
        # Copy missing data files only — never overwrite a live calibration.
        # robocopy uses 0-7 for success (including "files copied").
        & robocopy $data.FullName (Join-Path $dest "data") /E /XC /XN /XO /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
        if ($LASTEXITCODE -ge 8) {
            throw "robocopy failed with exit $LASTEXITCODE"
        }
    }
    Get-ChildItem $dest -Recurse -File | Unblock-File -ErrorAction SilentlyContinue
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $zip -ErrorAction SilentlyContinue
    return (Test-Path "$DUNEBOX_DIR\bin\Magic-Sand.exe")
}

function Get-DuneBoxBinary {
    $exe = "$DUNEBOX_DIR\bin\Magic-Sand.exe"
    if (Test-Path $exe) { Write-Host "  [ok] DuneBox already installed" -ForegroundColor Green; return $true }

    # (a) Published release asset
    $zip = "$env:TEMP\DuneBox-windows-x64.zip"
    try {
        gh release download --repo "$REPO_OWNER/DuneBox" --pattern "$ARTIFACT_NAME.zip" --output $zip 2>$null
        if (Test-Path $zip) {
            if (Expand-IntoBin $zip) { Write-Host "  [ok] Installed from latest release" -ForegroundColor Green; return $true }
            Write-Host "  [!!] Release zip did not contain Magic-Sand.exe - trying CI artifact..." -ForegroundColor Yellow
        }
    } catch {}

    # (b) Artifact from the most recent successful CI build (no tag needed)
    $runId = $null
    try {
        $runId = gh run list --repo "$REPO_OWNER/DuneBox" --workflow "$WORKFLOW_NAME" `
                    --status success --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null
    } catch {}
    if ($runId) {
        Write-Host "  [..] Downloading build artifact from run $runId..." -ForegroundColor Yellow
        $tmp = "$env:TEMP\dunebox-artifact"
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        gh run download $runId --repo "$REPO_OWNER/DuneBox" --name $ARTIFACT_NAME --dir $tmp 2>$null
        $inner = Get-ChildItem $tmp -Filter "*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($inner) { Expand-IntoBin $inner.FullName }
        elseif (Test-Path $tmp) { Copy-Item "$tmp\*" "$DUNEBOX_DIR\bin\" -Recurse -Force }
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $exe) { Write-Host "  [ok] Installed from CI artifact" -ForegroundColor Green; return $true }
    }

    # (c) No binary anywhere — optionally trigger a cloud build and wait
    if ($NoBuildWait) {
        Write-Host "  [!!] No pre-built binary yet (skipping build wait)." -ForegroundColor Yellow
        Write-Host "       Run '$DUNEBOX_DIR\run.bat' later to fetch it automatically." -ForegroundColor Gray
        return $false
    }
    Write-Host "  [..] No binary found - triggering a cloud build (~20-25 min)..." -ForegroundColor Yellow
    gh workflow run "$WORKFLOW_NAME" --repo "$REPO_OWNER/DuneBox" --ref main 2>$null
    Start-Sleep -Seconds 8
    $newRun = gh run list --repo "$REPO_OWNER/DuneBox" --workflow "$WORKFLOW_NAME" `
                --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null
    if ($newRun) {
        Write-Host "  [..] Watching build $newRun (this is the long part)..." -ForegroundColor Yellow
        gh run watch $newRun --repo "$REPO_OWNER/DuneBox" --exit-status 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [..] Downloading artifact from the new build..." -ForegroundColor Yellow
            $tmp = "$env:TEMP\dunebox-artifact"
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
            gh run download $newRun --repo "$REPO_OWNER/DuneBox" --name $ARTIFACT_NAME --dir $tmp 2>$null
            $inner = Get-ChildItem $tmp -Filter "*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($inner) { Expand-IntoBin $inner.FullName }
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
            if (Test-Path $exe) { Write-Host "  [ok] Installed from triggered CI build" -ForegroundColor Green; return $true }
            Write-Host "  [!!] Build finished but the artifact could not be downloaded." -ForegroundColor Yellow
            Write-Host "       Run '$DUNEBOX_DIR\run.bat' later to fetch it." -ForegroundColor Gray
            return $false
        }
        Write-Host "  [xx] Cloud build failed. See: gh run view $newRun --repo $REPO_OWNER/DuneBox" -ForegroundColor Red
    }
    return $false
}
$duneboxReady = Get-DuneBoxBinary

# ── Step 6: GPU check ──────────────────────────────────────────────────────────
Write-Step 6 "Nvidia GPU"
$gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match "NVIDIA|Quadro" }
if ($gpu) {
    Write-Host "  [ok] $($gpu.Name) (driver $($gpu.DriverVersion))" -ForegroundColor Green
} else {
    Write-Host "  [!!] No Nvidia GPU detected - water sim needs one; everything else still works." -ForegroundColor Yellow
}

# ── Step 7: Desktop shortcuts ──────────────────────────────────────────────────
Write-Step 7 "Desktop shortcuts"
$desktop = [System.Environment]::GetFolderPath("Desktop")
$ws = New-Object -ComObject WScript.Shell
foreach ($app in @(
    @{ Name = "DuneBox";                     Dir = $SANDCAM_DIR },
    @{ Name = "DuneBox (Magic-Sand C++)";    Dir = $DUNEBOX_DIR }
)) {
    $sc = $ws.CreateShortcut("$desktop\$($app.Name).lnk")
    $sc.TargetPath = "$($app.Dir)\run.bat"
    $sc.WorkingDirectory = $app.Dir
    $sc.Description = $app.Name
    if (Test-Path "$($app.Dir)\icon.ico") { $sc.IconLocation = "$($app.Dir)\icon.ico" }
    $sc.Save()
}
$legacy = Join-Path $desktop "DuneBox-sandcam.lnk"
if (Test-Path $legacy) { Remove-Item $legacy -Force }
Write-Host "  [ok] Shortcuts created on the desktop" -ForegroundColor Green

# ── Summary ────────────────────────────────────────────────────────────────────
Write-Step "*" "Summary"
$checks = @(
    @{ Name = "Git";          OK = (Test-Command "git") },
    @{ Name = "GitHub CLI";   OK = (Test-Command "gh") },
    @{ Name = "Python";       OK = (Test-Command "python") },
    @{ Name = "uv";           OK = (Test-Command "uv") },
    @{ Name = "sandcam repo"; OK = (Test-Path "$SANDCAM_DIR\.git") },
    @{ Name = "DuneBox app";  OK = (Test-Path "$DUNEBOX_DIR\bin\Magic-Sand.exe") },
    @{ Name = "Nvidia GPU";   OK = ($null -ne $gpu) }
)
foreach ($c in $checks) {
    $icon = if ($c.OK) { "[x]" } else { "[ ]" }
    Write-Host "  $icon $($c.Name)"
}

Write-Host @"

  ============================================================
                       Setup complete!
  ============================================================

  Launch:
    sandcam  ->  double-click "DuneBox" on the desktop
    DuneBox  ->  double-click "DuneBox (Magic-Sand C++)" on the desktop

  sandcam uses Kinect v2 (SDK) and falls back to the mouse simulator.
"@ -ForegroundColor Cyan
if (-not $duneboxReady) {
    Write-Host "  Note: DuneBox binary isn't present yet - its run.bat will fetch it`n        automatically once a CI build succeeds.`n" -ForegroundColor Yellow
}

if ($Launch) {
    Write-Host "  Launching sandcam..." -ForegroundColor Green
    Start-Process -FilePath "$SANDCAM_DIR\run.bat" -WorkingDirectory $SANDCAM_DIR
}
