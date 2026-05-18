#Requires -RunAsAdministrator
<#
.SYNOPSIS
    DuneBox Windows Setup Script
    Installs everything needed to build and run DuneBox + DuneBox-sandcam on Windows.

.DESCRIPTION
    Targets: Lenovo ThinkCentre M720Q + Quadro P620 (or any Windows 10/11 PC with Nvidia GPU)
    
    Installs:
      - Git
      - Nvidia GPU drivers (prompts to download)
      - Visual Studio 2022 Build Tools (C++ workload)
      - Python 3.12 + uv
      - OpenFrameworks 0.12.0
      - DuneBox (C++ AR sandbox) + addons
      - DuneBox-sandcam (Python AR sandbox)
      - Kinect for Windows SDK v1.8

    Run from an elevated PowerShell:
      Set-ExecutionPolicy Bypass -Scope Process -Force
      .\setup-windows.ps1

.NOTES
    Author: Manaiakalani (https://github.com/Manaiakalani)
    Project: DuneBox — https://github.com/Manaiakalani/DuneBox-docs
#>

$ErrorActionPreference = "Stop"

# ── Configuration ──────────────────────────────────────────────────────────────
$OF_VERSION    = "0.12.0"
$OF_URL        = "https://github.com/openframeworks/openFrameworks/releases/download/${OF_VERSION}/of_v${OF_VERSION}_vs_release.zip"
$OF_ROOT       = "C:\openFrameworks"
$DUNEBOX_DIR   = "$OF_ROOT\apps\myApps\DuneBox"
$SANDCAM_DIR   = "$HOME\Projects\DuneBox-sandcam"
$KINECT_SDK_URL = "https://www.microsoft.com/en-us/download/details.aspx?id=40278"

# ── Helper functions ───────────────────────────────────────────────────────────
function Write-Step($num, $msg) {
    Write-Host "`n" -NoNewline
    Write-Host "[$num] " -ForegroundColor Cyan -NoNewline
    Write-Host $msg -ForegroundColor White
    Write-Host ("─" * 60) -ForegroundColor DarkGray
}

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Install-WingetPackage($id, $name) {
    if (winget list --id $id 2>$null | Select-String $id) {
        Write-Host "  ✅ $name already installed" -ForegroundColor Green
    } else {
        Write-Host "  📦 Installing $name..." -ForegroundColor Yellow
        winget install --id $id --accept-source-agreements --accept-package-agreements
    }
}

# ── Pre-flight checks ─────────────────────────────────────────────────────────
Write-Host @"

  ╔══════════════════════════════════════════════════════════╗
  ║           🏜️  DuneBox Windows Setup Script  🏜️          ║
  ║                                                          ║
  ║  This script installs everything you need to build       ║
  ║  and run DuneBox on Windows 10/11.                       ║
  ╚══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

if (-not (Test-Command "winget")) {
    Write-Host "❌ winget not found. Please install App Installer from the Microsoft Store." -ForegroundColor Red
    exit 1
}

# ── Step 1: Git ────────────────────────────────────────────────────────────────
Write-Step 1 "Git"

if (Test-Command "git") {
    $gitVer = git --version
    Write-Host "  ✅ $gitVer" -ForegroundColor Green
} else {
    Install-WingetPackage "Git.Git" "Git"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ── Step 2: Nvidia GPU Driver ──────────────────────────────────────────────────
Write-Step 2 "Nvidia GPU Driver"

$gpu = Get-CimInstance -ClassName Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" -or $_.Name -like "*Quadro*" }
if ($gpu) {
    Write-Host "  ✅ GPU detected: $($gpu.Name)" -ForegroundColor Green
    Write-Host "  Driver version: $($gpu.DriverVersion)" -ForegroundColor Gray
    
    $nvidiaDriverInstalled = $gpu.DriverVersion -ne $null
    if (-not $nvidiaDriverInstalled) {
        Write-Host "  ⚠️  No driver detected. Download from:" -ForegroundColor Yellow
        Write-Host "     https://www.nvidia.com/Download/index.aspx" -ForegroundColor White
        Write-Host "     Select: Quadro → Quadro P-Series → Quadro P620 → Windows 10/11 64-bit" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠️  No Nvidia GPU detected. Water simulation requires Nvidia GPU." -ForegroundColor Yellow
    Write-Host "     DuneBox will still work without water sim." -ForegroundColor Gray
}

# ── Step 3: Visual Studio 2022 Build Tools ─────────────────────────────────────
Write-Step 3 "Visual Studio 2022 Build Tools (C++ workload)"

$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsInstalled = $false

if (Test-Path $vsWhere) {
    $vsPath = & $vsWhere -latest -property installationPath 2>$null
    if ($vsPath) {
        Write-Host "  ✅ Visual Studio found at: $vsPath" -ForegroundColor Green
        $vsInstalled = $true
    }
}

if (-not $vsInstalled) {
    Write-Host "  📦 Installing Visual Studio 2022 Build Tools..." -ForegroundColor Yellow
    Write-Host "     This will take 10-30 minutes." -ForegroundColor Gray
    
    winget install --id Microsoft.VisualStudio.2022.BuildTools `
        --override "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --passive --wait" `
        --accept-source-agreements --accept-package-agreements
    
    Write-Host "  ✅ Build Tools installed" -ForegroundColor Green
}

# ── Step 4: Python ─────────────────────────────────────────────────────────────
Write-Step 4 "Python 3.12+"

if (Test-Command "python") {
    $pyVer = python --version 2>&1
    Write-Host "  ✅ $pyVer" -ForegroundColor Green
} else {
    Install-WingetPackage "Python.Python.3.12" "Python 3.12"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Install uv (fast Python package manager)
if (Test-Command "uv") {
    Write-Host "  ✅ uv already installed" -ForegroundColor Green
} else {
    Write-Host "  📦 Installing uv..." -ForegroundColor Yellow
    irm https://astral.sh/uv/install.ps1 | iex
}

# ── Step 5: OpenFrameworks ─────────────────────────────────────────────────────
Write-Step 5 "OpenFrameworks $OF_VERSION"

if (Test-Path "$OF_ROOT\libs\openFrameworksCompiled") {
    Write-Host "  ✅ OpenFrameworks found at $OF_ROOT" -ForegroundColor Green
} else {
    Write-Host "  📦 Downloading OpenFrameworks $OF_VERSION..." -ForegroundColor Yellow
    
    $ofZip = "$env:TEMP\openframeworks.zip"
    
    if (-not (Test-Path $ofZip)) {
        Invoke-WebRequest -Uri $OF_URL -OutFile $ofZip -UseBasicParsing
    }
    
    Write-Host "  📂 Extracting to $OF_ROOT..." -ForegroundColor Yellow
    
    $tempExtract = "$env:TEMP\of_extract"
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    Expand-Archive -Path $ofZip -DestinationPath $tempExtract -Force
    
    $extractedDir = Get-ChildItem $tempExtract -Directory | Select-Object -First 1
    
    if (-not (Test-Path $OF_ROOT)) { New-Item -Path $OF_ROOT -ItemType Directory | Out-Null }
    
    Get-ChildItem $extractedDir.FullName | Move-Item -Destination $OF_ROOT -Force
    
    Remove-Item $tempExtract -Recurse -Force
    Remove-Item $ofZip -Force
    
    Write-Host "  ✅ OpenFrameworks extracted to $OF_ROOT" -ForegroundColor Green
}

$myApps = "$OF_ROOT\apps\myApps"
if (-not (Test-Path $myApps)) {
    New-Item -Path $myApps -ItemType Directory -Force | Out-Null
}

# ── Step 6: Clone DuneBox ─────────────────────────────────────────────────────
Write-Step 6 "Clone DuneBox"

if (Test-Path "$DUNEBOX_DIR\.git") {
    Write-Host "  ✅ DuneBox already cloned at $DUNEBOX_DIR" -ForegroundColor Green
    Push-Location $DUNEBOX_DIR
    git pull --quiet 2>$null
    Pop-Location
} else {
    Write-Host "  📦 Cloning DuneBox..." -ForegroundColor Yellow
    git clone https://github.com/Manaiakalani/DuneBox.git $DUNEBOX_DIR
}

Push-Location $DUNEBOX_DIR
git config user.name "Manaiakalani"
git config user.email "1502119+Manaiakalani@users.noreply.github.com"
Pop-Location

# ── Step 7: Install OpenFrameworks Addons ──────────────────────────────────────
Write-Step 7 "OpenFrameworks Addons"

$addonsDir = "$OF_ROOT\addons"
$addons = @(
    @{ Name = "ofxCv";        Url = "https://github.com/kylemcdonald/ofxCv" },
    @{ Name = "ofxDatGui";    Url = "https://github.com/braitsch/ofxDatGui" },
    @{ Name = "ofxParagraph"; Url = "https://github.com/braitsch/ofxParagraph" },
    @{ Name = "ofxModal";     Url = "https://github.com/braitsch/ofxModal" }
)

foreach ($addon in $addons) {
    $addonPath = Join-Path $addonsDir $addon.Name
    if (Test-Path "$addonPath\.git") {
        Write-Host "  ✅ $($addon.Name) already installed" -ForegroundColor Green
    } else {
        Write-Host "  📦 Cloning $($addon.Name)..." -ForegroundColor Yellow
        git clone $addon.Url $addonPath --quiet
    }
}

$bundled = @("ofxKinect", "ofxOpenCv", "ofxXmlSettings")
foreach ($b in $bundled) {
    if (Test-Path "$addonsDir\$b") {
        Write-Host "  ✅ $b (bundled)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $b not found — may need OF reinstall" -ForegroundColor Yellow
    }
}

# ── Step 8: Clone DuneBox-sandcam ─────────────────────────────────────────────
Write-Step 8 "Clone DuneBox-sandcam"

if (Test-Path "$SANDCAM_DIR\.git") {
    Write-Host "  ✅ DuneBox-sandcam already cloned at $SANDCAM_DIR" -ForegroundColor Green
    Push-Location $SANDCAM_DIR
    git pull --quiet 2>$null
    Pop-Location
} else {
    Write-Host "  📦 Cloning DuneBox-sandcam..." -ForegroundColor Yellow
    if (-not (Test-Path "$HOME\Projects")) { New-Item -Path "$HOME\Projects" -ItemType Directory | Out-Null }
    git clone https://github.com/Manaiakalani/DuneBox-sandcam.git $SANDCAM_DIR
}

Push-Location $SANDCAM_DIR
git config user.name "Manaiakalani"
git config user.email "1502119+Manaiakalani@users.noreply.github.com"
Pop-Location

Write-Host "  📦 Installing sandcam Python dependencies..." -ForegroundColor Yellow
Push-Location $SANDCAM_DIR
if (Test-Command "uv") {
    uv sync 2>$null
    Write-Host "  ✅ Python dependencies installed via uv" -ForegroundColor Green
} else {
    python -m pip install -r requirements.txt 2>$null
    Write-Host "  ✅ Python dependencies installed via pip" -ForegroundColor Green
}
Pop-Location

# ── Step 9: Kinect SDK ─────────────────────────────────────────────────────────
Write-Step 9 "Kinect for Windows SDK"

$kinectV1Sdk = "${env:ProgramFiles}\Microsoft SDKs\Kinect\v1.8"
$kinectV2Sdk = "${env:ProgramFiles}\Microsoft SDKs\Kinect\v2.0_1409"

Write-Host "  Kinect v1 SDK: " -NoNewline
if (Test-Path $kinectV1Sdk) {
    Write-Host "✅ Installed" -ForegroundColor Green
} else {
    Write-Host "❌ Not found" -ForegroundColor Yellow
    Write-Host "     Download Kinect for Windows SDK v1.8 from:" -ForegroundColor Gray
    Write-Host "     $KINECT_SDK_URL" -ForegroundColor White
    Write-Host "     (ofxKinect uses libfreenect — SDK not strictly required," -ForegroundColor Gray
    Write-Host "      but provides useful diagnostic tools)" -ForegroundColor Gray
}

Write-Host "  Kinect v2 SDK: " -NoNewline
if (Test-Path $kinectV2Sdk) {
    Write-Host "✅ Installed" -ForegroundColor Green
} else {
    Write-Host "⏭️  Not needed yet (stretch goal)" -ForegroundColor Gray
}

# ── Step 10: Verify ───────────────────────────────────────────────────────────
Write-Step 10 "Verification Summary"

$checks = @(
    @{ Name = "Git";           OK = (Test-Command "git") },
    @{ Name = "Python";        OK = (Test-Command "python") },
    @{ Name = "uv";            OK = (Test-Command "uv") },
    @{ Name = "OpenFrameworks"; OK = (Test-Path "$OF_ROOT\libs\openFrameworksCompiled") },
    @{ Name = "DuneBox clone"; OK = (Test-Path "$DUNEBOX_DIR\.git") },
    @{ Name = "sandcam clone"; OK = (Test-Path "$SANDCAM_DIR\.git") },
    @{ Name = "ofxCv addon";   OK = (Test-Path "$addonsDir\ofxCv\.git") },
    @{ Name = "ofxDatGui";     OK = (Test-Path "$addonsDir\ofxDatGui\.git") },
    @{ Name = "Nvidia GPU";    OK = ($gpu -ne $null) }
)

$allGood = $true
foreach ($c in $checks) {
    $icon = if ($c.OK) { "✅" } else { "❌"; $allGood = $false }
    Write-Host "  $icon $($c.Name)"
}

Write-Host ""
if ($allGood) {
    Write-Host @"
  ╔══════════════════════════════════════════════════════════╗
  ║          ✅  All checks passed! You're ready.           ║
  ╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green
} else {
    Write-Host @"
  ╔══════════════════════════════════════════════════════════╗
  ║      ⚠️  Some items need attention (see ❌ above).      ║
  ╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Yellow
}

Write-Host @"

  Next steps:
  ─────────────────────────────────────────────────────────
  1. Open Visual Studio → File → Open → Project/Solution
     → $DUNEBOX_DIR\Magic-Sand.sln

  2. Add WaterSimulation files to the project:
     Right-click src → Add Existing Item →
       src\WaterSimulation\WaterSimulation.h
       src\WaterSimulation\WaterSimulation.cpp

  3. Set configuration to x64 Release → Build (Ctrl+Shift+B)

  4. Run (F5) — no Kinect needed, it has a test terrain fallback

  5. Press 'w' to toggle the water simulation

  For sandcam (quick test):
     cd $SANDCAM_DIR
     uv run python main.py
     (works immediately — mouse simulator mode, no hardware needed)

  Full guide: https://github.com/Manaiakalani/DuneBox-docs

"@ -ForegroundColor Cyan
