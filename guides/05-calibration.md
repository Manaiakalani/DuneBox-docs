# 05 — Calibration

## Overview

Calibration aligns the projector's output with the Kinect's depth view so that colors and contour lines appear in the right place on the sand. Both DuneBox and sandcam have their own calibration methods.

---

## DuneBox Calibration (Auto-Chessboard)

DuneBox uses **automatic chessboard calibration** — much easier than the manual SARndbox method.

### What You Need
- Flat sand surface
- Kinect and projector both connected and running

DuneBox **projects** the chessboard — you do not print a board.

### Steps

1. **Flatten the sand** — make it as level as possible
2. **Open the GUI `Calibration` folder** and click **"Automatically calibrate kinect & projector"**
3. DuneBox **projects a chessboard pattern** onto the sand
4. The Kinect **sees the projected pattern** and computes the transform
5. Calibration is saved to `bin/data/settings/calibration.xml`

### If Calibration Fails
- Ensure the sand is flat (bumps distort the pattern)
- Reduce ambient light (interferes with pattern detection)
- Check that the projector is in focus across the entire surface
- Make sure nothing shadows the sand (hands, frame, cables)

---

## sandcam Calibration

sandcam does **not** have a projector-chessboard calibrator.

- **Depth range (Kinect v2 SDK):** press **`A`** over flat sand. This writes `min_depth_mm` / `max_depth_mm`.
- **Webcam ArUco overlay:** enable vision in the sidebar and show corner tags **100 / 101 / 102 / 103** (files in `calibration/`: TL, TR, BR, BL). That warps toy markers onto the heightfield; it does not align the projector.

---

## Physical Alignment Checklist

Before software calibration, ensure the physical setup is correct:

### Kinect
- [ ] Centered directly above the sandbox
- [ ] Pointing straight down (perpendicular to sand)
- [ ] ~40" (1m) above sand surface
- [ ] Level (use a bubble level on the Kinect body)
- [ ] Firmly mounted — no wobble

### Projector
- [ ] Image fully covers the sand surface
- [ ] Minimal overshoot past the sandbox edges
- [ ] In focus across the entire surface (center AND corners)
- [ ] No shadows from Kinect, frame, or cables
- [ ] Firmly mounted — calibration breaks if it moves

### Common Calibration Issues

| Problem | Cause | Fix |
|---|---|---|
| Colors shifted to one side | Projector or Kinect not centered | Re-center and recalibrate |
| Contours wavy/distorted | Projector out of focus | Refocus, especially corners |
| Calibration won't complete | Ambient light too bright | Dim the room, close blinds |
| Drift after some time | Frame flex or thermal expansion | Tighten frame, recalibrate after warm-up |
| Different at edges vs center | Projector keystoning | Use projector's keystone correction, then recalibrate |

---

## Recalibration

You need to recalibrate when:
- The projector or Kinect is bumped or moved
- You change the projector's zoom or focus
- You change the Kinect's height
- The frame is disassembled and reassembled

You do NOT need to recalibrate when:
- The sand surface changes (that's the whole point!)
- The PC is restarted (calibration is saved to disk)
- You switch between games or enable/disable water
