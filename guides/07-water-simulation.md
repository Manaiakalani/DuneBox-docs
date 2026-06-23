# 07 — Water Simulation

## Overview

DuneBox's water simulation uses GLSL shaders extracted from [SARndbox](https://github.com/KeckCAVES/SARndbox) (UC Davis) and adapted to run cross-platform via OpenFrameworks. The simulation solves the **shallow-water equations** (Saint-Venant) using **Runge-Kutta 2nd order** time integration on the GPU.

---

## How It Works

### The Physics
The shallow-water equations model water flow as a 2D grid where each cell tracks:
- **w** — water surface height
- **hu** — momentum in x-direction (height × velocity)
- **hv** — momentum in y-direction (height × velocity)

These are stored in an RGB32F texture: `(w, hu, hv)`.

Water flows from high terrain to low terrain. The flow speed depends on the height difference (gravity), and friction gradually slows the water down (attenuation).

### The GPU Pipeline

Each frame, 8 shader passes run in sequence:

```
Kinect depth → [1. Bathymetry Update] → terrain texture
                        ↓
              [2. Slope + Flux + Derivative] → flow rates
                        ↓
              [3. Euler Step (RK2 predictor)] → predicted state
                        ↓
              [4. Slope + Flux + Derivative] → corrected flow rates
                        ↓
              [5. Runge-Kutta Step (corrector)] → final state
                        ↓
              [6. Boundary Enforcement] → dry edges
                        ↓
              [7. Water Add + Update] → rain + evaporation
                        ↓
              [8. Water Rendering] → blue overlay on terrain
```

### Ping-Pong Buffering
The simulation uses two FBOs (framebuffer objects) that alternate each step:
- Read from FBO A → write to FBO B
- Next step: read from FBO B → write to FBO A

This avoids read-write conflicts on the GPU.

---

## Shader Files

Located in `bin/data/shaders/water/adapted/`:

| Shader | Purpose |
|---|---|
| `BathymetryUpdate.frag` | Syncs terrain elevation with Kinect depth |
| `SlopeFluxDeriv.frag` | Computes water flow using Kurganov-Petrova scheme |
| `EulerStep.frag` | RK2 predictor: q* = q + dq·dt |
| `RungeKuttaStep.frag` | RK2 corrector: q_new = (q + q* + dq*·dt) / 2 |
| `Boundary.frag` | Enforces dry boundary at sandbox edges |
| `WaterAdd.frag/vert` | Adds water at rain gesture positions |
| `WaterUpdate.frag` | Applies evaporation/damping |
| `WaterRender.frag/vert` | Renders water as semi-transparent blue overlay |
| `passthrough.vert` | Simple vertex passthrough for fullscreen quads |

Original (unmodified) SARndbox shaders are preserved in `bin/data/shaders/water/` for reference.

---

## Tuning Parameters

| Parameter | Default | Range | Effect |
|---|---|---|---|
| `gravity` | 9.81 | 1.0–20.0 | Higher = water flows faster |
| `attenuation` | 0.99 | 0.9–1.0 | Lower = more friction (water stops sooner) |
| `theta` | 1.5 | 1.0–2.0 | Minmod limiter: 1.0 = smoother, 2.0 = sharper waves |
| `epsilon` | 0.01 | 0.001–0.1 | Prevents division-by-zero in dry cells |
| `cellSize` | 1.0 | 0.1–10.0 | Physical scale factor — tune to match Kinect depth units |

### Tips
- Start with defaults and adjust `cellSize` first — this has the biggest impact on whether water flows realistically
- If water moves too fast, reduce `gravity` or increase `attenuation`
- If water looks "blocky", reduce `theta` toward 1.0
- If shallow water behaves erratically, increase `epsilon`

---

## Rain Gesture

The rain gesture detects hands above the sand surface:

1. The system scans Kinect depth data for pixels significantly above the baseline sand level
2. Any region more than ~50mm above the surface is treated as a "hand"
3. Water is added at the hand's XY position with a configurable radius and rate
4. Remove your hand → rain stops, water flows away naturally

---

## Performance

| GPU | Expected FPS | Notes |
|---|---|---|
| GTX 1060+ | 30–60 FPS | Full speed, smooth water |
| **Quadro P620** | **20–35 FPS** | Solid for most water scenarios |
| Intel UHD 630 | — | Water sim disabled (topology only) |

The water simulation is the most GPU-intensive part of DuneBox. If FPS drops below 15, consider:
- Running fewer simulation steps per frame
- Reducing the simulation grid resolution
- Disabling water and using topology-only mode

---

## Compute Shader Backend (GL 4.3+)

On GPUs that support OpenGL 4.3 or later, DuneBox automatically uses **compute shaders** instead of the fragment shader pipeline. This is detected at startup — if GL 4.3 is unavailable, the original 8-pass fragment shader pipeline is used as a fallback.

### Why Compute Shaders?

Compute shaders replace the 8 fragment passes with **5 compute dispatches**:

| Fragment Pipeline (GL 3.3) | Compute Pipeline (GL 4.3+) |
|---|---|
| 1. BathymetryUpdate.frag | 1. BathymetryUpdate.comp |
| 2. SlopeFluxDeriv.frag | 2. SlopeFluxDeriv.comp *(merged pass)* |
| 3. EulerStep.frag | 3. EulerStep.comp |
| 4. SlopeFluxDeriv.frag (repeat) | 4. RungeKuttaStep.comp |
| 5. RungeKuttaStep.frag | 5. WaterAddUpdate.comp *(merged pass)* |
| 6. Boundary.frag | |
| 7. WaterAdd.frag + WaterUpdate.frag | |
| 8. WaterRender.frag | |

The key optimization is **shared memory** — slope calculation, flux computation, and derivative estimation are merged into a single dispatch because neighboring workgroup threads can share intermediate results via `shared` memory instead of writing to a texture and reading it back.

### Workgroup Layout

All compute shaders use 16×16 workgroups:

```glsl
layout(local_size_x = 16, local_size_y = 16) in;
```

This maps well to typical GPU warp/wavefront sizes (256 threads per workgroup).

### In-Place Updates

Compute shaders use `imageLoad()` / `imageStore()` for direct read-write access to textures, eliminating the need for ping-pong FBOs in most passes. Barrier synchronization (`memoryBarrierImage()`) ensures correct ordering.

### Compute Shader Files

Located in `bin/data/shaders/water/compute/`:

| Shader | Purpose |
|---|---|
| `BathymetryUpdate.comp` | Syncs terrain with Kinect depth |
| `SlopeFluxDeriv.comp` | Merged slope + flux + derivative via shared memory |
| `EulerStep.comp` | RK2 predictor step |
| `RungeKuttaStep.comp` | RK2 corrector + boundary enforcement |
| `WaterAddUpdate.comp` | Rain addition + evaporation/damping in one pass |

---

## Lava Simulation

DuneBox supports a **lava mode** that reuses the same shallow-water physics engine with different parameters to simulate viscous lava flow.

### Parameter Differences

| Parameter | Water | Lava |
|---|---|---|
| Attenuation | 0.99 (low friction) | 0.85 (viscous, slows quickly) |
| Opacity | 5.0 | 8.0 (denser, more opaque) |
| Color | Blue, depth-based transparency | Orange-yellow (shallow) → deep red → black crust (cooling) |

### Controls

- **`l` key** — toggles lava mode on/off
- Activating lava mode automatically switches the color theme to **Volcanic**

### Dual-Fluid Simulation (Compute Backend Only)

When using the compute shader backend, DuneBox supports **water and lava simultaneously** on the same terrain. The two fluids are tracked in separate texture layers and rendered with distinct colors. Lava meeting water produces steam particle effects.

---

## Configuration — `waterSettings.xml`

Water simulation parameters are stored in an XML settings file that persists across sessions.

### File Location

```
bin/data/settings/waterSettings.xml
```

### Parameters

| XML Element | Type | Description |
|---|---|---|
| `gravity` | float | Gravitational acceleration (default: 9.81) |
| `attenuation` | float | Friction/damping factor (default: 0.99) |
| `theta` | float | Minmod limiter parameter (default: 1.5) |
| `epsilon` | float | Dry-cell threshold (default: 0.01) |
| `cellSize` | float | Physical scale factor (default: 1.0) |
| `waterOpacity` | float | Rendering opacity (default: 5.0) |
| `fixedDt` | float | Fixed timestep for simulation stability |
| `maxStepsPerFrame` | int | Cap on simulation steps per render frame |
| `enabled` | bool | Whether water simulation is active |
| `lavaMode` | bool | Whether lava mode is active |

### Behavior

- **Loaded at startup** — the app reads this file on launch and applies all values
- **Saved on exit** — any changes made during a session (via UI or keyboard) are written back
- **Manual editing** — you can edit this file with a text editor to fine-tune parameters without recompiling; changes take effect on next launch

---

## Technical Details

For the full shader analysis (uniforms, textures, pipeline), see:
- `bin/data/shaders/water/SHADER_ANALYSIS.md` (in the DuneBox repo)
- `docs/RENDER_PIPELINE_ANALYSIS.md` (in the DuneBox repo)
