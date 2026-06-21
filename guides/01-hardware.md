# 01 — Hardware Guide

## Overview

DuneBox needs four things: a **depth camera** (Kinect), a **projector**, a **computer**, and a **sandbox**. You likely already own the first three.

---

## Kinect Depth Camera

| Model | DuneBox Support | sandcam Support | Notes |
|---|---|---|---|
| **Kinect v1 (Xbox 360)** | ✅ Native | ✅ Native | ⭐ Best supported. Models 1414 & 1473 both work. |
| **Kinect v2 (Xbox One)** | ✅ Supported (v0.2.0+) | ✅ Supported | Set `kinectVersion=2` in config. Requires Kinect for Windows Runtime/SDK 2.0, USB 3.0, and Xbox One Kinect adapter ($30–80 eBay). Depth: 512×424. |
| **Azure Kinect DK** | ✅ Supported | ✅ Supported | USB-C. Set `kinectVersion=3`. Requires Azure Kinect SDK. |

### Recommendation
**Start with Kinect v1.** It has universal support, costs $20–60 used, and needs only USB 2.0. Upgrade to v2 or Azure DK later as a stretch goal.

### Kinect v1 Power
The Xbox 360 Kinect **requires its AC power adapter** for PC use — it doesn't run on USB bus power alone. The adapter splits into:
- USB-A data cable → PC
- DC barrel connector → wall outlet

Make sure you have this adapter. They're available on eBay/Amazon for ~$10.

### Kinect v1 on Windows — driver required
Windows has no built-in driver for the Xbox 360 Kinect. Before DuneBox can see
it, bind the **libusbK** driver to the three Kinect interfaces using **Zadig**
(a one-time ~2-minute step). See the
**[Troubleshooting guide](06-troubleshooting.md#windows-installing-the-kinect-v1-driver-zadig--libusbk)**
for the exact steps.

---

## Projector

| Spec | Recommendation | Why |
|---|---|---|
| **Throw** | Short-throw | Must project downward from above the sandbox |
| **Resolution** | XGA (1024×768) or higher | Kinect v1 depth is only 640×480 — XGA is plenty |
| **Aspect ratio** | 4:3 | Matches Kinect field of view and sandbox shape |
| **Connection** | HDMI or DisplayPort | ⚠️ **No VGA** — analog causes pixel misalignment |
| **Brightness** | 2000+ ANSI lumens | Indoor use; brighter is better for ambient light |
| **Reference model** | BenQ MX631ST | ~$300–550, the UC Davis recommended model |

### Projector Mounting
- Mount above the **rear long edge** of the sandbox (not center — projectors project above their centerline)
- Aim downward at the sand surface
- Must be rigidly mounted — any wobble ruins calibration

---

## Computer

### PC Compatibility Matrix

#### 🥇 Lenovo ThinkCentre M720Q + Quadro P620 (RECOMMENDED)

| Spec | Detail |
|---|---|
| CPU | i5-8400T/8500T (6-core, 3.3–3.5 GHz boost) |
| GPU | Nvidia Quadro P620 (Pascal, 512 CUDA cores, 2GB GDDR5) |
| RAM | 8GB DDR4 |
| Ports | 6× USB-A, 1× USB-C, HDMI, DP, 4× Mini-DP (on P620) |
| DuneBox | ✅ 60 FPS |
| sandcam | ✅ 60 FPS |
| Water simulation | ✅ Solid ~20–35 FPS. P620 = ~30% of GTX 1060. |
| Linux | ✅ Trivial install, no Optimus issues |

**Why #1**: Only machine that can run ALL software including GPU water sim. Desktop = easy Linux. Plenty of USB ports.

> ⚠️ **PSU note**: The stock 65W PSU is tight with the P620's 40W draw. Upgrade to the 90W PSU option Lenovo offers.

#### 🥈 Lenovo ThinkCentre M720Q (Intel UHD 630 only)

Same as above but without the Quadro P620. Great for DuneBox and sandcam at 60 FPS. No water simulation (Intel IGP can't handle it).

#### 🥉 Surface Laptop 2

Works for DuneBox/sandcam on Windows. Limitations:
- Only 1× USB-A port (Kinect takes it — need Bluetooth peripherals)
- No discrete GPU → no water simulation
- Linux requires patched `linux-surface` kernel

#### 🔴 Surface Pro 5th Gen

Least suitable. Dual-core CPU, thermal throttling, 1 USB-A port. OK for casual sandcam use only.

### Minimum Specs (any PC)

| Spec | DuneBox (Magic-Sand) | sandcam | Water simulation |
|---|---|---|---|
| CPU | x86 quad-core, 2GHz+ | Any modern CPU | x86, 3GHz+ |
| GPU | Integrated OK | None needed | **Nvidia GTX 1060+** (AMD won't work) |
| RAM | 4GB | 4GB | 4GB |
| USB | 2.0 (Kinect v1) | 2.0 (Kinect v1) | 2.0 (Kinect v1) |
| Video out | HDMI/DP (no VGA) | HDMI/DP | HDMI/DP |
| OS | Windows/macOS/Linux | Windows/macOS/Linux | **Linux only** (for native SARndbox) |

### GPU Comparison

| GPU | CUDA Cores | GFLOPS | Water Sim? |
|---|---|---|---|
| GTX 1060 (official minimum) | 1,280 | ~4,095 | ✅ Target spec |
| **Quadro P620** | **512** | **~1,386** | **✅ Solid ~20–35 FPS** |
| Intel UHD 630 | — | ~440 | ❌ Topology only |

---

## Cables & Adapters

| Cable | Why | Notes |
|---|---|---|
| HDMI 2.0, 10–15 ft | PC → projector | No VGA! |
| Active USB 2.0 extension, 10–15 ft | PC → Kinect at top of frame | Must be active (powered) for reliable data |
| Mini-DP → HDMI adapter | If using Quadro P620's Mini-DP output | ~$8 |
| Kinect AC adapter | Power for Kinect v1 on PC | Included with Kinect, or ~$10 on eBay |
