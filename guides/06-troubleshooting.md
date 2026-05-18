# 06 — Troubleshooting

## Common Problems & Solutions

---

### Kinect Issues

#### Kinect not detected / "Failed to initialize streaming mode"
- **Check USB**: Plug directly into motherboard USB port — **no USB hubs**
- **Check power**: Kinect v1 requires its AC power adapter; USB alone won't work
- **Check driver**: On Linux, run `lsusb` — should show "Microsoft Corp. Xbox NUI Camera"
- **Windows**: May need to plug/unplug Kinect several times (known Windows 10 issue)
- **Permissions (Linux)**: Add udev rules for Kinect:
  ```bash
  sudo cp /path/to/openFrameworks/addons/ofxKinect/scripts/51-kinect.rules /etc/udev/rules.d/
  sudo udevadm control --reload-rules
  ```

#### Kinect depth image is noisy or flickering
- Reduce ambient infrared light (sunlight, halogen lamps interfere with Kinect's IR projector)
- Ensure Kinect is perpendicular to sand — angled views reduce depth accuracy
- Check that nothing reflective is in the sandbox (metal, glass, shiny objects)

---

### Projector Issues

#### Colors are shifted / misaligned
- **Recalibrate** (press `c` in DuneBox)
- Check that projector hasn't moved since last calibration
- Ensure HDMI connection (VGA causes pixel misalignment)

#### Image doesn't cover full sandbox
- Adjust projector zoom and position
- Move projector closer (short-throw) or farther (long-throw)
- Sandbox must be 4:3 aspect ratio to match Kinect FOV

---

### Water Simulation Issues

#### "Water2Water shader" error / shader compilation failure
- **GPU required**: Water sim needs a discrete Nvidia GPU. Intel integrated graphics will show shader errors.
- **Check OpenGL version**: DuneBox needs OpenGL 3.2+. Run `glxinfo | grep "OpenGL version"` on Linux.
- On macOS, OpenGL 3.2 core profile is the default — should work.

#### Water simulation is very slow / laggy
- **Expected on Quadro P620**: ~20–35 FPS for complex water scenes. The P620 has ~30% of the GTX 1060's compute power.
- Reduce sandbox area in settings (smaller simulation grid = faster)
- Close other GPU-intensive applications
- On Linux, ensure you're using the Nvidia proprietary driver, not nouveau

#### Water doesn't flow / sits still
- Check `cellSize` parameter — if too large/small relative to depth values, water won't move
- Check `gravity` — set to 9.81 (standard)
- Ensure the depth texture is actually updating (Kinect must be connected)

#### Water disappears after a few seconds
- `attenuation` may be too low (< 0.95 drains water quickly)
- Set `attenuation` to 0.99 for slow evaporation, 1.0 for no evaporation

---

### Build / Compilation Issues

#### DuneBox won't compile — missing headers
- Ensure DuneBox is inside `openFrameworks/apps/myApps/`
- Ensure all addons are installed in `openFrameworks/addons/`
- Run the OF project generator to regenerate project files

#### "ofxKinect not found"
- ofxKinect ships with OF — check it exists in `openFrameworks/addons/ofxKinect/`
- Make sure `addons.make` lists all required addons

#### sandcam: "No module named freenect"
- **Windows**: The `freenect.dll` should be in the sandcam directory
- **macOS**: `brew install libfreenect`
- **Linux**: `sudo apt install freenect libfreenect-dev`

---

### Performance Issues

#### DuneBox runs below 30 FPS
- Check GPU load — is the water sim enabled? Press `w` to disable and check if FPS improves
- Close other applications
- On laptops: plug in AC power (battery mode throttles GPU)
- Reduce projector resolution in settings

#### sandcam runs below 60 FPS
- sandcam is CPU-bound (no GPU). Close CPU-heavy background tasks.
- Disable creatures or webcam features if not needed
- Check that the Python venv is using the correct Python version (3.10+)

---

### Linux-Specific Issues

#### SARndbox software won't install on Ubuntu 22+
Use the new PullPackage installer (2025+):
```bash
curl https://vroom.library.ucdavis.edu/PullPackage | bash
PullPackage Vrui
PullPackage Kinect
PullPackage SARndbox
```
Or use **Linux Mint 19.3** which the original guide was written for.

#### AMD GPU — water simulation crashes
AMD GPUs are **not supported** for the water simulation. The SARndbox GLSL shaders have known incompatibilities with AMD's Linux Mesa driver. Use an Nvidia GPU with the proprietary driver.

#### Nvidia Optimus laptop — wrong GPU used
Laptops with Nvidia Optimus may default to the Intel IGP instead of the Nvidia GPU. Force the Nvidia GPU:
```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia ./DuneBox
```
Or configure in `nvidia-settings`. Desktop PCs with PCIe GPUs (like the M720Q + Quadro P620) don't have this problem.

---

### Getting Help

- **[r/arsandbox](https://reddit.com/r/arsandbox)** — dedicated subreddit (113 members), maintained by the SARndbox creator
- **[SARndbox FAQ](https://web.cs.ucdavis.edu/~okreylos/ResDev/SARndbox/FAQ.html)** — official FAQ from UC Davis
- **[UC Davis calibration videos](https://www.youtube.com/results?search_query=SARndbox+calibration)** — step-by-step video guides
