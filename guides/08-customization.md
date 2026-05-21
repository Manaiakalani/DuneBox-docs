# 08 — Customization & Features

## Overview

DuneBox is highly customizable across both the C++ (DuneBox) and Python (sandcam) applications. This guide covers all the major features and how to configure them.

---

## Color Themes (DuneBox C++)

DuneBox includes **5 built-in color themes** that change the terrain elevation gradient, water color, and contour line color.

| Theme | Description |
|---|---|
| **Topo** | Classic topographic map colors (green → brown → white) |
| **Ocean** | Deep blue water emphasis, sandy shores |
| **Volcanic** | Reds, oranges, and dark greys — pairs with lava mode |
| **Ice Age** | Cool blues and whites, glacial feel |
| **Alien** | Otherworldly purples, greens, and cyans |

### Controls

- **`t` key** — cycles through themes
- Active theme is saved in `bin/data/settings/sandSurfaceRendererSettings.xml`

Each theme defines:
- **Elevation gradient** — color ramp from lowest to highest terrain
- **Water color** — tint applied to the water simulation overlay
- **Contour color** — color of topographic contour lines

---

## Dinosaur Mode (sandcam)

sandcam includes a full **dinosaur simulation** with 6 species, biome-aware placement, and predator-prey mechanics.

### Species

| Species | Biome | Role |
|---|---|---|
| T-Rex | Mountain / highland | Apex predator |
| Raptor | Forest / grassland | Pack predator |
| Stegosaurus | Grassland / beach | Herbivore |
| Triceratops | Grassland | Herbivore (defensive) |
| Pteranodon | Mountain peaks / sky | Aerial |
| Brachiosaurus | Forest | Large herbivore |

Each species has an **elevation range** — creatures only spawn in terrain zones matching their biome preference.

### Predator-Prey Mechanics

- **Predators** (T-Rex, Raptor) **chase** nearby herbivores
- **Herbivores** (Stegosaurus, Triceratops, Brachiosaurus) **flee** from predators
- **Triceratops** can **charge** predators in defense
- Predators can **kill** prey on contact — prey respawns after a cooldown

### Controls

- **`V` key** — cycles creature visibility: **Modern → Prehistoric → All → None**

### ArUco Marker Triggers

| Marker ID | Effect |
|---|---|
| 10 | Spawn T-Rex pack |
| 11 | Spawn Raptor pack |
| 12 | Spawn Pteranodon flock |
| 13 | Extinction event (kills all dinosaurs) |

---

## Volcano System (sandcam)

Place and trigger volcanoes anywhere on the terrain.

### Placement

- **`O` key** — places a volcano at the center of the terrain
- **ArUco marker ID 20** — places a volcano at the marker's position

### Eruption

- **Click** a placed volcano to trigger eruption, or use **ArUco marker ID 21** to trigger the nearest volcano

### Eruption States

Volcanoes cycle through 5 states:

1. **Dormant** — visible cone, no activity
2. **Rumbling** — screen shake, smoke particles begin
3. **Erupting** — sparks and ash particles launch from the crater
4. **Flowing** — lava flows downhill using **cellular automata** (each cell propagates to lower neighbors)
5. **Cooling** — lava darkens, activity subsides, returns to dormant

### Particle Effects

- **Smoke** — rising grey particles during rumbling and eruption
- **Sparks** — bright orange particles launched from crater
- **Ash** — dark particles that drift and settle
- **Steam** — produced when lava meets water

### Inter-App Sync

Volcano eruptions sync with the C++ DuneBox app via the inter-app bridge (see below), enabling lava mode and volcanic theme to activate automatically.

---

## Ecosystem Simulation (sandcam)

A layered ecosystem that grows vegetation and manages food chains based on terrain.

### Controls

- **`E` key** — toggles ecosystem on/off

### Vegetation Layers

Three layers of vegetation grow based on water proximity and elevation:

1. **Grass** — grows near water at low-mid elevations
2. **Shrubs** — grows at mid elevations where grass is established
3. **Trees** — grows at mid elevations where shrubs are established (slowest)

### Biome Zones

The terrain is classified into **7 biome zones** based on elevation and moisture:

- Deep water, shallow water, beach, grassland, forest, mountain, snow

### Food Chain

- **Vegetation** → consumed by **herbivores**
- **Herbivores** → hunted by **carnivores**
- **Carrying capacity** limits populations naturally — overpopulation leads to die-off

---

## Game Modes (sandcam)

sandcam includes 4 educational game modes, each with star ratings (★★★) on completion.

| Key | Game | Objective |
|---|---|---|
| **F1** | Build a Dam | Contain rising water by sculpting terrain barriers |
| **F2** | Volcano Defense | Protect a village from lava by diverting flow with terrain |
| **F3** | Watershed Puzzle | Route rainfall to a target reservoir using channels |
| **F4** | Biome Sculpt | Shape terrain to match a target elevation distribution |

All game modes use a **CPU-based water simulation** for game logic (separate from DuneBox's GPU water sim), so games work independently of the C++ app.

---

## Day/Night Cycle (Both Apps)

A dynamic lighting cycle that affects visuals and creature behavior across both DuneBox and sandcam.

### Controls

- **`N` key** — toggles day/night cycle on/off
- **`+` / `-` keys** — increase/decrease cycle speed
- **`P` key** — pause the cycle at current phase

### Phases

| Phase | Lighting | Details |
|---|---|---|
| **Dawn** | Warm orange tones | Sun rises, birds begin ambient audio |
| **Day** | Full brightness | Normal simulation lighting |
| **Dusk** | Golden-purple gradient | Sun sets, transition period |
| **Night** | Dark blue tones | Stars and moon visible, sun hidden |

### Behavior Changes

- **Creatures slow 50% at night** — reduced movement speed during night phase
- **Sound changes** — crickets and owl sounds at night; bird calls at dawn (see Sound System)

---

## Earthquake Gesture (sandcam)

Trigger earthquakes by physical interaction or keyboard.

### Activation

- **Hand slap** — detected from rapid depth changes across the sensor
- **`K` key** — manual trigger

### Effects

- **Expanding shockwave rings** radiate from the epicenter
- **Dinosaur stampede** — all dinosaurs flee at 2× speed
- **70% chance** to trigger eruption on nearby volcanoes

---

## Sound System (sandcam)

Spatial audio that reacts to terrain and simulation events.

### Controls

- **`S` key** — mute/unmute all sound

### Ambient Sounds

| Sound | Trigger |
|---|---|
| Water | Terrain-reactive volume (louder with more water) |
| Wind | Always present, varies with terrain height |
| Crickets | Night phase only |

### Event Sounds

| Sound | Trigger |
|---|---|
| Creature spawn/despawn | Creature added or removed |
| Marker detect/lost | ArUco marker enters or leaves view |
| Eruption | Volcano erupts |
| Earthquake | Earthquake triggered |

### Configuration

Sound settings are stored in the settings JSON:
- **Master volume** — overall volume level
- **Per-category volumes** — ambient, events, creatures, UI

---

## Web Dashboard (sandcam)

A browser-based dashboard for monitoring and remote control.

### Controls

- **`U` key** — enables the WebSocket server on port **8765**

### Access

Open the dashboard HTML file directly:
```
web/index.html
```

Or connect to `http://localhost:8765` when the WebSocket server is running.

### Features

- **Live depth view** — real-time terrain visualization
- **FPS graph** — performance monitoring
- **Creature stats** — population counts, species breakdown
- **Remote controls** — change themes, toggle water, mute sound, start games from the browser

---

## DEM Loading (sandcam)

Load real-world terrain data as a depth overlay.

### Controls

- **`D` key** — toggles DEM overlay on/off
- **`[` / `]` keys** — cycle through built-in terrains: **canyon**, **volcano**, **valley**, **islands**, **flat**
- **`F5`** — saves a snapshot of the current terrain

### GeoTIFF Support

For loading custom GeoTIFF elevation files, install the optional `rasterio` dependency:

```bash
uv sync --extra geo
```

---

## Inter-App Bridge

TCP-based communication between sandcam (Python) and DuneBox (C++).

### Controls

- **`B` key** — toggles the bridge on/off

### Architecture

- **Protocol**: TCP with JSON messages on `localhost:9876`
- **sandcam (Python)** = server
- **DuneBox (C++)** = client

### Synced Data

| Data | Direction | Description |
|---|---|---|
| ArUco markers | sandcam → DuneBox | Marker positions and IDs |
| Theme changes | sandcam → DuneBox | Theme switch commands |
| Volcano eruptions | sandcam → DuneBox | Eruption triggers and lava state |
| Water status | DuneBox → sandcam | Water simulation state |

---

## ArUco Marker Reference

Full table of supported ArUco marker IDs:

| Marker ID | Event |
|---|---|
| 10 | Spawn T-Rex pack |
| 11 | Spawn Raptor pack |
| 12 | Spawn Pteranodon flock |
| 13 | Extinction event |
| 20 | Place volcano |
| 21 | Trigger nearest eruption |

### Adding Custom Marker Events

1. **Print an ArUco marker** — use OpenCV's ArUco dictionary (4×4_50). Pick an unused ID.
2. **Register the event** in `interaction_engine.py`
3. **Attach the marker** to a physical toy (tape it to the bottom of a figurine, boat, etc.)
4. **Place the toy on the sand** → the webcam detects the marker → the event fires

---

## sandcam: Adding Custom Creatures

Creatures are **biome-aware** — they appear based on terrain elevation. The system is defined in `creatures.py`.

### Adding a New Creature

1. **Create a sprite** — any PNG image with transparency. Place it in `assets/creatures/`.

2. **Register it in `creatures.py`**:
   ```python
   CREATURE_TYPES = {
       "my_creature": {
           "sprite": "assets/creatures/my_creature.png",
           "biome": "grassland",
           "speed": 0.3,
           "size": (48, 48),
           "rarity": 0.1,
       },
   }
   ```

3. **Biome types** (lowest to highest elevation):
   `deep_water`, `shallow_water`, `beach`, `grassland`, `forest`, `mountain`, `snow`

---

## DuneBox (C++): Adding Games

The C++ DuneBox has a game plugin system in `src/Games/`. Each game is a class that inherits from a base game interface.

Existing games:
- **Shape an Island** — draw an island in the sand
- **Sandimals** — fish and sharks swim in water areas
- **Animals & Mothers** — match animals with their habitats

Adding new C++ games requires more effort than Python — refer to the existing game classes as templates.

---

## Inspiration & References

- **[RiverWeyTrust/ARSandbox-Adds](https://github.com/RiverWeyTrust/ARSandbox-Adds)** — lava flows, snow effects
- **[danigeos/sARndbox](https://github.com/danigeos/sARndbox)** — erosion & sedimentation simulation
- **[SARndbox calibration videos](https://www.youtube.com/results?search_query=SARndbox)** — see what others have built
