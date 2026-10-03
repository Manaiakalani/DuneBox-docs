# 09 — Depth Sensor Support

## Overview

The Windows DuneBox binary defaults to **Kinect v2**. Kinect v1 still works if you set `<kinectVersion>1</kinectVersion>` and install the Zadig/libusbK driver. Azure Kinect, Orbbec Femto and RealSense reach DuneBox (C++) through sandcam: see [Use any sandcam sensor in DuneBox](#use-any-sandcam-sensor-in-dunebox).

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
| DuneBox (C++) | ✅ Native | ✅ ofxKinectForWindows2 (pre-built) | ✅ via sandcam (`kinectVersion=4`) | ✅ via sandcam (`kinectVersion=4`) |
| sandcam (Python) | ✅ Native | ✅ sensor_api.py | ✅ via pyk4a | ✅ via pyorbbecsdk |

---

## Sensor Configuration

### sandcam (Python)

Set the `sensor_type` field in `sandcam-settings.json`:

```json
{
  "sensor_type": "kinect_v1"
}
```

Supported values: `"kinect_v1"`, `"kinect_v2"`, `"kinect_v2_sdk"`, `"orbbec"`, `"realsense"`, `"mouse_simulator"`, `"dummy"`

If no hardware is detected, sandcam **automatically falls back to a mouse simulator** (`"mouse_simulator"` mode) so you can develop and test without a physical sensor.

### DuneBox (C++)

Set `kinectVersion` in `bin/data/settings/kinectProjectorSettings.xml`:

```xml
<kinectVersion>2</kinectVersion>
```

| Value | Sensor | Depth Resolution |
|---|---|---|
| `1` | Kinect v1 | 640×480 |
| `2` | Kinect v2 | 512×424 |
| `3` | Azure Kinect direct — **refused at startup** (use `4`) | — |
| `4` | Any sensor sandcam can read, shared over the network | 640×480 |

**Kinect v2 requirements**: Kinect for Windows Runtime/SDK 2.0 and a true USB 3.0 port.

If no Kinect is connected, DuneBox uses **procedural sine-wave terrain**, not a mouse sculptor (that is sandcam only).

---

## Use any sandcam sensor in DuneBox

sandcam reads more sensors than DuneBox (C++): Azure Kinect, Orbbec Femto, RealSense and Kinect v2 through the SDK. It can share its depth stream so DuneBox uses the same sensor, with no extra drivers in the C++ app.

1. Set up the sensor in sandcam first and check it works (dashboard → **Setup check**).
2. In the sandcam dashboard, turn on **Sensor → Share this sensor with DuneBox**. It is remembered.
3. In DuneBox, set `<kinectVersion>4</kinectVersion>` in `bin/data/settings/kinectProjectorSettings.xml` and start it.
4. The dashboard's **Sensor** hint changes to "DuneBox is receiving depth from this sensor". Calibrate DuneBox as usual.

Only one program can open a sensor at a time, so sandcam must be running whenever DuneBox uses version 4. If sandcam restarts, DuneBox reconnects on its own within a few seconds.

| Sensor in sandcam | Depth | Colour (for calibration) |
|---|---|---|
| Azure Kinect (pyk4a) | ✅ | ✅ aligned to depth |
| RealSense | ✅ | ✅ aligned to depth |
| Orbbec Femto (pyorbbecsdk) | ✅ | ⚠️ approximate. Calibrate with the depth image if the colour view looks offset |
| Kinect v1 / v2 | ✅ | ⚠️ not aligned. Use `kinectVersion` 1 or 2 directly instead |
| Mouse simulator | ✅ | Grey depth image |

Under the hood: sandcam serves 640×480 depth in millimetres on TCP port 9877, on this PC only, plus the sensor's field of view so DuneBox's world coordinates are right. Colour is only sent while DuneBox is calibrating.

---

## Kinect v1 (Xbox 360)

The original and most widely documented sensor for AR sandboxes.

- **DuneBox (C++)**: Native support via `ofxKinect` (wraps libfreenect)
- **sandcam (Python)**: Native support via libfreenect
- **Windows driver required**: Install the **libusbK** driver via **Zadig** (one-time setup — see [Troubleshooting](06-troubleshooting.md#windows-installing-the-kinect-v1-driver-zadig--libusbk))

---

## Kinect v2 (Xbox One)

### DuneBox (C++)

Supported via the **KinectV2Handler** class using **ofxKinectForWindows2** (Microsoft's Kinect SDK 2.0). The pre-built release includes Kinect v2 support out of the box.

### sandcam (Python)

Supported via `sensor_api.py`, which provides a unified interface across all sensor types.

### Hardware Requirements
- **USB 3.0** port (Kinect v2 won't work on USB 2.0)
- **Xbox One Kinect Adapter** for PC connection (~$30–80 on eBay)
- On Windows: install Kinect for Windows SDK 2.0 — [download id=44561](https://www.microsoft.com/en-us/download/details.aspx?id=44561) (includes the runtime, **Configuration Verifier**, Kinect Studio, and samples)

> After installing, the SDK's Configuration Verifier may show two orange `!`
> warnings ("Failed to update configuration definitions" and "Unknown USB 3.0
> port detected"). On modern PCs both are normally benign — see
> [06 — Troubleshooting](06-troubleshooting.md) → *Kinect v2 Configuration
> Verifier shows orange warnings* for what they mean and when to act.

---

## Azure Kinect DK

### DuneBox (C++)

**Through sandcam.** Set `kinectVersion=4` and turn on sensor sharing in sandcam ([how](#use-any-sandcam-sensor-in-dunebox)). Direct support (`kinectVersion=3`) is refused at startup even if you define `DUNEBOX_USE_AZURE_KINECT`; the handler is not wired.

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
- SDK is Windows-only for the DuneBox C++ app

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

**Through sandcam.** Set `kinectVersion=4` and turn on sensor sharing in sandcam ([how](#use-any-sandcam-sensor-in-dunebox)).

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
  "sensor_type": "realsense"
}
```

> **Note**: DuneBox (C++) uses RealSense through sandcam: set `kinectVersion=4` ([how](#use-any-sandcam-sensor-in-dunebox)).

---

## Recommendation

1. **Windows default** — **Kinect v2** (Runtime 2.0 + USB 3.0 adapter)
2. **Budget / v1 box** — **Kinect v1** (`<kinectVersion>1</kinectVersion>` + Zadig/libusbK)
3. **Already own a Kinect v2** — fully supported in both apps
4. **New hardware** — **Orbbec Femto Bolt** in sandcam; DuneBox (C++) shares it with `kinectVersion=4`
5. **Azure Kinect / RealSense** — same as Femto: sandcam reads it, DuneBox shares it
