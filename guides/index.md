# DuneBox

A home-built augmented reality sandbox. A depth camera reads the shape of real sand, and a projector paints it back as a live topographic map with contour lines, flowing water and creatures that react to the terrain.

[Start the build](01-hardware.md){ .md-button .md-button--primary }
[Calibrate a rig](05-calibration.md){ .md-button }

## Two apps, one sandbox

DuneBox ships as two apps that run on the same PC. Use either one, or both at once: they find each other automatically over a local link, and the web dashboard controls both.

<div class="grid-cards" markdown>
<div markdown>
**[DuneBox (C++)](03-setup-dunebox.md)**

The primary sandbox, built on Magic-Sand and openFrameworks. Topographic maps, GPU water and lava, animal games, chessboard calibration.
</div>
<div markdown>
**[sandcam (Python)](04-setup-sandcam.md)**

The hackable sandbox, built with pygame. Creatures, volcanoes, day and night, ArUco toy triggers, mini-games and an optional AI guide. Runs without a camera.
</div>
<div markdown>
**[Web dashboard](10-tablet-dashboard.md)**

Served by sandcam. Watch the live sand map and control both apps from a laptop, or from a tablet on the same Wi-Fi.
</div>
</div>

## Quick start (Windows)

On the sandbox PC, open PowerShell as administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements
gh auth login --hostname github.com --git-protocol https --web
gh repo clone Manaiakalani/DuneBox-docs "$HOME\DuneBox-docs"
& "$HOME\DuneBox-docs\scripts\bootstrap.ps1" -Launch
```

The bootstrap installs Git, Python 3.12, uv and the Visual C++ runtime, clones both apps, fetches the prebuilt DuneBox (C++) binary and adds two desktop shortcuts:

| Shortcut | Starts |
|---|---|
| **DuneBox** | sandcam (Python) |
| **DuneBox (Magic-Sand C++)** | DuneBox (C++) |

It takes about five minutes when a prebuilt binary is available. Both apps run without a depth camera: sandcam falls back to a mouse-driven simulator and DuneBox (C++) to procedural terrain, so you can try everything before the hardware arrives.

!!! note "Private repositories"
    DuneBox-sandcam and DuneBox-docs are private, so the bootstrap asks you to sign in to GitHub once. For an unattended install, set `$env:GH_TOKEN` to a token with `repo` scope before running it.

## How it fits together

```text
 Projector  ◄── HDMI ──  Mini PC  ── USB ──►  Depth camera
                        (both apps)           (Kinect v1, v2 or Azure)
                             │                      │
                             └── Wi-Fi ── Tablet     ▼
                                 (dashboard)    Sand, 40" × 30" box
```

## Typical cost

If you already own a depth camera, a projector and a PC with a modest GPU, the rest (sand, box, frame, cables) costs roughly **$220 to $365**. The [hardware guide](01-hardware.md) has the full list.
