# 04 — Software Setup: DuneBox-sandcam (Python)

## Overview

DuneBox-sandcam is the hackable Python companion to DuneBox. It's ideal for rapid prototyping, custom creatures, ArUco marker experiments, and testing without dedicated hardware.

**Repo**: [Manaiakalani/DuneBox-sandcam](https://github.com/Manaiakalani/DuneBox-sandcam)

---

## Prerequisites

| Dependency | Version | Purpose |
|---|---|---|
| Python | 3.10+ | Runtime |
| uv | latest | Package manager |
| Kinect v1 + AC adapter | — | Depth camera (optional — has mouse simulator) |

---

## Step 1: Clone the Repo

```bash
git clone https://github.com/Manaiakalani/DuneBox-sandcam.git
cd DuneBox-sandcam
```

---

## Step 2: Install Dependencies

```bash
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

### Windows Note
sandcam ships with pre-compiled `freenect.dll` and `libusb-1.0.dll` — no C compilation needed on Windows.

### macOS Note
```bash
brew install libfreenect
```

### Linux Note
```bash
sudo apt install freenect libfreenect-dev
```

---

## Step 3: Run

```bash
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

Events are defined in `interaction_engine.py`:
- Volcano toy → eruption animation
- Dinosaur toy → prehistoric biome overlay
- Boat toy → water current visualization
- Tree toy → forest growth animation

### AI Guide (Optional)
Enable the AI guide in settings for interactive narration. The guide describes terrain features and teaches geography concepts. See `ai_guide.py`.

---

## Configuration

Edit `sandcam-settings.json`:

```json
{
  "display": "auto",
  "fullscreen": true,
  "kinect_enabled": true,
  "creatures_enabled": true,
  "webcam_enabled": false,
  "ai_guide_enabled": false
}
```

---

## Next Steps

- **[Calibration guide](05-calibration.md)** — aligning projector and Kinect
- **[Customization guide](08-customization.md)** — adding themes and creatures
- Set up the webcam for ArUco detection → `webcam_observer.py`
