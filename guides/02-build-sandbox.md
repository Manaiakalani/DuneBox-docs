# 02 — Building the Sandbox

## Overview

The sandbox is a plywood box filled with sand, mounted on a rigid frame with the Kinect and projector above it. The **4:3 aspect ratio is mandatory** — it matches the Kinect's field of view.

---

## Bill of Materials

| Item | Spec | Est. Cost | Where to buy |
|---|---|---|---|
| **Plywood** | ¾" (19mm), one 4'×8' sheet | $25–40 | Home Depot / Lowe's |
| **Wood screws** | #8 × 1¼", box of 50 | $5 | Hardware store |
| **Wood glue** | Titebond III (waterproof) | $5 | Hardware store |
| **Polyurethane sealant** | Water-based, 1 quart | $12–15 | Hardware store |
| **Sandtastik White Play Sand** | 25 lb bags × 6–8 | $90–150 | Amazon / craft stores |
| **Support frame** | ¾" steel pipe + flanges OR 80/20 aluminum extrusion | $40–80 | Hardware store / 80/20.net |
| **Kinect mount** | L-bracket or 3D-printed mount | $5–15 | Hardware store / 3D print |
| **Projector mount** | Ceiling mount or shelf bracket | $15–30 | Amazon |
| **Spray bottle** | For dampening sand | $3 | Dollar store |
| **Calibration target** | Printed chessboard on cardstock | $0–5 | Print at home |
| | | **$220–365 total** | |

---

## Sandbox Box Construction

### Dimensions
- **Interior**: 40" × 30" × 4" deep (1016mm × 762mm × 102mm)
- **Exterior**: ~41.5" × 31.5" × 5.5" (with ¾" plywood walls and base)
- **Aspect ratio**: 4:3 — this is **mandatory**, not a suggestion

### Cut List (from one 4'×8' plywood sheet)

| Piece | Size | Qty |
|---|---|---|
| Base | 41.5" × 31.5" | 1 |
| Long sides | 41.5" × 5.5" | 2 |
| Short sides | 30" × 5.5" | 2 |

### Assembly Steps

1. **Cut plywood** to dimensions above. Have the hardware store make the cuts if you don't have a table saw.

2. **Dry fit** — lay out the base with sides standing on it. Check squareness by measuring diagonals (should be equal).

3. **Glue + screw** — apply wood glue to the base edges, place sides, drive screws through the sides into the base edge every 6". Pre-drill to prevent splitting.

4. **Seal interior** — apply 2–3 coats of polyurethane to the entire interior surface (base + sides). Let each coat dry 2–4 hours. This prevents moisture damage from damp sand.

5. **Let cure 24 hours** before adding sand.

### Pro Tips
- Round or sand the interior edges — prevents sand from catching in sharp corners
- Optional: line with heavy-duty plastic sheeting for extra waterproofing
- The box should sit at a comfortable height for users (30–36" for adults, 24" for kids)

---

## Support Frame

The frame holds the box, Kinect, and projector. **Rigidity is critical** — any flex or vibration ruins the projector-Kinect calibration.

### Option A: Steel Pipe (Easiest)

```
        ┌──────── projector mount ────────┐
        │                                 │
   ┌────┴────┐                       ┌────┴────┐
   │  pipe   │    Kinect mount        │  pipe   │
   │  (rear) │    (center bar)        │  (rear) │
   │         │         ↓              │         │
   │    ┌────┴─────────┴──────────────┴────┐    │
   │    │          cross bar               │    │
   │    └──────────────────────────────────┘    │
   │                                            │
   ├────────── SANDBOX BOX ────────────────────┤
   │                                            │
   └────────────────────────────────────────────┘
        legs (4×)        legs (4×)
```

**Parts list:**
- 4× vertical legs: ¾" pipe, 40" long
- 2× cross bars: ¾" pipe, 42" long (span the sandbox width)
- 1× center bar: ¾" pipe, 32" long (for Kinect mount)
- 8× floor flanges (4 for sandbox corners, 4 for top)
- 8× elbow joints
- 2× T-joints (for center bar)

### Option B: 80/20 Aluminum Extrusion (Most rigid)

More expensive but incredibly rigid and adjustable. Use 1" (25mm) T-slot extrusion. Allows precise height adjustment for Kinect and projector.

---

## Mounting the Kinect

- Mount **directly above center** of the sandbox
- Point **straight down** (perpendicular to sand surface)
- Height: **~40 inches** (1 meter) above the sand surface for a 40" wide box
- Use an L-bracket or 3D-printed mount — the Kinect has a standard ¼"-20 tripod thread on the bottom

### Kinect Mounting Checklist
- [ ] Centered over sandbox (measure both diagonals)
- [ ] Level (use a bubble level)
- [ ] Firmly secured (no wobble when bumped)
- [ ] USB cable routed to PC without tension
- [ ] AC power adapter plugged in

---

## Mounting the Projector

- Mount above the **rear long edge** of the sandbox (not center)
- Most projectors project above their centerline — the image goes "up" from the lens
- Short-throw projectors work best (less distance needed)
- The projector should illuminate the entire sand surface with minimal overshoot

### Projector Mounting Checklist
- [ ] Image covers entire sand surface
- [ ] No shadows from frame or Kinect
- [ ] Focus is sharp across the entire surface
- [ ] HDMI cable routed to PC without tension
- [ ] Firmly secured (calibration depends on fixed position)

---

## Adding Sand

1. **Sandtastik White Play Sand** is the community consensus best choice:
   - Projects colors vividly (white surface)
   - No fine silica dust (respiratory safe)
   - Available on Amazon in 25 lb bags

2. **Quantity**: ~75 liters (6–8 bags of 25 lbs) to fill the box to 4" depth

3. **Dampen the sand**: Add 1 cup of water per ~200 lbs of sand. Mix thoroughly. Damp sand:
   - Holds shapes better (mountains, valleys)
   - Doesn't create dust clouds
   - Is safer to breathe around

4. **Level the sand** initially — the software will map whatever surface you create, but start flat for calibration.

> ⚠️ **Do NOT use regular hardware store sand** without washing it first. Construction sand contains fine silica dust which is a serious respiratory hazard. Sandtastik is pre-washed and safe.
