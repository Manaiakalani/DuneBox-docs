# 06 — Troubleshooting

## Common Problems & Solutions

---

### Kinect Issues

#### Do not run both apps at once
Kinect v2 is **exclusive**. Close sandcam before launching Magic-Sand (and vice versa) or you will see "no Kinect connected" / "in use by another app".

#### Missing Kinect20.dll (Kinect v2)
The pre-built C++ app needs **Kinect for Windows Runtime 2.0**. Install from [download 44559](https://www.microsoft.com/download/details.aspx?id=44559). `run.bat` warns if `Kinect20.dll` is missing.

#### sandcam depth looks wrong after mounting a v2
Press **`A`** to auto-calibrate `min_depth_mm` / `max_depth_mm` from the flat sand.

#### Kinect not detected / "Failed to initialize streaming mode"
- **Check USB**: Plug directly into motherboard USB port — **no USB hubs**
- **Check power**: Kinect v1 requires its AC power adapter; USB alone won't work
- **Windows — install the libusbK driver first** (see below); plug/unplug a few times only helps *after* the driver is in place

<a id="windows-installing-the-kinect-v1-driver-zadig--libusbk"></a>

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

#### Kinect v2 Configuration Verifier shows orange warnings (usually safe to ignore)

The **Kinect for Windows v2 Configuration Verifier** (`KinectVerifier.exe`, installed
with SDK 2.0 under
`C:\Program Files\Microsoft SDKs\Kinect\v2.0_1409\Tools\KinectConfigurationVerifier\`)
flags two **orange `!` warnings** on many modern PCs. Neither is fatal — if DuneBox or
sandcam already shows a live depth feed, you can ignore both. An orange `!` is a
*warning*; only a red ✗ is a hard failure.

**"Update Configuration Definitions — Failed to update, using last known good definitions"**

- The verifier tries to download fresh definitions from a Microsoft server that has
  since been **retired**, so the update always fails and it falls back to the bundled
  ("last known good") definitions.
- **Resolution: none needed.** This is only an online-update check; the verifier and the
  Kinect runtime work normally offline. Safe to ignore.

**"USB Controller — Unknown USB 3.0 port detected. Your USB configuration may support Kinect for Windows"**

- The verifier only recognises a fixed list of older Intel/Renesas USB 3.0 host
  controllers. Newer controllers — e.g. the **Intel USB 3.1 eXtensible Host Controller**
  using the Microsoft inbox driver — aren't on that list, so it reports
  "Unknown… *may* support" instead of a definite pass.
- This is a **soft warning, not a failure** (a real failure reads "USB configuration
  **not** supported" with a red ✗). Most unknown USB 3.0 controllers, including the Intel
  xHCI, stream Kinect v2 depth fine.
- **Resolution:** confirm the sensor actually works (below). Only if depth/IR frames are
  all-zero or keep dropping out should you move the Kinect Adapter to a different
  **USB 3.0** port backed by another host controller.

**Confirm the v2 sensor is really working (this overrides both warnings):**

1. **Device Manager** — the Kinect enumerates as **WDF KinectSensor Interface 0**,
   **Xbox NUI Sensor**, and a **Generic SuperSpeed USB Hub**, all with no yellow `!`.
2. Run the SDK's **Kinect Studio** or the **Depth Basics-D2D** sample — you should see a
   live depth image.
3. In DuneBox the launch log shows `opening Kinect for Windows v2` followed by
   `setFromPixels(): allocating to match dimensions: 512 424` (depth frames flowing). In
   sandcam, use the `kinect_v2_sdk` backend.

> **Plug into a rear USB 3.0 port** (directly on the motherboard — blue, or labelled
> "SS"), not a front-panel header or an external hub. Kinect v2 depth/IR are uncompressed
> and need full USB 3.0 bandwidth; **color works but depth/IR are all-zero** almost always
> means the link negotiated USB 2.0.
>
> Download SDK 2.0 (includes the runtime, verifier, Kinect Studio, and samples) from
> Microsoft: <https://www.microsoft.com/en-us/download/details.aspx?id=44561>.

---

### Projector Issues

#### Colors are shifted / misaligned
- **Recalibrate** (open the GUI `Calibration` folder and click "Automatically calibrate kinect & projector")
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
- **Check OpenGL version**: DuneBox needs OpenGL 3.2+. Check via GPU-Z or the DuneBox startup diagnostics log.

#### Water simulation is very slow / laggy
- **Expected on Quadro P620**: ~20–35 FPS for complex water scenes. The P620 has ~30% of the GTX 1060's compute power.
- Reduce sandbox area in settings (smaller simulation grid = faster)
- Close other GPU-intensive applications

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
- **Windows**: The `freenect.dll` should be in the sandcam directory. Reinstall with `uv sync`.

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
- Check that the Python venv is using the correct Python version (3.11+)

---

### Getting Help

- **[r/arsandbox](https://reddit.com/r/arsandbox)** — dedicated subreddit (113 members), maintained by the SARndbox creator
- **[SARndbox FAQ](https://web.cs.ucdavis.edu/~okreylos/ResDev/SARndbox/FAQ.html)** — official FAQ from UC Davis
- **[UC Davis calibration videos](https://www.youtube.com/results?search_query=SARndbox+calibration)** — step-by-step video guides
