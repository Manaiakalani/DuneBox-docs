# 09 — Depth Sensor Support

## Overview

DuneBox supports a range of depth sensors across both the C++ and Python applications. Kinect v1 remains the easiest starting point, but all four major sensor families are now fully supported.

---

## Sensor Comparison

| Feature | Kinect v1 (Xbox 360) | Kinect v2 (Xbox One) | Azure Kinect DK | Orbbec Femto Bolt |
|---|---|---|---|---|
| Depth resolution | 640×480 | 512×424 | 640×576 (NFOV) | 640×576 (NFOV) |
| Depth range | 0.4–4.0m | 0.5–4.5m | 0.25–5.46m | 0.25–5.46m |
| Field of view | 57°×43° | 70°×60° | 75°×65° (NFOV) | 75°×65° (NFOV) |
| USB | 2.0 | 3.0 required | 3.0 (USB-C) | 3.0 (USB-C) |
| PC adapter needed | No | Yes (~$30–80) | No | No |
| Price | $20–60 (used) | $60–120 + adapter | $200–400 (used, discontinued) | ~$300 (new) |
| Status | Legacy, widely available | Legacy, still available | Discontinued (2023) | **Actively manufactured (2024+)** |

### Software Support

| Feature | Kinect v1 | Kinect v2 | Azure Kinect | Orbbec Femto Bolt |
|---|---|---|---|---|
| DuneBox (C++) | ✅ Native | ✅ KinectV2Handler | ✅ AzureKinectHandler | ✅ Azure SDK compatible |
| sandcam (Python) | ✅ Native | ✅ sensor_api.py | ✅ via pyk4a | ✅ via pyorbbecsdk |

---

## Sensor Configuration

### sandcam (Python)

Set the `sensor.type` field in `sandcam-settings.json`:

```json
{
  "sensor": {
    "type": "kinect_v1"
  }
}
```

Supported values: `"kinect_v1"`, `"kinect_v2"`, `"orbbec"`, `"realsense"`, `"dummy"`

If no hardware is detected, sandcam **automatically falls back to a mouse simulator** (`"dummy"` mode) so you can develop and test without a physical sensor.

### DuneBox (C++)

Set `kinectVersion` in the config file:

| Value | Sensor |
|---|---|
| `1` | Kinect v1 |
| `2` | Kinect v2 |
| `3` | Azure Kinect / Orbbec Femto Bolt |

Like sandcam, DuneBox falls back to a mouse-based depth simulator if no hardware is detected.

---

## Kinect v1 (Xbox 360)

The original and most widely documented sensor for AR sandboxes.

- **DuneBox (C++)**: Native support via `ofxKinect` (wraps libfreenect)
- **sandcam (Python)**: Native support via libfreenect
- **No extra installation needed** — drivers are included with both apps

---

## Kinect v2 (Xbox One)

### DuneBox (C++)

Supported via the **KinectV2Handler** class, which wraps either:
- **ofxKinectV2** (Linux/macOS) — uses `libfreenect2`
- **ofxKinectForWindows2** (Windows) — uses Microsoft's Kinect SDK 2.0

### sandcam (Python)

Supported via `sensor_api.py`, which provides a unified interface across all sensor types.

### Hardware Requirements
- **USB 3.0** port (Kinect v2 won't work on USB 2.0)
- **Xbox One Kinect Adapter** for PC connection (~$30–80 on eBay)
- On Windows: install Kinect for Windows SDK 2.0

---

## Azure Kinect DK

### DuneBox (C++)

Supported via the **AzureKinectHandler** class using [ofxAzureKinect](https://github.com/prisonerjohn/ofxAzureKinect).

### sandcam (Python)

Supported via `pyk4a` (Python bindings for Azure Kinect SDK):

```bash
uv sync --extra azure
```

### Advantages
- Higher depth resolution (640×576 NFOV)
- Better depth accuracy (±2mm vs ±10mm for v1)
- Wider field of view
- USB-C (no adapter needed)
- Better in bright ambient light

### Disadvantages
- Discontinued by Microsoft in 2023 — only available used ($200–400)
- Requires Azure Kinect SDK (additional dependency)
- SDK is Windows and Linux only (no macOS)

---

## Orbbec Femto Bolt

The **best long-term Kinect replacement**. The Femto Bolt is Azure Kinect SDK compatible and actively manufactured.

### Why Femto Bolt?

- **~$300**, available new from Orbbec
- **Actively manufactured** (2024+) — not discontinued
- **Azure Kinect SDK compatible** — works with the same `k4a` API
- Same depth resolution and field of view as Azure Kinect DK
- USB-C, no adapter needed

### DuneBox (C++)

Works with the same AzureKinectHandler (set `kinectVersion = 3`) since it's Azure SDK compatible.

### sandcam (Python)

Supported via `pyorbbecsdk` or via the Azure SDK compatibility layer:

```bash
# Option 1: Native Orbbec SDK
uv sync --extra orbbec

# Option 2: Azure SDK compatibility
uv sync --extra azure
```

---

## Intel RealSense

Supported in sandcam as an alternative depth sensor family.

### Recommended Models

| Model | Type | Best For |
|---|---|---|
| **L515** | LiDAR | High accuracy, short range — ideal for sandboxes |
| **D435** | Stereo | Wider availability, good general-purpose depth |

### sandcam (Python)

Supported via `pyrealsense2`:

```bash
uv sync --extra realsense
```

Then set sensor type in `sandcam-settings.json`:

```json
{
  "sensor": {
    "type": "realsense"
  }
}
```

> **Note**: Intel RealSense is not currently supported in the C++ DuneBox app.

---

## Recommendation

1. **New builds** — consider the **Orbbec Femto Bolt** (~$300, best long-term availability)
2. **Budget builds** — **Kinect v1** ($20–60 used, most documentation available)
3. **Already own a Kinect v2** — fully supported, just need the USB adapter
4. **Already own an Azure Kinect** — fully supported in both apps
5. **Already own a RealSense** — works with sandcam out of the box
