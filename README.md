# 🏜️ DuneBox Build Guide

> *Everything you need to build an epic AR sandbox from scratch.*

This repo contains the complete build guide for DuneBox — a home-built augmented reality sandbox that projects topographic maps, GPU-accelerated water simulation, and interactive creatures onto real sand.

## DuneBox Repos

| Repo | What | Tech |
|---|---|---|
| **[DuneBox](https://github.com/Manaiakalani/DuneBox)** | Primary AR sandbox — topo maps, water sim, games | C++ / OpenFrameworks |
| **[DuneBox-sandcam](https://github.com/Manaiakalani/DuneBox-sandcam)** | Hackable sandbox — creatures, ArUco triggers, AI guide | Python / pygame |
| **[DuneBox-docs](https://github.com/Manaiakalani/DuneBox-docs)** | This repo — build guide, BOM, troubleshooting | Markdown |

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
                    │   Mini PC    │  ← Lenovo M720Q + Quadro P400
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
| Lenovo M720Q + Quadro P400 | — | $0 |
| — | Sand + box + frame + cables | **$220–365** |

## License

Documentation is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
