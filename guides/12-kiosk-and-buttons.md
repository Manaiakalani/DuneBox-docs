# 12 — Kiosk and Buttons

For a sandbox that runs on its own in a museum, library or classroom: it starts with the PC, recovers from crashes and unplugged cables, follows opening hours, and visitors use big physical buttons instead of a keyboard.

---

## Start automatically and stay running

### Windows

`kiosk.ps1` in the sandcam folder starts sandcam and restarts it whenever it exits or crashes, waiting longer between restarts if it keeps failing.

```powershell
# Try it now (Ctrl+C to stop)
powershell -ExecutionPolicy Bypass -File .\kiosk.ps1

# Also keep DuneBox (C++) running from ..\DuneBox\bin
powershell -ExecutionPolicy Bypass -File .\kiosk.ps1 -WithDuneBox

# Run it at every sign-in
powershell -ExecutionPolicy Bypass -File .\kiosk.ps1 -Install -WithDuneBox

# Remove it again
powershell -ExecutionPolicy Bypass -File .\kiosk.ps1 -Uninstall
```

`-Install` registers a scheduled task named **DuneBox kiosk**. Turn on automatic sign-in for the PC's account so the sandbox comes back by itself after a reboot or power cut. Restarts are logged to `kiosk.log` next to the script.

### Linux

`sandcam-kiosk.service` is the same thing as a systemd user service:

```bash
mkdir -p ~/.config/systemd/user
cp sandcam-kiosk.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now sandcam-kiosk
```

It assumes the repo is at `~/DuneBox-sandcam`; edit `WorkingDirectory` in the file if not.

---

## Opening hours and the projector

In the [dashboard](10-tablet-dashboard.md), open **Unattended**:

| Control | What it does |
|---|---|
| **Opening hours** | Outside the hours you set, the projection goes dark and the projector switches off. Hours can run past midnight (for example 18:00–02:00) |
| Open days | Tap the days the sandbox is open |
| **Wake until next change** | Brings it back early, until the next opening or closing time. Pressing a key or clicking on the sandbox PC does the same |
| **Projector (PJLink)** | Type the projector's IP address. sandcam turns it on and off with the opening hours, and **On** / **Off** test it now |
| **Reconnect camera automatically** | If the depth camera is unplugged, or the PC starts without it, sandcam keeps trying in the background and picks it up as soon as it's back |

PJLink is the network control standard most Epson, NEC, Panasonic, Sony and BenQ projectors support (enable it in the projector's network menu). If it asks for a password, set `projector_password` in `sandcam-settings.json`.

---

## Physical buttons

Big arcade buttons are easier for visitors than a keyboard. Two ways to connect them:

### A USB number pad

The simplest option, with no soldering: a cheap USB number pad gives 17 buttons. Any keypad key, and F13 to F15, works as a button.

### Arcade buttons on an Arduino

For real arcade buttons, use an Arduino Uno, Nano, Leonardo or similar:

1. Wire each button between a pin and **GND**: pins **2 to 9** are buttons 1 to 8. No resistors are needed.
2. Upload `hardware/buttons/buttons.ino` from the sandcam folder with the Arduino IDE.
3. Plug the Arduino into the sandbox PC and turn on **Physical buttons → Arduino buttons** in the dashboard. sandcam finds the board by itself.

Arcade buttons with a built-in LED can light up while pressed: connect each LED (with its resistor) to a spare pin and list it in `LED_PINS` in the sketch.

To check the wiring, open the Arduino IDE's Serial Monitor at **115200** baud: each press prints a line such as `BTN 3`. Close the monitor before turning on **Arduino buttons**, since only one program can use the port.

### Choose what each button does

Press a button and it appears in the **Physical buttons** group. Pick an action from its menu; the choice is saved.

Arduino buttons 1 to 6 start out as erupt a volcano, next colour theme, contour lines on/off, raise the sea, lower the sea, and save the terrain. Other choices include earthquake, creatures, day and night, the terrain challenge, end the game, wake the sandbox, and DuneBox (C++) water, lava, eruption, drain and erosion.
