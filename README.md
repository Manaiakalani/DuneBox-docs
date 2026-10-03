# 🏜️ DuneBox Build Guide

> *Everything you need to build an epic AR sandbox from scratch.*

This repo contains the complete build guide for DuneBox: a home-built augmented reality sandbox that projects topographic maps, GPU-accelerated water simulation, and interactive creatures onto real sand.

**Read it as a site:** <https://manaiakalani.github.io/DuneBox-docs/>, or preview locally with `pip install -r requirements-docs.txt` then `mkdocs serve`.

## DuneBox Repos

| Repo | What | Tech | Visibility |
|---|---|---|---|
| **[DuneBox](https://github.com/Manaiakalani/DuneBox)** | Primary AR sandbox: topo maps, water sim, games | C++ / OpenFrameworks | Public |
| **[DuneBox-sandcam](https://github.com/Manaiakalani/DuneBox-sandcam)** | Hackable sandbox: creatures, ArUco triggers, AI guide | Python / pygame | Private (auth required) |
| **[DuneBox-docs](https://github.com/Manaiakalani/DuneBox-docs)** | This repo: build guide, BOM, troubleshooting | Markdown | Public ([site](https://manaiakalani.github.io/DuneBox-docs/)) |

## ⚡ Quick Start (Windows)

On your sandbox PC, open an **elevated PowerShell** (right-click → *Run as administrator*) and paste the commands below. Sign in when asked: DuneBox-sandcam is private.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements
gh auth login --hostname github.com --git-protocol https --web
gh repo clone Manaiakalani/DuneBox-docs "$HOME\DuneBox-docs"
& "$HOME\DuneBox-docs\scripts\bootstrap.ps1" -Launch
```

**That's it.** The bootstrap self-elevates, signs you in to GitHub if needed (sandcam is private), then runs `setup-windows.ps1`, which:
- Installs Git + LFS, Python 3.12, uv, VC++ Redistributable, and checks for Kinect Runtime 2.0
- Clones both app repos and `uv sync --extra kinect-v2`
- Fetches the **pre-built DuneBox app** without overwriting a live `calibration.xml`
- Creates desktop shortcuts named **DuneBox** (sandcam) and **DuneBox (Magic-Sand C++)**
- `-Launch` starts sandcam right away

Typically takes ~5 minutes if a release artifact is already available; 20–25+ minutes if a cloud build must be triggered. Both apps work without a Kinect (sandcam mouse-simulator / C++ procedural terrain).

### Fully unattended (no clicks)
To skip the one-time browser sign-in, provide a token with `repo` scope (needed to clone private sandcam):

```powershell
$env:GH_TOKEN = "ghp_your_token_here"
& "$HOME\DuneBox-docs\scripts\bootstrap.ps1" -Launch
```

### Useful flags
| Flag | Effect |
|---|---|
| `-Launch` | Start sandcam when setup finishes |
| `-NoBuildWait` | Don't trigger/wait for a cloud build if no DuneBox binary exists yet |
| `-Token <pat>` | Sign in non-interactively with a GitHub PAT |

## Guides

### Getting Started
1. **[Hardware Guide](guides/01-hardware.md)**: What to buy, PC requirements, Kinect comparison
2. **[Building the Sandbox](guides/02-build-sandbox.md)**: Physical construction: box, frame, mounts
3. **[Software Setup: DuneBox](guides/03-setup-dunebox.md)**: Pre-built install, or build from source with Visual Studio
4. **[Software Setup: DuneBox-sandcam](guides/04-setup-sandcam.md)**: Python install, test with mouse simulator
5. **[Calibration](guides/05-calibration.md)**: Aligning the projector and Kinect
6. **[Run it from a tablet](guides/10-tablet-dashboard.md)**: The web dashboard, LAN access and the PIN
7. **[Troubleshooting](guides/06-troubleshooting.md)**: Common problems and fixes

### Advanced
8. **[Water Simulation](guides/07-water-simulation.md)**: How the GPU water sim works, tuning parameters
9. **[Custom Themes & Creatures](guides/08-customization.md)**: Adding your own content
10. **[Depth sensors](guides/09-kinect-upgrades.md)**: Kinect, Azure, Femto, RealSense, and sharing a sensor with DuneBox
11. **[Classroom](guides/11-classroom.md)**: Lessons, teams and writing your own lesson files
12. **[Kiosk and buttons](guides/12-kiosk-and-buttons.md)**: Autostart, opening hours, projector power, keypad and Arduino buttons

**[Credits](guides/credits.md)**: SARndbox, Magic-Sand and the other projects DuneBox builds on

## Quick Overview

```
                    ┌─────────────┐
                    │  Projector   │
                    └──────┬──────┘
                           │ HDMI
                    ┌──────┴──────┐
                    │   Mini PC    │  ← Lenovo M720Q + Quadro P620
                    │  (DuneBox)   │
                    └──────┬──────┘
                           │ USB
                    ┌──────┴──────┐
                    │   Kinect v1  │  ← mounted ~40" above sand
                    └──────┬──────┘
                           │ depth data
                    ┌──────┴──────┐
                    │    Sand      │  ← 40"×30" box, Sandtastik white
                    └─────────────┘
```

## Estimated Cost

| Already owned | Need to buy | Est. Cost |
|---|---|---|
| Kinect v1, v2, Azure DK | n/a | $0 |
| Projector | n/a | $0 |
| Lenovo M720Q + Quadro P620 | n/a | $0 |
| n/a | Sand + box + frame + cables | **$220–365** |

## License

Documentation is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
