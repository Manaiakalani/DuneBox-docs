# 03 — Software Setup: DuneBox (C++ / OpenFrameworks)

## Overview

DuneBox is the primary AR sandbox application. It runs on Windows, macOS, or Linux using OpenFrameworks. This guide walks through getting it built and running.

**Repo**: [Manaiakalani/DuneBox](https://github.com/Manaiakalani/DuneBox)

---

## Features

DuneBox now includes:

- **GPU water simulation** — fragment shader and compute shader backends
- **Lava simulation mode** — auto-switches to Volcanic theme
- **5 color themes** — Topo, Ocean, Volcanic, Ice Age, Alien (cycle with `t`)
- **Day/night cycle** — animated lighting with sun/moon transitions
- **Volcano eruption** — manual trigger at center of sandbox
- **Startup diagnostics** — GPU, Kinect, and shader checks on launch
- **Inter-app bridge** — WebSocket link to DuneBox-sandcam
- **Kinect v1/v2/Azure Kinect** — all three sensor generations supported
- **XML-configurable water** — tune water physics via `data/waterSettings.xml`
- **Map & boid games** — interactive educational game modes

---

## Option A: Pre-Built Release (Recommended — no coding needed)

On Windows, just run the setup script or double-click `run.bat`:

```powershell
# Run from elevated PowerShell on your sandbox PC
cd DuneBox-docs\scripts
.\setup-windows.ps1
```

The script downloads the pre-built `.exe`, installs dependencies, and creates a desktop shortcut. **No Visual Studio or build tools needed.**

Or clone the repo and double-click `run.bat` — it auto-downloads the latest release.

---

## Option B: Build from Source (for developers)

Only needed if you want to modify the C++ code.

### Prerequisites

| Dependency | Version | Purpose |
|---|---|---|
| OpenFrameworks | 0.12.0 | Application framework |
| Visual Studio 2022 (Windows) | — | C++ compiler |
| Xcode (macOS) | — | C++ compiler |
| make + gcc (Linux) | — | C++ compiler |

---

## Step 1: Clone the Repo

```bash
git clone https://github.com/Manaiakalani/DuneBox.git
cd DuneBox
```

---

## Step 2: Install OpenFrameworks

1. Download from [openframeworks.cc/download](https://openframeworks.cc/download/)
2. Extract to a known location (e.g., `C:\openFrameworks` or `~/openFrameworks`)
3. DuneBox should live inside the `apps/myApps/` directory:
   ```
   openFrameworks/
   ├── apps/
   │   └── myApps/
   │       └── DuneBox/      ← clone here
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
| `ofxDatGui` | ❌ No | `git clone https://github.com/braitsch/ofxDatGui` into `addons/` |
| `ofxParagraph` | ❌ No | `git clone https://github.com/braitsch/ofxParagraph` into `addons/` |
| `ofxModal` | ❌ No | `git clone https://github.com/braitsch/ofxModal` into `addons/` |

```bash
cd /path/to/openFrameworks/addons/
git clone https://github.com/kylemcdonald/ofxCv
git clone https://github.com/braitsch/ofxDatGui
git clone https://github.com/braitsch/ofxParagraph
git clone https://github.com/braitsch/ofxModal
```

---

## Step 4: Add WaterSimulation to Build

The `src/WaterSimulation/` directory needs to be included in the project's build:

### Windows (Visual Studio)
1. Open `Magic-Sand.sln`
2. In Solution Explorer, right-click `src` → Add → Existing Item
3. Add `src/WaterSimulation/WaterSimulation.h` and `src/WaterSimulation/WaterSimulation.cpp`

### macOS (Xcode)
1. Open `Magic-Sand.xcodeproj`
2. Right-click `src` group → Add Files to "Magic-Sand"
3. Add `src/WaterSimulation/WaterSimulation.h` and `src/WaterSimulation/WaterSimulation.cpp`

### Linux (Makefile)
The Makefile should automatically pick up all `.cpp` files in `src/` subdirectories. If not, add to the Makefile:
```makefile
PROJECT_SOURCES += src/WaterSimulation/WaterSimulation.cpp
```

---

## Step 5: Build

### Windows
1. Open `Magic-Sand.sln` in Visual Studio
2. Set configuration to **x64 Release**
3. Build → Build Solution (Ctrl+Shift+B)

### macOS
1. Open `Magic-Sand.xcodeproj` in Xcode
2. Select scheme "Magic-Sand" → "My Mac"
3. Product → Build (⌘B)

### Linux
```bash
make -j$(nproc)
make run
```

---

## Step 6: First Run

1. **Connect Kinect v1** via USB (with AC power adapter plugged in)
2. **Connect projector** via HDMI
3. **Run DuneBox**
4. The application should show the Kinect depth view and topographic mapping

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

Water simulation parameters are now configured via **`data/waterSettings.xml`** (no recompilation needed). Edit the XML file to adjust:

| Parameter | Default | What it does |
|---|---|---|
| `gravity` | 9.81 | Strength of water flow (higher = faster) |
| `attenuation` | 0.99 | Friction/damping (lower = water slows faster) |
| `theta` | 1.5 | Minmod limiter (1.0–2.0, affects wave sharpness) |
| `epsilon` | 0.01 | Prevents division by zero in dry areas |
| `cellSize` | 1.0 | Physical scale — tune to match your Kinect depth range |

The file is located at `DuneBox/data/waterSettings.xml` and is loaded at startup.

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

- **[Calibration guide](05-calibration.md)** — align projector and Kinect
- **[Water simulation deep dive](07-water-simulation.md)** — how it works, tuning
- **[Customization](08-customization.md)** — add your own themes and creatures
