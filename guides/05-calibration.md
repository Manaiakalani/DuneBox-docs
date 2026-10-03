# 05 — Calibration

## Overview

Calibration aligns the projector's output with the Kinect's depth view so that colors and contour lines appear in the right place on the sand. Both DuneBox and sandcam have their own calibration methods.

---

## DuneBox (C++) calibration

DuneBox (C++) calibrates itself by projecting a chessboard and watching it with the depth camera, which is much easier than the manual SARndbox method. You do not print a board.

### What you need

- Sand raked flat and level
- Depth camera and projector connected, DuneBox (C++) running
- The room dimmed, and hands, cables and the frame out of the projector's path

### Walkthrough

The **Calibration** panel sits at the top of the settings on the right of the DuneBox (C++) window. The **Status** panel bottom left tells you which step is missing.

1. **Check the depth camera.** Status should read *Depth camera: connected*. If it says *not found*, check USB and power before going further.
2. **Draw the sand region.** Select **1. Draw the sand region**, then drag a rectangle over the sand in the depth view. Skip this if Status already reads *Sand region: set*.
3. **Flatten the sand.** Rake it level; bumps distort the pattern.
4. **Calibrate the projector.** Select **2. Calibrate projector** and follow the prompts. DuneBox projects a chessboard, the depth camera finds it, and the result is saved to `bin/data/settings/calibration.xml`.
5. **Start.** Press ++space++ or select **Start sandbox**. Status reads *Sandbox: Running* and the topographic map appears on the sand.

Turn on **Outline region on sand** to see the sand region projected as a check. If the map lands slightly off the box, **Refit region to calibration** tightens the region to the calibrated area.

!!! tip "From the dashboard"
    With sandcam running too, the web dashboard's DuneBox (C++) group shows whether the C++ app is in setup or running, and its **Start** button does the same as ++space++.

### If Calibration Fails
- Ensure the sand is flat (bumps distort the pattern)
- Reduce ambient light (interferes with pattern detection)
- Check that the projector is in focus across the entire surface
- Make sure nothing shadows the sand (hands, frame, cables)

---

## sandcam (Python) calibration

sandcam does not have a projector chessboard calibrator. It has two simpler steps.

- **Depth range (Kinect v2 SDK).** Flatten the sand, keep hands clear, then press ++a++, select **Auto-calibrate depth** at the top of the sidebar (++tab++), or select **Calibrate depth** in the dashboard's Setup group. This writes `min_depth_mm` and `max_depth_mm`. Fine-tune with the **Min** and **Max** sliders under Calibration in the sidebar.
- **Webcam ArUco overlay.** Turn on **Webcam vision** in the sidebar, select **Calibrate projector**, and show corner tags **100, 101, 102 and 103** (files in `calibration/`: top left, top right, bottom right, bottom left). This maps toy markers onto the heightfield; it does not align the projector.

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
