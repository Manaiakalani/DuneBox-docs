# Software setup: DuneBox (C++)

## Overview

DuneBox is the primary AR sandbox application. It runs on **Windows** using OpenFrameworks. This guide walks through getting it built and running.

**Repo**: [Manaiakalani/DuneBox](https://github.com/Manaiakalani/DuneBox)

---

## Features

DuneBox includes:

- **GPU water simulation**: fragment shader and compute shader backends
- **Lava simulation mode**: auto-switches to Volcanic theme
- **5 color themes**: Topo, Ocean, Volcanic, Ice Age, Alien (cycle with `t`)
- **Day/night cycle**: animated lighting with sun/moon transitions
- **Volcano eruption**: manual trigger at center of sandbox
- **Startup diagnostics**: GPU, Kinect, and shader checks logged to the console on launch
- **Inter-app bridge**: TCP/JSON link to DuneBox-sandcam on `localhost:9876`
- **Kinect v1/v2, or any sandcam sensor**: Windows binary defaults to Kinect v2. Azure Kinect, Orbbec Femto and RealSense reach DuneBox through sandcam (`kinectVersion` 4). See [Depth sensors](09-kinect-upgrades.md).
- **XML-configurable water**: tune water physics via `bin/data/settings/waterSettings.xml`
- **Map & boid games**: interactive educational game modes

---

## Option A: Pre-built release (recommended, no coding)

On your sandbox PC, open an **elevated PowerShell** and run the one-command bootstrap:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements
gh auth login --hostname github.com --git-protocol https --web
gh repo clone Manaiakalani/DuneBox-docs "$HOME\DuneBox-docs"
& "$HOME\DuneBox-docs\scripts\bootstrap.ps1" -Launch
```

This fetches the pre-built `.exe`, installs both apps and their dependencies, and creates desktop shortcuts. **No Visual Studio or build tools needed.** The binary is sourced automatically: latest GitHub release → newest CI build artifact → (if neither exists) a fresh cloud build it triggers and waits for.

> **Note**: The pre-built `Magic-Sand.exe` requires the **Microsoft Visual C++ Redistributable (x64)**. Without it the app exits immediately with error `0xC0000135`. The bootstrap script installs this automatically via `winget install Microsoft.VCRedist.2015+.x64`.

Already cloned? Just double-click **`run.bat`** in the DuneBox folder: it performs the same release→artifact auto-download on its own.

> The Windows binary is produced by GitHub Actions (`.github/workflows/build.yml`). You can trigger a build any time from the Actions tab (**Run workflow**) or with `gh workflow run "Build & Release" --repo Manaiakalani/DuneBox`.

---

## Option B: Build from Source (for developers)

Only needed if you want to modify the C++ code.

### Prerequisites

| Dependency | Version | Purpose |
|---|---|---|
| OpenFrameworks | 0.12.0 | Application framework |
| Visual Studio 2022 | Community or newer | C++ compiler (Windows) |

---

## Step 1: Clone the Repo

```bash
git lfs install
git clone https://github.com/Manaiakalani/DuneBox.git
cd DuneBox
```

Map-game imagery is stored in Git LFS. Clone into `openFrameworks/apps/myApps/Magic-Sand/` (the folder name must be `Magic-Sand` so the generated exe is `Magic-Sand.exe`). The CI recipe in `.github/workflows/build.yml` is the source of truth for addon pins and Kinect v2 flags.

---

## Step 2: Install OpenFrameworks

1. Download from [openframeworks.cc/download](https://openframeworks.cc/download/)
2. Extract to a known location (e.g., `C:\openFrameworks` or `%USERPROFILE%\openFrameworks`)
3. DuneBox should live inside the `apps/myApps/` directory:
   ```
   openFrameworks/
   ├── apps/
   │   └── myApps/
   │       └── Magic-Sand/   ← clone DuneBox here (folder name matters)
   ├── addons/
   ├── libs/
   └── ...
   ```

---

## Step 3: Install Required Addons

Some addons ship with OF, others need to be downloaded into `openFrameworks/addons/`:

| Addon | Ships with OF? | Install |
|---|---|---|
| `ofxKinect` | ✅ Yes | Already included |
| `ofxOpenCv` | ✅ Yes | Already included |
| `ofxXmlSettings` | ✅ Yes | Already included |
| `ofxCv` | ❌ No | `git clone https://github.com/kylemcdonald/ofxCv` into `addons/` |
| `ofxDatGui` | ❌ No | `git clone https://github.com/thomwolf/ofxDatGui` into `addons/` (CI pin + OF 0.12 patches: see `build.yml`) |
| `ofxParagraph` | ❌ No | `git clone https://github.com/braitsch/ofxParagraph` into `addons/` |
| `ofxModal` | ❌ No | `git clone https://github.com/braitsch/ofxModal` into `addons/` |
| `ofxKinectForWindows2` | ❌ No | Required for v2. CI clones elliotwoods/ofxKinectForWindows2 and defines `DUNEBOX_USE_KINECT_FOR_WINDOWS2`: see `build.yml` |

```bash
cd C:\openFrameworks\addons\
git clone https://github.com/kylemcdonald/ofxCv
git clone https://github.com/thomwolf/ofxDatGui
git clone https://github.com/braitsch/ofxParagraph
git clone https://github.com/braitsch/ofxModal
```

---

## Step 4: Add WaterSimulation to Build

> **Note:** This repo does **not** commit IDE project files (`Magic-Sand.sln`,
> `Magic-Sand.vcxproj`). They are generated by the OpenFrameworks
> **projectGenerator** (the same tool the CI build uses). Run projectGenerator
> against the `DuneBox/` folder once to generate the platform project, which will
> pick up everything under `src/`: including both the fragment backend
> (`WaterSimulation.cpp/.h`) and the compute-shader backend
> (`ComputeWaterSimulation.cpp/.h`): automatically. Most users should prefer
> **Option A** (the pre-built release / CI artifact) and skip building from source.

The `src/WaterSimulation/` directory needs to be included in the project's build:

### Windows (Visual Studio)
1. Generate/open `Magic-Sand.sln` (via projectGenerator)
2. In Solution Explorer, right-click `src` → Add → Existing Item
3. Add the files under `src/WaterSimulation/` (`WaterSimulation.*` and `ComputeWaterSimulation.*`)

> **Tip:** The projectGenerator will pick up everything under `src/` automatically,
> including both the fragment backend and compute shader backend. Most users should
> prefer **Option A** (the pre-built release).

---

## Step 5: Build

### Windows
1. Open `Magic-Sand.sln` in Visual Studio
2. Set configuration to **x64 Release**
3. Build → Build Solution (Ctrl+Shift+B)

---

## Step 6: First Run

1. **Connect a Kinect v2** to a true USB 3.0 port (powered Xbox One adapter required)
2. **Install Kinect for Windows Runtime 2.0** if `Kinect20.dll` is missing:
   https://www.microsoft.com/download/details.aspx?id=44559
   Committed settings are `<kinectVersion>2</kinectVersion>`. Do **not** run Zadig on a v2.
3. **Using Kinect v1 instead?** Set `<kinectVersion>1</kinectVersion>` and bind **libusbK** with Zadig (see [Troubleshooting](06-troubleshooting.md#windows-installing-the-kinect-v1-driver-zadig--libusbk)).
4. **Connect projector** via HDMI
5. **Run DuneBox** (`run.bat` or the **DuneBox (Magic-Sand C++)** shortcut)
6. The application should show the Kinect depth view and topographic mapping

### No Kinect? No problem.
DuneBox includes a **no-Kinect fallback** that generates a procedural sine-wave terrain. The water simulation will run on this test terrain so you can verify the GPU pipeline works.

---

## Step 7: Enable Water Simulation

Press **`w`** to toggle the GPU water simulation on/off.

When enabled:
- Water flows downhill following the sand topography
- Wave your hand above the sand → rain appears at your hand position
- Water accumulates in valleys and flows along channels

### Tuning Parameters

Water simulation parameters are now configured via **`bin/data/settings/waterSettings.xml`** (no recompilation needed). Edit the XML file to adjust:

| Parameter | Default | What it does |
|---|---|---|
| `gravity` | 9.81 | Strength of water flow (higher = faster) |
| `attenuation` | 0.99 | Friction/damping (lower = water slows faster) |
| `theta` | 1.5 | Minmod limiter (1.0–2.0, affects wave sharpness) |
| `epsilon` | 0.01 | Prevents division by zero in dry areas |
| `cellSize` | 1.0 | Physical scale: tune to match your Kinect depth range |

The file is located at `bin/data/settings/waterSettings.xml` and is loaded at startup.

---

## Keyboard Controls

| Key | Action |
|---|---|
| `w` | Toggle water simulation |
| `l` | Toggle lava mode (auto-switches to Volcanic theme) |
| `t` | Cycle color themes (Topo → Ocean → Volcanic → Ice → Alien) |
| `T` | Run real-time test |
| `n` | Toggle day/night cycle |
| `v` | Manual volcano eruption at center |
| `b` | Send ping via inter-app bridge |
| `space` | Start/advance map game |
| `f` / `r` | Start fish game / end map game |
| `1`–`4` | Start boid game difficulty 0–3 |
| `m` | Start seek mother game |
| `c` | Save Kinect color image |
| `d` | Save filtered depth image |

---

## Next Steps

- **[Calibration guide](05-calibration.md)**: align projector and Kinect
- **[Water simulation deep dive](07-water-simulation.md)**: how it works, tuning
- **[Customization](08-customization.md)**: add your own themes and creatures
