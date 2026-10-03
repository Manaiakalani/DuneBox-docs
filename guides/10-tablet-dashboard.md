# Run it from a tablet

sandcam serves a web dashboard that shows the live sand map and controls both apps. Out of the box it only answers on the sandbox PC itself. This page covers turning it on, opening it to a tablet or phone on the same Wi-Fi, and keeping it locked to people who know the PIN.

## Turn on the dashboard

1. Start sandcam.
2. Press ++u++. The status line flashes the address, normally <http://127.0.0.1:8765/>.
3. Open that address in a browser on the sandbox PC.

To have it start every time, set `"depth_server_enabled": true` in `sandcam-settings.json`.

## What it controls

| Group | Controls |
|---|---|
| **World** | Color theme, contour lines, creatures and creature set, plants grow, day and night with speed, sound |
| **Events** | Erupt a volcano, trigger an earthquake |
| **Games** | Start or end Build a Dam, Volcano Defense, Watershed Puzzle, Biome Sculpt |
| **Setup** | Calibrate depth (Kinect v2), save a terrain snapshot, reset terrain (simulator) |
| **DuneBox (C++)** | Water, lava, eruption, next theme, day and night, start. Appears when DuneBox (C++) is running on the same PC |

Every action is confirmed by the sandbox itself. If a command fails, the dashboard says why, for example "Kinect v2 (SDK) can't auto-calibrate depth". On a keyboard, press ++question++ for shortcuts; they match the sandcam keys.

The status pills along the top are honest: **Simulator (no depth camera)** means sandcam fell back to the mouse simulator, and the DuneBox (C++) group says **Not linked** until the C++ app actually connects.

## Open it to the Wi-Fi

In `sandcam-settings.json`:

```json
{
  "depth_server_enabled": true,
  "depth_server_host": "0.0.0.0",
  "dashboard_pin": ""
}
```

Restart sandcam. The first time, Windows asks whether Python may accept connections; allow it on **private** networks only.

Then, on the sandbox PC's dashboard, select **Open on a tablet**. Scan the QR code with the tablet's camera, or type the address and PIN it shows.

!!! warning "Use a private network"
    Anyone who can reach the PC and knows the PIN can change the sandbox. Use your home or classroom Wi-Fi, not open guest networks.

## The PIN

When the dashboard is open to the network, it always needs a PIN:

- Leave `dashboard_pin` empty and sandcam picks a new six-digit PIN each time it starts. Good for one-off events.
- Set `dashboard_pin` to your own digits (for example `"4821"`) to keep the same PIN across restarts. Good for a classroom tablet that stays paired.

The tablet remembers the PIN after the first visit. After five wrong PINs from one device, that device waits a minute before trying again. The sandbox PC itself never asks: pages opened from the address sandcam flashes already carry the PIN.

## Troubleshooting

| What you see | Fix |
|---|---|
| Tablet says the page can't be reached | Check both devices are on the same network and the firewall prompt was allowed. The address must be the PC's LAN address, not `127.0.0.1` |
| **Can't reach the sandbox** banner | sandcam stopped or the dashboard was toggled off with ++u++. The page retries on its own; select **Retry** to try now |
| **That PIN is no longer valid** | sandcam restarted and picked a new PIN. Rescan the QR code, or set a fixed `dashboard_pin` |
| No QR code, only an address | Install the optional QR dependency with `uv sync`, then restart sandcam |
| DuneBox (C++) group says **Not linked** | Start DuneBox (C++) on the same PC. It links to sandcam automatically within a few seconds |
