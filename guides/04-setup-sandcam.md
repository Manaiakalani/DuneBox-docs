# 04 — Software Setup: DuneBox-sandcam (Python)

## Overview

DuneBox-sandcam is the hackable Python companion to DuneBox. It's ideal for rapid prototyping, custom creatures, ArUco marker experiments, and testing without dedicated hardware.

**Repo**: [Manaiakalani/DuneBox-sandcam](https://github.com/Manaiakalani/DuneBox-sandcam)

---

## Prerequisites

| Dependency | Version | Purpose |
|---|---|---|
| Python | 3.11+ | Runtime |
| uv | latest | Package manager |
| Kinect v1 + AC adapter | — | Depth camera (optional — has mouse simulator) |
| websockets | — | Depth streaming server (installed by `uv sync`) |

### Optional Extras

```bash
# GeoTIFF / DEM loading support
uv sync --extra geo

# Extra sensor backends (Kinect v2, Azure Kinect, RealSense)
uv sync --extra all-sensors
```

---

## Step 1: Clone the Repo

```powershell
git clone https://github.com/Manaiakalani/DuneBox-sandcam.git
cd DuneBox-sandcam
```

---

## Step 2: Install Dependencies

```powershell
# Install uv if you don't have it
pip install uv

# Sync dependencies (creates .venv automatically)
uv sync
```

This installs:
- `pygame` — 60 FPS display + multi-display
- `numpy` / `scipy` — array computation
- `opencv-contrib-python` — ArUco marker detection
- `libfreenect` bindings (ctypes wrapper)
- `websockets` — depth streaming server + inter-app bridge

### Windows Note
sandcam ships with pre-compiled `freenect.dll` and `libusb-1.0.dll` — no C compilation needed on Windows.

---

## Step 3: Run

```powershell
uv run python main.py
```

### No Kinect Connected?
sandcam automatically enters **mouse simulator mode**:
- Move your mouse to simulate terrain changes
- Full UI and creature system works
- Great for development and testing

### With Kinect Connected
- Kinect v1 depth data drives the terrain in real-time
- Make sure the AC adapter is plugged in (Kinect v1 won't work on USB power alone)

---

## Step 4: Multi-Display Setup

For projector output, sandcam supports a **separate display window**:

1. Connect projector as a second display
2. In the sandcam UI, select the projector display from the display picker
3. The projector shows the clean sand visualization; your monitor shows the control UI

---

## Features to Explore

### Biome-Aware Creatures
Animals appear contextually based on terrain elevation:
- Deep water → fish, sharks
- Shallow water → crabs, turtles
- Beach → seagulls
- Grassland → rabbits, deer
- Mountains → goats, eagles

Creature definitions are in `creatures.py` — easy to add your own!

### ArUco Marker Triggers
1. Print ArUco markers (OpenCV ArUco dictionary)
2. Attach markers to physical toys (dinosaurs, boats, houses, etc.)
3. Place a marked toy on the sand → the webcam detects it → triggers a themed event

Printed 4×4 tags live in `calibration/` (dictionary **DICT_4X4_250**):

| IDs | Role |
|---|---|
| 1–5 | Toys: boat, dino, house, tree, volcano (guide + ripples) |
| 10–13 | Dinosaur spawn / extinction |
| 20 / 21 | Place volcano / trigger nearest volcano |
| 100 / 101 / 102 / 103 | Corners: TL / TR / BR / BL |

### AI Guide (Optional)
Enable the AI guide in settings for interactive narration. The guide describes terrain features and teaches geography concepts. See `ai_guide.py`.

---

## New Features

DuneBox-sandcam has gained 16 major features since the initial release:

- **Sound effects** — ambient audio reacts to terrain and weather
- **Dinosaurs** — prehistoric creature set alongside modern animals
- **Volcanoes** — place and trigger volcanic eruptions
- **Earthquakes** — manual earthquake trigger shakes the terrain
- **Ecosystem simulation** — food chains, predator/prey dynamics
- **Game modes** — Build a Dam, Volcano Defense, Watershed Puzzle, Biome Sculpt
- **Day/night cycle** — animated lighting with adjustable speed
- **Sensor abstraction** — Kinect v1/v2, Azure Kinect, RealSense via config
- **Web dashboard** — browser-based depth viewer and controls
- **Inter-app bridge** — TCP link to DuneBox (C++) on `localhost:9876`
- **Contour lines** — togglable topographic contour overlay
- **Terrain snapshots** — `F5` saves the current heightfield
- **Creature set cycling** — Modern, Prehistoric, All, or None
- **Settings sidebar** — in-app settings panel (Tab key)
- **WebSocket depth server** — stream depth data to browsers

---

## Keyboard Controls

| Key | Action |
|---|---|
| `A` | Auto-calibrate Kinect v2 depth range from the flat sand |
| `C` | Toggle contour lines |
| `G` | Toggle creatures |
| `V` | Cycle creature sets (Modern → Prehistoric → All → None) |
| `F5` | Save terrain snapshot |
| `E` | Toggle ecosystem simulation |
| `N` | Toggle day/night cycle |
| `+` / `-` | Speed up / slow down day/night |
| `P` | Pause day/night cycle |
| `S` | Toggle sound mute |
| `O` | Toggle volcano click-to-place |
| `K` | Manual earthquake trigger |
| `U` | Toggle WebSocket depth server (`ws://127.0.0.1:8765`) |
| `B` | Toggle inter-app bridge |
| `F1` | Game: Build a Dam |
| `F2` | Game: Volcano Defense |
| `F3` | Game: Watershed Puzzle |
| `F4` | Game: Biome Sculpt |
| `Esc` | End current game |
| `Tab` | Settings sidebar |
| `R` | Reset terrain (simulator mode) |
| `Q` | Quit |

---

## Web Dashboard

When the WebSocket depth server is enabled (press `U`), it listens on **`ws://127.0.0.1:8765`** (localhost only). There is no HTTP server on that port.

Open `DuneBox-sandcam/web/index.html` in a browser (or serve that folder with any static file server). The page connects to the WebSocket.

The dashboard provides:
- Live depth data visualization
- Terrain statistics and heatmap
- Remote control of sandbox settings

---

## Sensor Configuration

sandcam supports multiple depth sensors via the `sensor_type` field in `sandcam-settings.json`:

```json
{
  "sensor_type": "kinect_v1"
}
```

Supported values:
| Value | Sensor |
|---|---|
| `kinect_v1` | Microsoft Kinect v1 (Xbox 360) |
| `kinect_v2` | Microsoft Kinect v2 (Xbox One) via libfreenect |
| `kinect_v2_sdk` | Microsoft Kinect v2 via Kinect SDK 2.0 |
| `orbbec` | Orbbec depth camera |
| `realsense` | Intel RealSense (requires `--extra all-sensors`) |
| `mouse_simulator` | Mouse-driven simulator (default when no sensor found) |
| `dummy` | No-op dummy sensor for testing |

---

## Configuration

Edit `sandcam-settings.json`:

```json
{
  "sensor_type": "kinect_v1",
  "sensor_fallback": "mouse_simulator",
  "fullscreen": false,
  "display_index": 0,
  "show_creatures": true,
  "vision_enabled": false,
  "ai_enabled": false,
  "guide_enabled": true
}
```

Unknown keys are ignored. Copy `sandcam-settings.example.json` for the full portable default set. After mounting a Kinect v2, press **`A`** to auto-calibrate `min_depth_mm` / `max_depth_mm`.

---

## Next Steps

- **[Calibration guide](05-calibration.md)** — aligning projector and Kinect
- **[Customization guide](08-customization.md)** — adding themes and creatures
- Set up the webcam for ArUco detection → `webcam_observer.py`
