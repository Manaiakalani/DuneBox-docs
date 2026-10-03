# Classroom

sandcam can run a lesson step by step from the [tablet dashboard](10-tablet-dashboard.md), keep score for teams, and show everything on the sand in English or Spanish.

---

## Run a lesson

1. Open the dashboard and find the **Classroom** group.
2. Choose **Start** next to a lesson. Each one lists its age range and length.
3. The step's title and instructions appear on the sand, and the sandbox sets itself up for that step (theme, contour lines, sea level, sometimes a game).
4. Choose **Next step** or **Back** to move through it, and **End lesson** when you are done.

A presentation clicker works too: ++page-down++ goes to the next step and ++page-up++ goes back.

Some steps have a goal, such as "build a tall mountain". sandcam measures the sand and shows a hint ("Make it taller") until the class gets there, then "✓ Done".

### Lessons included

| Lesson | Ages | Minutes | Covers |
|---|---|---|---|
| Reading a topographic map | 9–14 | 20 | Build a mountain, then see how contour lines show its shape, height and steepness |
| Islands and rising seas | 9–14 | 20 | Build an island with a town on the beach, then raise the sea and protect it |
| Where does the rain go? | 8–12 | 15 | Build a ridge between two valleys, predict where rain will flow, then test it |

---

## Teams and points

Under **Teams**, pick **2**, **3** or **4**. Each team gets a colour and a score on the sand (turn off **Show scores on the sand** to keep them on the tablet only).

- Type in a team's name box to rename it.
- **+1** and **-1** adjust a score by hand.
- After a game ends, the dashboard offers "Give the last game's points to:" with a button per team.
- **Reset scores** sets everyone back to zero.

---

## Language

**Language on the sand** switches the lesson text and new team names projected on the sand between **English** and **Español**. Lessons without Spanish text stay in English.

The dashboard **EN / ES** switch in the top bar is separate: lesson titles, step text and confirmations on the tablet follow that switch, even if the sand is still in English.

---

## Write your own lesson

Lessons are JSON files in sandcam's `lessons/` folder. Add a file there and restart sandcam; a file with a mistake is skipped, and the log says why.

```json
{
  "id": "my-lesson",
  "title": {"en": "Build a volcano island", "es": "Construye una isla volcánica"},
  "level": {"en": "Ages 9–14", "es": "De 9 a 14 años"},
  "minutes": 15,
  "summary": {"en": "One short sentence for the lesson list.", "es": "Una frase corta para la lista."},
  "steps": [
    {
      "title": {"en": "Build an island", "es": "Construye una isla"},
      "text": {"en": "Leave sea all around it.", "es": "Deja mar a su alrededor."},
      "settings": {"theme": "terrain", "contours": true, "sea_level": 0},
      "check": {
        "metric": "below_sea", "min": 0.3, "max": 0.85,
        "hint": {"en": "Leave sea all around it", "es": "Deja mar a su alrededor"}
      }
    },
    {
      "title": "Make it erupt",
      "settings": {"game": "volcano"}
    }
  ]
}
```

Any text can be a plain string, or one string per language (`en`, `es`). Only `id` and at least one step with a `title` are required.

**Settings** a step can apply:

| Setting | Value |
|---|---|
| `theme` | `terrain`, `heat`, `greyscale` or `desert` |
| `contours`, `contour_labels`, `creatures` | `true` or `false` |
| `contour_interval` | Spacing between lines, as a share of the depth range (for example `0.05`) |
| `sea_level` | Offset from the normal sea level, from `-0.2` to `0.2` |
| `game` | `dam`, `volcano`, `watershed`, `biome`, or `challenge:island`, `challenge:valley`, `challenge:two_peaks` |

**Checks** a step can wait for:

| Metric | Measures |
|---|---|
| `below_sea` | Share of the sand under water, from 0 to 1 |
| `relief` | Height between the lowest and highest points, as a share of the depth range |

Give `min`, `max` or both, plus an optional `hint` shown until the goal is met.
