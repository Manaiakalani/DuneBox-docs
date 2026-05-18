# 08 — Custom Themes & Creatures

## Overview

One of DuneBox's goals is making it easy to add your own themes, creatures, and interactive experiences. The sandcam (Python) side is much easier to customize than the C++ side.

---

## sandcam: Adding Custom Creatures

### Creature System
Creatures in sandcam are **biome-aware** — they appear based on terrain elevation. The system is defined in `creatures.py`.

### Adding a New Creature

1. **Create a sprite** — any PNG image, ideally with transparency. Place it in `assets/creatures/`.

2. **Register it in `creatures.py`**:
   ```python
   CREATURE_TYPES = {
       # ... existing creatures ...
       "trex": {
           "sprite": "assets/creatures/trex.png",
           "biome": "mountain",        # Where it appears
           "speed": 0.3,               # Movement speed
           "size": (48, 48),           # Display size in pixels
           "rarity": 0.1,             # Spawn probability (0–1)
       },
   }
   ```

3. **Biome types** (from lowest to highest elevation):
   - `deep_water` — deep blue areas
   - `shallow_water` — light blue areas
   - `beach` — sand-colored transition zone
   - `grassland` — green low areas
   - `forest` — darker green mid areas
   - `mountain` — brown/grey high areas
   - `snow` — white peaks

---

## sandcam: Adding ArUco Marker Triggers

### How Markers Work
1. A webcam watches the sand surface
2. When it detects an ArUco marker, it reads the marker ID
3. The marker ID maps to an **event** in `interaction_engine.py`
4. The event triggers a visual effect at the marker's position

### Adding a New Marker Event

1. **Print an ArUco marker** — use OpenCV's ArUco dictionary. Pick an unused ID.

2. **Register the event** in `interaction_engine.py`:
   ```python
   MARKER_EVENTS = {
       # marker_id: event_config
       0: {"type": "volcano", "radius": 50, "particles": "lava"},
       1: {"type": "dinosaur", "creature": "trex", "count": 3},
       2: {"type": "water_source", "flow_rate": 1.0},
       # Add yours:
       3: {"type": "forest", "tree_count": 10, "spread": 80},
   }
   ```

3. **Attach the marker** to a physical toy (tape it to the bottom of a dinosaur figurine, boat, etc.)

4. **Place the toy on the sand** → the webcam detects the marker → the event fires!

---

## Theme System (Planned)

The goal is a YAML-based theme system for swapping the entire visual style:

```yaml
# themes/dinosaur.yaml
name: "Jurassic DuneBox"
terrain_colors:
  deep_water: "#1a3d5c"
  shallow_water: "#3d7a5c"
  beach: "#c4a35a"
  grassland: "#5a8c3d"
  forest: "#2d5a1a"
  mountain: "#8c7a5a"
  snow: "#d4cfc4"
water_color: "#3d5a2d"  # murky green
creatures:
  - type: trex
    biome: grassland
    rarity: 0.05
  - type: raptor
    biome: forest
    rarity: 0.1
  - type: stegosaurus
    biome: beach
    rarity: 0.08
  - type: pterodactyl
    biome: mountain
    rarity: 0.03
markers:
  0: {type: volcano, effect: eruption}
  1: {type: meteor, effect: extinction_event}
```

```yaml
# themes/ocean.yaml
name: "Deep Blue DuneBox"
terrain_colors:
  deep_water: "#0a1628"
  shallow_water: "#1a4a7a"
  beach: "#f0e6c8"
  grassland: "#7ab87a"
  forest: "#3d7a3d"
  mountain: "#8c8c8c"
  snow: "#ffffff"
water_color: "#1a3a6a"
creatures:
  - type: shark
    biome: deep_water
    rarity: 0.03
  - type: dolphin
    biome: shallow_water
    rarity: 0.1
  - type: turtle
    biome: beach
    rarity: 0.08
  - type: seagull
    biome: beach
    rarity: 0.15
markers:
  0: {type: boat, effect: wake_trail}
  1: {type: lighthouse, effect: beam_sweep}
```

### Loading a Theme
```bash
uv run python main.py --theme themes/dinosaur.yaml
```

> ⚠️ The theme system is planned but not yet implemented. Currently, customization requires editing Python source files directly.

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
