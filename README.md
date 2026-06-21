# 🏜️ DuneBox Build Guide

> *Everything you need to build an epic AR sandbox from scratch.*

This repo contains the complete build guide for DuneBox — a home-built augmented reality sandbox that projects topographic maps, GPU-accelerated water simulation, and interactive creatures onto real sand.

## DuneBox Repos

| Repo | What | Tech |
|---|---|---|
| **[DuneBox](https://github.com/Manaiakalani/DuneBox)** | Primary AR sandbox — topo maps, water sim, games | C++ / OpenFrameworks |
| **[DuneBox-sandcam](https://github.com/Manaiakalani/DuneBox-sandcam)** | Hackable sandbox — creatures, ArUco triggers, AI guide | Python / pygame |
| **[DuneBox-docs](https://github.com/Manaiakalani/DuneBox-docs)** | This repo — build guide, BOM, troubleshooting | Markdown |

## ⚡ Quick Start (Windows)

On your sandbox PC, open an **elevated PowerShell** (right-click → *Run as administrator*) and paste the **one command** below. It installs everything, signs you in once, fetches the pre-built apps, and creates desktop shortcuts:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements
gh repo clone Manaiakalani/DuneBox-docs "$HOME\DuneBox-docs"
& "$HOME\DuneBox-docs\scripts\bootstrap.ps1" -Launch
```

**That's it.** The bootstrap self-elevates, signs you in to GitHub (one browser click — required since DuneBox-sandcam and DuneBox-docs are private), then runs `setup-windows.ps1`, which:
- Installs Git, Python 3.12, uv, and the Microsoft Visual C++ Redistributable (x64) (silent, no prompts)
- Clones both app repos and installs sandcam's Python dependencies
- Fetches the **pre-built DuneBox app** — no Visual Studio, no compiling (requires the VC++ Redistributable, which the script installs automatically)
  *(latest release → newest CI build artifact → triggers a cloud build and waits, in that order)*
- Checks the Quadro P620 driver and creates desktop shortcuts
- `-Launch` starts sandcam right away

Takes ~5 minutes. Both apps work without a Kinect (mouse-simulator mode).

### Fully unattended (no clicks)
To skip the one-time browser sign-in, provide a token with `repo` scope (required to clone the private repos):

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
1. **[Hardware Guide](guides/01-hardware.md)** — What to buy, PC requirements, Kinect comparison
2. **[Building the Sandbox](guides/02-build-sandbox.md)** — Physical construction: box, frame, mounts
3. **[Software Setup: DuneBox](guides/03-setup-dunebox.md)** — Install OpenFrameworks, build, calibrate
4. **[Software Setup: DuneBox-sandcam](guides/04-setup-sandcam.md)** — Python install, test with mouse simulator
5. **[Calibration](guides/05-calibration.md)** — Aligning the projector and Kinect
6. **[Troubleshooting](guides/06-troubleshooting.md)** — Common problems and fixes

### Advanced
7. **[Water Simulation](guides/07-water-simulation.md)** — How the GPU water sim works, tuning parameters
8. **[Custom Themes & Creatures](guides/08-customization.md)** — Adding your own content
9. **[Kinect v2 & Azure DK](guides/09-kinect-upgrades.md)** — Upgrading beyond Kinect v1

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
| Kinect v1, v2, Azure DK | — | $0 |
| Projector | — | $0 |
| Lenovo M720Q + Quadro P620 | — | $0 |
| — | Sand + box + frame + cables | **$220–365** |

## License

Documentation is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
