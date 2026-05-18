# 09 — Kinect v2 & Azure Kinect DK Upgrades

## Overview

DuneBox starts with Kinect v1 (Xbox 360) which has universal support. This guide covers upgrading to Kinect v2 (Xbox One) or Azure Kinect DK as stretch goals.

---

## Kinect Comparison

| Feature | Kinect v1 (Xbox 360) | Kinect v2 (Xbox One) | Azure Kinect DK |
|---|---|---|---|
| Depth resolution | 640×480 | 512×424 | 640×576 (NFOV) |
| Depth range | 0.4–4.0m | 0.5–4.5m | 0.25–5.46m |
| Field of view | 57°×43° | 70°×60° | 75°×65° (NFOV) |
| USB | 2.0 | 3.0 required | 3.0 (USB-C) |
| PC adapter needed | No | Yes (~$30–80) | No |
| DuneBox support | ✅ Native | ⚠️ Code mod needed | ⚠️ Experimental |
| sandcam support | ✅ Native | ❌ Not supported | ❌ Not supported |
| Price (used) | $20–60 | $60–120 + adapter | $200–400 |

---

## Kinect v2 Upgrade (DuneBox)

### What Needs to Change
DuneBox uses `ofxKinect` (which wraps libfreenect for Kinect v1). For Kinect v2, you need to swap this for a Kinect v2 addon.

### Options

#### Option A: ofxKinectV2 (Linux/macOS)
- Uses `libfreenect2` (open-source Kinect v2 driver)
- Works on Linux and macOS
- Repo: [ofTheo/ofxKinectV2](https://github.com/ofTheo/ofxKinectV2)

#### Option B: ofxKinectForWindows2 (Windows only)
- Uses Microsoft's official Kinect SDK 2.0
- Windows only
- Repo: [elliotwoods/ofxKinectForWindows2](https://github.com/elliotwoods/ofxKinectForWindows2)

### Code Changes Required

1. Replace `#include "ofxKinect.h"` with the new addon's header
2. Update `KinectProjector.cpp` to use the new API:
   - Depth texture accessor may differ
   - Resolution changes from 640×480 to 512×424
   - Coordinate system may differ
3. Update the calibration system for the new field of view
4. Test depth data scaling (Kinect v2 uses millimeters; v1 uses a 11-bit raw value)

### Hardware Requirements
- **USB 3.0** port (Kinect v2 won't work on USB 2.0)
- **Xbox One Kinect Adapter** for PC connection (~$30–80 on eBay)
- On Windows: install Kinect for Windows SDK 2.0

---

## Azure Kinect DK Upgrade (DuneBox)

### Status: Experimental — No Community Precedent

No AR sandbox project has successfully used the Azure Kinect DK. This would be greenfield work.

### What Would Be Needed

1. **OpenFrameworks addon**: [ofxAzureKinect](https://github.com/prisonerjohn/ofxAzureKinect)
2. **Azure Kinect SDK** (k4a): [Microsoft/Azure-Kinect-Sensor-SDK](https://github.com/microsoft/Azure-Kinect-Sensor-SDK)
3. Same code changes as Kinect v2 (swap depth source, update resolution, recalibrate)

### Advantages of Azure Kinect DK
- Higher depth resolution (640×576 NFOV)
- Better depth accuracy (±2mm vs ±10mm for v1)
- Wider field of view
- USB-C (no adapter needed)
- Better in bright ambient light

### Disadvantages
- More expensive ($200–400 used, discontinued by Microsoft in 2023)
- Requires Azure Kinect SDK (additional dependency)
- No community support for sandbox use
- SDK is Windows and Linux only (no macOS)

---

## sandcam Kinect Upgrades

sandcam currently only supports Kinect v1 via libfreenect. Adding Kinect v2 or Azure DK would require:

1. Modifying `depth_source.py` to support alternative depth backends
2. Using `pylibfreenect2` (Python bindings for libfreenect2) for Kinect v2
3. Using `pyk4a` (Python bindings for Azure Kinect SDK) for Azure DK
4. Handling the different depth resolutions and coordinate systems

This is simpler than the C++ changes since Python libraries exist for all three Kinect models.

---

## Recommendation

1. **Start with Kinect v1** — get everything working and calibrated first
2. **Kinect v2 next** — better FOV, only needs an addon swap in DuneBox
3. **Azure DK last** — most capable but least supported, save for when everything else works
