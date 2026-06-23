<#
.SYNOPSIS
    DuneBox one-command bootstrap. Installs GitHub CLI, signs in, pulls the
    docs repo, and hands off to setup-windows.ps1 for the full install.

.DESCRIPTION
    This is the single entry point for a fresh Windows box. It self-elevates to
    Administrator, makes sure GitHub CLI exists, signs you in to GitHub (required
    because DuneBox-sandcam and DuneBox-docs are private repos), clones
    DuneBox-docs, then runs the main unattended installer. Pass-through args go
    straight to setup-windows.ps1.

.EXAMPLE
    # From an elevated PowerShell:
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\bootstrap.ps1 -Launch

.NOTES
    Author: Manaiakalani — https://github.com/Manaiakalani/DuneBox-docs
#>
[CmdletBinding()]
param(
    [switch]$Launch,
    [switch]$NoBuildWait,
    [string]$Token
)

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"

# ── Self-elevate to Administrator ──────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Re-launching as Administrator..." -ForegroundColor Yellow
    $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"")
    if ($Launch)      { $argList += "-Launch" }
    if ($NoBuildWait) { $argList += "-NoBuildWait" }
    if ($Token)       { $argList += @("-Token", $Token) }
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $argList
    return
}

$OWNER    = "Manaiakalani"
$DOCS_DIR = "$HOME\DuneBox-docs"

Write-Host "`n=== DuneBox bootstrap ===" -ForegroundColor Cyan

# ── Ensure winget ──────────────────────────────────────────────────────────────
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Red
    exit 1
}

# ── Ensure Git ─────────────────────────────────────────────────────────────────
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity | Out-Null
    $env:Path += ";$env:ProgramFiles\Git\cmd"
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git did not install correctly. Install Git manually, then re-run." -ForegroundColor Red
        exit 1
    }
}

# ── Ensure GitHub CLI ──────────────────────────────────────────────────────────
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing GitHub CLI..." -ForegroundColor Yellow
    winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity | Out-Null
    $env:Path += ";$env:ProgramFiles\GitHub CLI"
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "GitHub CLI did not install correctly. Install it manually, then re-run." -ForegroundColor Red
        exit 1
    }
}

# ── Sign in (token or one browser flow) ────────────────────────────────────────
if (-not $Token) {
    if     ($env:GH_TOKEN)     { $Token = $env:GH_TOKEN }
    elseif ($env:GITHUB_TOKEN) { $Token = $env:GITHUB_TOKEN }
}
gh auth status 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    if ($Token) { $Token | gh auth login --hostname github.com --git-protocol https --with-token }
    else        { gh auth login --hostname github.com --git-protocol https --web }
}
gh auth setup-git 2>$null | Out-Null

# ── Clone/refresh docs, then run the installer ─────────────────────────────────
if (Test-Path "$DOCS_DIR\.git") {
    Push-Location $DOCS_DIR; git pull --quiet; Pop-Location
} else {
    git clone "https://github.com/$OWNER/DuneBox-docs.git" $DOCS_DIR --quiet
}

$setup = "$DOCS_DIR\scripts\setup-windows.ps1"
$fwd = @{}
if ($Launch)      { $fwd.Launch = $true }
if ($NoBuildWait) { $fwd.NoBuildWait = $true }
if ($Token)       { $fwd.Token = $Token }
Write-Host "Handing off to setup-windows.ps1...`n" -ForegroundColor Cyan
& $setup @fwd
