# 06 — Troubleshooting

## Common Problems & Solutions

---

### Kinect Issues

#### Kinect not detected / "Failed to initialize streaming mode"
- **Check USB**: Plug directly into motherboard USB port — **no USB hubs**
- **Check power**: Kinect v1 requires its AC power adapter; USB alone won't work
- **Check driver**: On Linux, run `lsusb` — should show "Microsoft Corp. Xbox NUI Camera"
- **Windows — install the libusbK driver first** (see below); plug/unplug a few times only helps *after* the driver is in place
- **Permissions (Linux)**: Add udev rules for Kinect:
  ```bash
  sudo cp /path/to/openFrameworks/addons/ofxKinect/scripts/51-kinect.rules /etc/udev/rules.d/
  sudo udevadm control --reload-rules
  ```

#### Windows: installing the Kinect v1 driver (Zadig + libusbK)

DuneBox/ofxKinect talk to the Kinect through **libfreenect**, which on Windows
needs the **libusbK** driver bound to each Kinect interface. Windows does **not**
provide this automatically — without it the Kinect is never detected, no matter
how many times you replug it. This is a one-time setup.

1. Download **Zadig** from [zadig.akeo.ie](https://zadig.akeo.ie) (no install — it's a single `.exe`).
2. Plug in the Kinect v1 (with its **AC power adapter** connected) directly into a motherboard USB port.
3. Run Zadig, then **Options → List All Devices**.
4. Three Kinect interfaces appear in the dropdown — install **libusbK** for **each** one:
   - **Xbox NUI Motor**
   - **Xbox NUI Camera**
   - **Xbox NUI Audio**
   For each: pick it in the dropdown, choose **libusbK** as the target driver, then click **Install Driver** (or **Replace Driver**).
5. Open **Device Manager** to confirm — you should see a **libusbK USB Devices** group containing the three NUI entries (no yellow warning icons).
6. Re-launch DuneBox. The Kinect depth view should now appear.

> **Model 1414 vs 1473**: both work. If only some interfaces show up in Zadig,
> replug the AC adapter — the camera/audio interfaces only enumerate when the
> Kinect has external power.
>
> **Kinect v2 (Xbox One)** is different — it uses the official Kinect for Windows
> v2 SDK runtime + a USB 3.0 port, not Zadig/libusbK.

#### Quick sanity check: is the Kinect actually alive?

Run these in order — each rules out a layer (power → USB → driver → depth feed)
so you know exactly where a failure is.

1. **Power LED.** With the AC adapter connected and USB plugged in, the Kinect's
   front status LED should **blink green** (some firmware shows solid green once a
   host app connects). **No LED at all = power problem** — check the AC adapter,
   not the USB cable.
2. **Windows sees the USB device.** Open **Device Manager** → expand
   **libusbK USB Devices**. You should see **Xbox NUI Motor**, **Xbox NUI Camera**,
   and **Xbox NUI Audio** with **no yellow warning icons**. Missing entries or
   yellow `!` = redo the Zadig/libusbK step above.
   - *(Linux/macOS equivalent: `lsusb | grep -i xbox` should list "Xbox NUI Camera".)*
3. **Motor responds (proves the data path, not just power).** Run the bundled
   ofxKinect example or, if you have libfreenect installed, `freenect-glview` /
   `freenect-tilt` — tilting the head up/down means the host can talk to the
   device. In DuneBox you can also confirm by watching the motor recenter on
   launch.
4. **Live depth feed.** Launch DuneBox and wave your hand ~50 cm above the sensor.
   A **healthy feed** updates smoothly and your hand shows up as a distinct
   nearer (warmer/brighter) blob that tracks your movement in real time.
   - **All-black or all-one-color, frozen image** = no depth stream (driver/USB) —
     go back to steps 2–3.
   - **Image present but heavily speckled/flickering** = the feed works; it's an
     IR-interference or geometry issue → see *"Kinect depth image is noisy or
     flickering"* below.
   - **Remember the ~0.5–4.5 m range**: the Kinect v1 sees nothing closer than
     ~50 cm, so mount it high enough above the sand or the whole surface reads as
     blank/invalid.

> **No Kinect plugged in at all?** DuneBox falls back to a procedural sine-wave
> terrain. If you see smooth animated waves that *don't* react to your hand, the
> app is running fine but isn't receiving Kinect data — work back through steps
> 1–3.

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
