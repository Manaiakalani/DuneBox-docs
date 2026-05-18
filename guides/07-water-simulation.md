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
| **Quadro P400** | **10–20 FPS** | Functional but slow on complex flows |
| Intel UHD 630 | — | Water sim disabled (topology only) |

The water simulation is the most GPU-intensive part of DuneBox. If FPS drops below 15, consider:
- Running fewer simulation steps per frame
- Reducing the simulation grid resolution
- Disabling water and using topology-only mode

---

## Technical Details

For the full shader analysis (uniforms, textures, pipeline), see:
- `bin/data/shaders/water/SHADER_ANALYSIS.md` (1,250 lines)
- `docs/RENDER_PIPELINE_ANALYSIS.md`
