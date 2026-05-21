#Requires -RunAsAdministrator
<#
.SYNOPSIS
    DuneBox Windows Setup — downloads and installs both sandbox apps.

.DESCRIPTION
    Targets: Any Windows 10/11 PC with Nvidia GPU (tested on M720Q + Quadro P620)
    
    What this does (5 minutes):
      1. Installs Git + GitHub CLI (via winget)
      2. Installs Python 3.12 + uv (for sandcam)
      3. Downloads pre-built DuneBox release (no Visual Studio needed!)
      4. Clones DuneBox-sandcam + installs Python dependencies
      5. Checks Nvidia GPU driver status

    Run from elevated PowerShell:
      Set-ExecutionPolicy Bypass -Scope Process -Force
      .\setup-windows.ps1

.NOTES
    Author: Manaiakalani (https://github.com/Manaiakalani)
    Project: DuneBox — https://github.com/Manaiakalani/DuneBox-docs
#>

$ErrorActionPreference = "Stop"

# ── Configuration ──────────────────────────────────────────────────────────────
$INSTALL_DIR   = "$HOME\DuneBox"
$DUNEBOX_DIR   = "$INSTALL_DIR\DuneBox"
$SANDCAM_DIR   = "$INSTALL_DIR\DuneBox-sandcam"
$REPO_OWNER    = "Manaiakalani"

# ── Helpers ────────────────────────────────────────────────────────────────────
function Write-Step($num, $msg) {
    Write-Host "`n" -NoNewline
    Write-Host "[$num] " -ForegroundColor Cyan -NoNewline
    Write-Host $msg -ForegroundColor White
    Write-Host ("─" * 60) -ForegroundColor DarkGray
}

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

# ── Banner ─────────────────────────────────────────────────────────────────────
Write-Host @"

  ╔══════════════════════════════════════════════════════════╗
  ║           🏜️  DuneBox Setup (Windows)  🏜️               ║
  ║                                                          ║
  ║  No Visual Studio needed — downloads pre-built app.      ║
  ║  Takes about 5 minutes.                                  ║
  ╚══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

if (-not (Test-Command "winget")) {
    Write-Host "❌ winget not found. Install App Installer from Microsoft Store." -ForegroundColor Red
    exit 1
}

# Create install directory
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -Path $INSTALL_DIR -ItemType Directory -Force | Out-Null
}

# ── Step 1: Git + GitHub CLI ───────────────────────────────────────────────────
Write-Step 1 "Git + GitHub CLI"

if (Test-Command "git") {
    Write-Host "  ✅ Git installed" -ForegroundColor Green
} else {
    Write-Host "  📦 Installing Git..." -ForegroundColor Yellow
    winget install --id Git.Git --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if (Test-Command "gh") {
    Write-Host "  ✅ GitHub CLI installed" -ForegroundColor Green
} else {
    Write-Host "  📦 Installing GitHub CLI..." -ForegroundColor Yellow
    winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ── Step 2: Python + uv ───────────────────────────────────────────────────────
Write-Step 2 "Python + uv"

if (Test-Command "python") {
    $pyVer = python --version 2>&1
    Write-Host "  ✅ $pyVer" -ForegroundColor Green
} else {
    Write-Host "  📦 Installing Python 3.12..." -ForegroundColor Yellow
    winget install --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

if (Test-Command "uv") {
    Write-Host "  ✅ uv installed" -ForegroundColor Green
} else {
    Write-Host "  📦 Installing uv..." -ForegroundColor Yellow
    irm https://astral.sh/uv/install.ps1 | iex
}

# ── Step 3: DuneBox (pre-built) ───────────────────────────────────────────────
Write-Step 3 "DuneBox (pre-built release)"

if (Test-Path "$DUNEBOX_DIR\bin\Magic-Sand.exe") {
    Write-Host "  ✅ DuneBox already installed at $DUNEBOX_DIR" -ForegroundColor Green
} else {
    # Clone repo (for shaders, data files, config)
    if (-not (Test-Path "$DUNEBOX_DIR\.git")) {
        Write-Host "  📦 Cloning DuneBox repo..." -ForegroundColor Yellow
        git clone "https://github.com/$REPO_OWNER/DuneBox.git" $DUNEBOX_DIR --quiet
    }

    # Download pre-built release
    Write-Host "  📦 Downloading latest pre-built release..." -ForegroundColor Yellow
    $zipFile = "$env:TEMP\DuneBox-windows-x64.zip"

    Push-Location $DUNEBOX_DIR
    $downloaded = $false
    try {
        gh release download --pattern "DuneBox-windows-x64.zip" --output $zipFile 2>$null
        $downloaded = Test-Path $zipFile
    } catch {}
    Pop-Location

    if ($downloaded) {
        if (-not (Test-Path "$DUNEBOX_DIR\bin")) {
            New-Item "$DUNEBOX_DIR\bin" -ItemType Directory | Out-Null
        }
        Expand-Archive -Path $zipFile -DestinationPath "$DUNEBOX_DIR\bin" -Force
        Remove-Item $zipFile
        Write-Host "  ✅ DuneBox installed" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  No release build available yet." -ForegroundColor Yellow
        Write-Host "     The CI pipeline will build it on the next push." -ForegroundColor Gray
        Write-Host "     To trigger: git tag v0.1.0 && git push origin v0.1.0" -ForegroundColor Gray
        Write-Host "     Or just double-click run.bat — it auto-downloads when ready." -ForegroundColor Gray
    }
}

# ── Step 4: DuneBox-sandcam ───────────────────────────────────────────────────
Write-Step 4 "DuneBox-sandcam"

if (Test-Path "$SANDCAM_DIR\.git") {
    Write-Host "  ✅ sandcam already cloned at $SANDCAM_DIR" -ForegroundColor Green
    Push-Location $SANDCAM_DIR
    git pull --quiet 2>$null
    Pop-Location
} else {
    Write-Host "  📦 Cloning DuneBox-sandcam..." -ForegroundColor Yellow
    git clone "https://github.com/$REPO_OWNER/DuneBox-sandcam.git" $SANDCAM_DIR --quiet
}

Write-Host "  📦 Installing Python dependencies..." -ForegroundColor Yellow
Push-Location $SANDCAM_DIR
if (Test-Command "uv") {
    uv sync 2>$null
    Write-Host "  ✅ Dependencies installed" -ForegroundColor Green
} else {
    python -m pip install -r requirements.txt 2>$null
    Write-Host "  ✅ Dependencies installed (pip)" -ForegroundColor Green
}
Pop-Location

# ── Step 5: GPU check ─────────────────────────────────────────────────────────
Write-Step 5 "Nvidia GPU"

$gpu = Get-CimInstance -ClassName Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" -or $_.Name -like "*Quadro*" }
if ($gpu) {
    Write-Host "  ✅ $($gpu.Name)" -ForegroundColor Green
    Write-Host "     Driver: $($gpu.DriverVersion)" -ForegroundColor Gray
} else {
    Write-Host "  ⚠️  No Nvidia GPU detected." -ForegroundColor Yellow
    Write-Host "     Water simulation requires Nvidia GPU." -ForegroundColor Gray
    Write-Host "     DuneBox topo maps + sandcam will still work fine." -ForegroundColor Gray
}

# ── Step 6: Verify ────────────────────────────────────────────────────────────
Write-Step 6 "Summary"

$checks = @(
    @{ Name = "Git";             OK = (Test-Command "git") },
    @{ Name = "GitHub CLI";      OK = (Test-Command "gh") },
    @{ Name = "Python";          OK = (Test-Command "python") },
    @{ Name = "uv";              OK = (Test-Command "uv") },
    @{ Name = "DuneBox repo";    OK = (Test-Path "$DUNEBOX_DIR\.git") },
    @{ Name = "DuneBox exe";     OK = (Test-Path "$DUNEBOX_DIR\bin\Magic-Sand.exe") },
    @{ Name = "sandcam repo";    OK = (Test-Path "$SANDCAM_DIR\.git") },
    @{ Name = "Nvidia GPU";      OK = ($gpu -ne $null) }
)

$allGood = $true
foreach ($c in $checks) {
    $icon = if ($c.OK) { "✅" } else { "⬜"; $allGood = $false }
    Write-Host "  $icon $($c.Name)"
}

Write-Host ""

# ── Desktop shortcuts ──────────────────────────────────────────────────────────
$desktop = [System.Environment]::GetFolderPath("Desktop")

# DuneBox shortcut
$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut("$desktop\DuneBox.lnk")
$sc.TargetPath = "$DUNEBOX_DIR\run.bat"
$sc.WorkingDirectory = $DUNEBOX_DIR
$sc.Description = "DuneBox AR Sandbox"
if (Test-Path "$DUNEBOX_DIR\icon.ico") { $sc.IconLocation = "$DUNEBOX_DIR\icon.ico" }
$sc.Save()

# sandcam shortcut
$sc2 = $ws.CreateShortcut("$desktop\DuneBox-sandcam.lnk")
$sc2.TargetPath = "$SANDCAM_DIR\run.bat"
$sc2.WorkingDirectory = $SANDCAM_DIR
$sc2.Description = "DuneBox sandcam (Python)"
$sc2.Save()

Write-Host "  🖥️  Desktop shortcuts created!" -ForegroundColor Green

Write-Host @"

  ╔══════════════════════════════════════════════════════════╗
  ║                    ✅  Setup Complete!                   ║
  ╚══════════════════════════════════════════════════════════╝

  To run:
  ─────────────────────────────────────────────────────────
  🏜️  DuneBox:   Double-click "DuneBox" on your desktop
                  or: cd $DUNEBOX_DIR && .\run.bat

  🐍  sandcam:   Double-click "DuneBox-sandcam" on your desktop
                  or: cd $SANDCAM_DIR && .\run.bat

  Both work without a Kinect (test/simulator modes).
  Press 'w' in DuneBox to toggle the water simulation.

  Full guide: https://github.com/$REPO_OWNER/DuneBox-docs

"@ -ForegroundColor Cyan
