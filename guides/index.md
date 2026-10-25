# DuneBox

A home-built augmented reality sandbox. A depth camera reads the shape of real sand, and a projector paints it back as a live topographic map with contour lines, flowing water and creatures that react to the terrain.

[Start the build](01-hardware.md){ .md-button .md-button--primary }
[Calibrate a rig](05-calibration.md){ .md-button }

## Two apps, one sandbox

DuneBox ships as two apps that run on the same PC. Use either one, or both at once: they find each other over a local link, and the web dashboard controls both. To share one depth camera, turn on **Share this sensor with DuneBox** in sandcam and set DuneBox (C++) to `kinectVersion` 4 ([how](09-kinect-upgrades.md#use-any-sandcam-sensor-in-dunebox)). Two apps both opening Kinect v2 will fight over the camera.

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
gh repo clone Manaiakalani/DuneBox-docs "$HOME\DuneBox-docs"
& "$HOME\DuneBox-docs\scripts\bootstrap.ps1" -Launch
```

The bootstrap installs Git, Python 3.12, uv and the Visual C++ runtime, clones both apps, fetches the prebuilt DuneBox (C++) binary and adds two desktop shortcuts:

| Shortcut | Starts |
|---|---|
| **DuneBox** | sandcam (Python) |
| **DuneBox (C++)** | C++ renderer |

It takes about five minutes when a prebuilt binary is available. Both apps run without a depth camera: sandcam falls back to a mouse-driven simulator and DuneBox (C++) to procedural terrain, so you can try everything before the hardware arrives.

!!! note "Public repos"
    DuneBox, DuneBox-sandcam, and this docs site are all public. The bootstrap clones them without a GitHub sign-in. A token is only needed when no DuneBox release exists yet and the installer has to trigger a cloud build.

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
