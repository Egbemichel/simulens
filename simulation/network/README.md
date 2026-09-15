# SUMO Network — Mvog-Mbi → Poste Centrale Corridor

This directory holds the SUMO-compatible road network generated from the
real OSM extract, and the record of how it was produced.

## Files

- **`mvogmbi_postecentrale_corridor.net.xml`** — the SUMO network, generated
  by `netconvert` from
  [`../../data/raw/osm/mvogmbi_postecentrale_corridor.osm`](../../data/raw/osm/mvogmbi_postecentrale_corridor.osm).
  This is a **structural** conversion only: no traffic demand, signal
  timing, or calibration has been applied.
- **`netconvert_warnings.txt`** — the full, unedited console output from the
  conversion run (see below for a categorized summary).

The raw OSM file itself was **not modified** by this process — `netconvert`
reads it and writes a separate network file; see `git log` on
`data/raw/osm/mvogmbi_postecentrale_corridor.osm` to confirm it is
unchanged since acquisition.

## How to regenerate

```
scripts/convert_osm_to_sumo.sh
```

This script requires SUMO's `netconvert` on `PATH`. SUMO was not installed
in the base development environment for this project; it was installed via:

```
pip install eclipse-sumo
```

which bundles the `netconvert`/`sumo` binaries and SUMO's standard data
files (including the OSM typemap used below) under
`<site-packages>/sumo/`. No system package manager (`apt`) install was
needed or used.

**SUMO version used:** Eclipse SUMO 1.27.1 (`eclipse-sumo` 1.27.1 on PyPI).

## Exact conversion command

```
netconvert \
  --osm-files data/raw/osm/mvogmbi_postecentrale_corridor.osm \
  --type-files <sumo-install>/data/typemap/osmNetconvert.typ.xml \
  --geometry.remove \
  --junctions.join \
  --output.original-names \
  --output.street-names \
  -o simulation/network/mvogmbi_postecentrale_corridor.net.xml
```

(Exact reproducible form: `scripts/convert_osm_to_sumo.sh`.)

### Why these options, and no others

This intentionally does **not** use SUMO's own `osmBuild.py` helper's full
default option set
(`--geometry.remove,--ramps.guess,--junctions.join,--tls.guess-signals,--tls.discard-simple,--tls.join,--output.original-names,--output.street-names`).
It keeps the geometry-cleanup options but drops the traffic-signal-guessing
ones:

- **`--type-files osmNetconvert.typ.xml`** — SUMO's own standard typemap,
  used unmodified. It supplies fallback lane count / speed / priority values
  *only* for OSM highway classes that lack explicit `lanes`/`maxspeed` tags
  (most ways in this extract — see the extraction methodology doc). These
  are SUMO's documented generic defaults per road class, not
  Yaoundé-specific measurements, and are called out below as a calibration
  target, not treated as ground truth.
- **`--geometry.remove`** — merges redundant intermediate shape points along
  a way into a single edge; does not change road topology or invent
  anything.
- **`--junctions.join`** — merges OSM's often multi-node representation of a
  single real-world intersection into one logical SUMO junction. Standard,
  necessary cleanup for OSM imports; does not add or remove roads.
- **`--output.original-names` / `--output.street-names`** — preserves OSM
  way names and IDs in the output so every SUMO edge can be traced back to
  its source OSM way.
- **Omitted: `--ramps.guess`** — only affects motorway/motorway_link edges;
  this corridor has none, so it would be a no-op either way.
- **Omitted: `--tls.guess-signals` / `--tls.discard-simple` / `--tls.join`**
  — these would add traffic-light control at geometrically complex
  junctions that have **no** `highway=traffic_signals` tag in OSM. The
  extract has only 1 such tagged node in the whole area, and it did not end
  up controlling a junction (see below). Per the current task's scope,
  traffic control assumptions beyond what OSM actually encodes are a later
  calibration decision, not part of this structural conversion.

## Structural validation

The network was checked two ways:

1. **`netconvert` completed with `Success.`** (exit code 0) — no fatal
   errors, only warnings (categorized below).
2. **Loaded in the SUMO simulation engine itself**, not just the converter:
   `sumo -n mvogmbi_postecentrale_corridor.net.xml --no-step-log --end 10`
   ran to completion with exit code 0 (empty network, no demand — this only
   confirms the network file itself is structurally loadable by `sumo`, not
   that any traffic behaves correctly on it).

### Structural counts

| Element | Count |
|---|---|
| Junctions (total) | 701 |
| — `priority` (real intersections) | 296 |
| — `right_before_left` | 10 |
| — `dead_end` | 16 |
| — `rail_crossing` | 1 |
| — `internal` (auto-generated) | 378 |
| Edges (total) | 2,750 |
| — normal (drivable/walkable) | 692 |
| — internal (auto-generated intersection geometry) | 2,058 |
| Lanes | 3,041 |
| Connections | 4,050 |
| Traffic-light logics (`tlLogic`) | 0 |

Zero `tlLogic` entries is expected, not an error: the only OSM
`traffic_signals` node in the extract does not sit at a junction requiring
one (likely a mid-block pedestrian-crossing signal), and signal-guessing was
deliberately not enabled (see above). All 296 real intersections are
currently controlled by SUMO's default priority / right-of-way rules,
including the roundabouts (e.g. Place Ahmadou Ahidjo), which import as
priority-controlled junctions per OSM's `junction=roundabout` tagging.

## Warnings from conversion (38 warning lines, categorized)

Full detail in [`netconvert_warnings.txt`](netconvert_warnings.txt). None of
these blocked network generation; they are flagged here as things to
revisit during network cleaning / calibration, not fixed silently:

| Count | Category | Notes |
|---|---|---|
| 24 | Connection speed reduced for tight turning radius | Automatic, geometry-based; expected at sharp junctions. Worth spot-checking the sharpest ones. |
| 7 | Nearby junctions not merged despite `--junctions.join` | `netconvert` decided the geometry didn't warrant merging (parallel or long-edge cases); left as separate junctions. |
| 7 | Sharp turn / acute-angle geometry at an edge segment | Reflects actual OSM node placement; may indicate an OSM digitizing quirk or a genuinely sharp real corner — not yet distinguished. |
| 4 | Discarding unusable type (`waterway.*`) | Rivers/streams/canals/ditches inside the bbox — not roads, correctly excluded from the road network. |
| 4 | Turn-restriction relation broken (see below) | The single mapped turn restriction in the extract references two ways that lie outside the extraction bounding box, so it could not be attached. |
| 4 | Intersecting left turns at a junction | `netconvert`'s own suggestion is "increase junction radius" — a network-geometry refinement, not a data problem. |
| 3 | Junction cluster reduced | Geometry cleanup of closely-spaced OSM nodes into a smaller cluster. |
| 1 | Discarding unknown compound tag (`railway.rail\|usage.main`) | A rail edge with a tag combination not in the typemap; the way itself is still imported as a plain railway. |
| 1 | Incomplete public-transport relation ignored | A PT route relation with no stops in this bbox — expected for a relation that extends beyond the extraction area. |
| 1 | Rail crossing node with no connected road | OSM node `2163420596` is tagged as a rail crossing but has no road edge attached in this extract — likely the crossing road falls just outside the bbox or was filtered as non-drivable. |
| 1 | Incomplete roundabout | Part of a roundabout's edge set (`608526512#0`) lies outside the bbox, so it's written as a partial roundabout. |

### Specific known limitation: the one mapped turn restriction is lost

`docs/methodology/corridor-osm-extraction.md` already flagged that the
extract contains only one `type=restriction` relation
(`no_left_turn`, relation `14151685`). During conversion, its two member
ways (`727379371`, `1061207468`) turned out **not** to be present in the
raw extract at all — they lie outside the study bounding box, even though
the restriction's `via` node is inside it. `netconvert` correctly dropped
the restriction rather than guessing. This means the generated network
currently has **zero enforced turn restrictions**, which does not match
reality and will need to be re-added manually (or via a wider re-extraction)
during network cleaning.

## What this conversion deliberately does not include

- No traffic demand (vehicles, routes, flows) — none exists yet anywhere in
  the repository.
- No calibrated lane counts or speed limits — untagged ways use SUMO's
  generic per-class typemap defaults, not measured or Yaoundé-specific
  values.
- No traffic-signal timing — no junction in this network currently has
  signal control.
- No scenarios or interventions.
- No validation against observed traffic.

## Next step

Traffic demand definition (`simulation/routes/`) is the next milestone per
the project's progression (OSM network → SUMO network → traffic demand →
baseline simulation). Before that, the network-cleaning items above (lane
counts, the lost turn restriction, the sharp-angle/intersecting-left-turn
warnings) should be reviewed — see
[`../../docs/PROJECT_STATUS.md`](../../docs/PROJECT_STATUS.md) for the
up-to-date TODO ordering.
