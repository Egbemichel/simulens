# SUMO Network — Mvog-Mbi → Poste Centrale Corridor

This directory holds the SUMO-compatible road network generated from the
real OSM extract, and the record of how it was produced.

## Files

- **`mvogmbi_postecentrale_corridor.net.xml`** — the SUMO network, generated
  by `netconvert` from
  [`../../data/processed/mvogmbi_postecentrale_corridor_cleaned.osm`](../../data/processed/mvogmbi_postecentrale_corridor_cleaned.osm)
  (a derived, documented copy of the raw extract with a small set of
  explicit lane/speed tag additions — see
  [`../../docs/methodology/network-cleaning.md`](../../docs/methodology/network-cleaning.md)
  for exactly what was added and why). This is a **structural** conversion:
  no traffic demand, signal timing, or calibration has been applied.
- **`netconvert_warnings.txt`** — the full, unedited console output from the
  current conversion run (see below for a categorized summary).

The raw OSM file itself was **not modified** by this or the cleaning
process — see `git log` on
`data/raw/osm/mvogmbi_postecentrale_corridor.osm` to confirm it is
unchanged since acquisition. Tag additions were applied to a separate
derived copy in `data/processed/`, never to the raw file.

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
  --osm-files data/processed/mvogmbi_postecentrale_corridor_cleaned.osm \
  --type-files <sumo-install>/data/typemap/osmNetconvert.typ.xml \
  --geometry.remove \
  --junctions.join \
  --default.junctions.radius 10 \
  --output.original-names \
  --output.street-names \
  -o simulation/network/mvogmbi_postecentrale_corridor.net.xml
```

(`--default.junctions.radius 10` was added during the network-cleaning
pass — see [`../../docs/methodology/network-cleaning.md`](../../docs/methodology/network-cleaning.md)
§3. It is a geometry parameter, not traffic data.)

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

### Structural counts (current, post-cleaning)

| Element | Count |
|---|---|
| Junctions (total) | 667 |
| — `priority` (real intersections) | 291 |
| — `right_before_left` | 10 |
| — `dead_end` | 16 |
| — `rail_crossing` | 1 |
| — `internal` (auto-generated) | 349 |
| Edges (total) | 2,707 |
| — normal (drivable/walkable) | 683 |
| — internal (auto-generated intersection geometry) | 2,024 |
| Lanes | 3,008 |
| Connections | 4,019 |
| Traffic-light logics (`tlLogic`) | 0 |

(Counts shifted slightly from the initial conversion — see
[`../../docs/methodology/network-cleaning.md`](../../docs/methodology/network-cleaning.md)
§3 for why: the junction-radius geometry fix affects how `--junctions.join`
clusters nearby nodes.)

Zero `tlLogic` entries is expected, not an error: **this study area
contains zero OSM-tagged traffic signals** — the one
`highway=traffic_signals` node in the raw extract turned out, on
investigation, to be ~1km outside the study boundary (see the network-
cleaning doc §5), and signal-guessing was deliberately not enabled (see
above). All real intersections are currently controlled by SUMO's default
priority / right-of-way rules, including the roundabouts (e.g. Place
Ahmadou Ahidjo), which import as priority-controlled junctions per OSM's
`junction=roundabout` tagging. Their true real-world control method is
unverified and flagged for field checking.

## Warnings from conversion

Full detail in [`netconvert_warnings.txt`](netconvert_warnings.txt) (current,
post-cleaning). A focused network-cleaning pass investigated which of
these affect the main corridor/feeders versus purely residential
geometry, and applied a geometry-only fix (`--default.junctions.radius
10`) for the corridor-relevant ones — full before/after detail,
including which warnings persisted, in
[`../../docs/methodology/network-cleaning.md`](../../docs/methodology/network-cleaning.md)
§3. Current categorized counts:

| Count | Category | Notes |
|---|---|---|
| 8 | Connection speed reduced for tight turning radius | Automatic, geometry-based. |
| 7 | Sharp turn / acute-angle geometry at an edge segment | One (`-1486879770#0`, Boulevard de l'OCAM) is corridor-relevant; see cleaning doc. |
| 10 | Nearby junctions not merged despite `--junctions.join` | `netconvert` decided the geometry didn't warrant merging; informational. |
| 5 | Junction cluster reduced | Geometry cleanup of closely-spaced OSM nodes into a smaller cluster. |
| 4 | Discarding unusable type (`waterway.*`) | Rivers/streams/canals/ditches inside the bbox — not roads, correctly excluded. |
| 4 | Turn-restriction relation broken (see below) | Investigated and confirmed genuinely outside the study area — not a bug. |
| 3 | Intersecting left turns at a junction | 2 of 3 are corridor-critical and **remain unresolved** after the radius fix — see cleaning doc §3. |
| 1 | Discarding unknown compound tag (`railway.rail\|usage.main`) | A rail edge with a tag combination not in the typemap. |
| 1 | Incomplete public-transport relation ignored | A PT route relation with no stops in this bbox. |
| 1 | Rail crossing node with no connected road | OSM node `2163420596`, no road edge attached in this extract. |
| 1 | Incomplete roundabout | Part of a roundabout's edge set (`608526512#0`) lies outside the bbox. |

### The one mapped turn restriction: confirmed not applicable here

The single `type=restriction` relation referencing this extract
(`no_left_turn`, relation `14151685`) was investigated directly against
the OSM API: its via-node's real coordinates place it **~1.5 km outside**
this study area's boundary. It is not a restriction on this corridor at
all — it only appeared in the raw extract because OSM's `map` endpoint
includes every node referenced by a way touching the bbox, however far
away that node actually is. **No turn restriction exists in this network's
study area**, and none was fabricated to fill the gap. Full investigation
in [`../../docs/methodology/network-cleaning.md`](../../docs/methodology/network-cleaning.md) §4.

## Pre-demand connectivity inspection

Before generating any traffic demand, the network was checked for fatal,
simulation-blocking connectivity problems (not just the local geometry
warnings above):

- **Whole-network connectivity**: restricting to passenger-allowed edges,
  a weakly-connected-component analysis (via `sumolib`) found **exactly
  one component** containing every passenger edge (576 before cleaning,
  567 after — see note below) — no disconnected islands in the drivable
  network, before or after cleaning.
- **Corridor routability**: using `sumolib`'s shortest-path search on the
  actual directed network (i.e. respecting one-way streets), a route
  exists in **both directions** between the edges nearest the two study
  endpoints, both before and after cleaning:
  - Before cleaning: Mvog-Mbi → Poste Centrale 30 edges/1,463 m; Poste
    Centrale → Mvog-Mbi 28 edges/1,416 m.
  - After cleaning: Mvog-Mbi → Poste Centrale 24 edges/1,220 m; Poste
    Centrale → Mvog-Mbi 19 edges/1,066 m (shorter — fewer redundant
    micro-edges after junction merging, not a shortcut or data change).
- **Engine load test** (see above): `sumo` itself loads the network without
  error, both before and after cleaning.

No fatal issues were found, in either version. The network is connected
and routable enough to support demand generation.

## What this network still does not include

- No **observed** or measured lane counts or speed limits anywhere — see
  [`../../docs/methodology/network-cleaning.md`](../../docs/methodology/network-cleaning.md)
  for the full OBSERVED / OSM-DERIVED / ASSUMED / MODEL-DEFAULT breakdown
  of every value now in the network.
- No traffic-signal timing — no junction in this network currently has
  signal control, and none is invented.
- No scenarios or interventions.
- No calibration or validation against observed traffic.

## Next step

Traffic demand exists as a **synthetic technical smoke test** — see
[`../routes/README.md`](../routes/README.md) and
[`../configs/README.md`](../configs/README.md). It is explicitly not
calibrated or observed data. A first network-cleaning pass is done (see
the methodology doc linked above); its unresolved limitations (some
corridor lane gaps, the provisional speed assumption, two persistent
geometry warnings, unverified signal control at every major junction) are
listed there and in
[`../../docs/PROJECT_STATUS.md`](../../docs/PROJECT_STATUS.md).
