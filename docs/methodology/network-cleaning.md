# Network Cleaning — Methodology

A focused cleaning pass on the SUMO network generated from the real OSM
extract, done to make the network **more trustworthy before introducing
real observed traffic data** — not to calibrate it and not to validate it.
Nothing in this document should be read as a claim that the network now
reflects measured, real-world conditions.

## Data provenance classification

Every non-trivial value in the network now falls into one of four
categories. This distinction is the point of this document — conflating
them is exactly what must not happen going into calibration:

- **OBSERVED DATA** — an actual field measurement or count. **None exists
  in this project yet.** Nothing in the network is OBSERVED.
- **OSM-DERIVED DATA** — an explicit tag present in the raw OpenStreetMap
  extract (`data/raw/osm/mvogmbi_postecentrale_corridor.osm`), unmodified.
  Real, but crowd-sourced/volunteered, not measured by this project.
- **ASSUMED DATA** — a value this cleaning pass added because it was
  *inferable* from OSM-derived data on the same physical road (e.g. copying
  a lane count from a tagged segment to an untagged segment of the same
  named way). Documented explicitly below, including the source segment.
- **MODEL DEFAULTS** — SUMO's own generic typemap fallback values
  (`osmNetconvert.typ.xml`), applied automatically by `netconvert` wherever
  neither OSM-derived nor assumed data exists. Generic, not
  Yaoundé-specific, not corridor-specific.

## 1. Lane data

**Method**: inspected every corridor and major-feeder named road's OSM
`lanes` tag (raw extract, all segments). Where some segments of a named
road carry an explicit `lanes` tag and others don't, and the tagged
segments agree, the untagged segments were given the same value —
**ASSUMED DATA**, not invented. Where no same-road evidence exists at all,
nothing was added; those segments still fall back to SUMO's generic
typemap default (**MODEL DEFAULT**) and are flagged as open gaps.

Implemented in [`../../scripts/patch_osm_tags.py`](../../scripts/patch_osm_tags.py)
(`LANE_OVERRIDES`), applied to a **derived copy** of the raw OSM file
(`data/processed/mvogmbi_postecentrale_corridor_cleaned.osm`) — the raw
extract itself was never touched (verified: `git diff` on
`data/raw/osm/mvogmbi_postecentrale_corridor.osm` is empty after this
change).

### ASSUMED (10 way segments)

| Road | Segments given `lanes=2` | Evidence (already-tagged segments of the same road) |
|---|---|---|
| Boulevard de l'OCAM | 630899558, 630899576, 688078455, 688078456 | 615207480, 688078457, 1486879770 (all `lanes=2`) |
| Boulevard du 20 Mai 1972 | 913211108 | 7 other segments, all `lanes=2` |
| Rue Many Ewondo | 204406544, 1241964746, 1257140147 | 48801969, 1257140148 (`lanes=2`) |
| Avenue John F. Kennedy | 97257140 | 236956785 (`lanes=2`) — single-segment evidence, weaker confidence |
| Avenue du Pdt El Hadj Ahmadou Ahidjo | 727378247 | 614502824 (`lanes=2`) — single-segment evidence, weaker confidence |

### NOT assumed — left as MODEL DEFAULT, open gap

Deliberately **not** touched, because no same-road tagged evidence exists,
or the only evidence was contradictory/not clearly applicable:

- **Place d'Awae** (706737153, 736398871, 736398872) — zero tagged segments
  anywhere in the extract.
- **Rue 1.001** (206159731) — the only other segment of this road
  (206159732) is tagged `lanes=4`, a *different* value; copying it would be
  a bigger and less defensible assumption than the cases above, especially
  this close to a major junction where lane count plausibly changes. Left
  untouched.
- **Place Ahmadou Ahidjo link** (209214746) — the roundabout ring itself
  (35811035) is tagged `lanes=6`, but 209214746 is a separate
  approach/exit way (not tagged `junction=roundabout`), so the ring's lane
  count doesn't reliably apply to it.
- **Rue 3.010** (204406322, 713182026, 1061295729), **Rue 3.012**
  (199028552), **Rue 4.007** (615207479, 713516967, 713516971, 725285849)
  — zero tagged evidence anywhere. **Rue 4.007 is the road at the
  Mvog-Mbi endpoint itself** — worth flagging prominently as a priority
  for future field verification.

## 2. Speed data

**Method**: checked every corridor/feeder way for an OSM `maxspeed` tag.
Only **2 of ~50** corridor/feeder segments have one — both `maxspeed=50`
(way 494826133, Boulevard du 20 Mai 1972; way 35811035, the Place Ahmadou
Ahidjo roundabout) — **OSM-DERIVED**, real.

Searched for a reliable external source to corroborate a general urban
limit for the rest of the corridor (per this task's explicit instruction
to check before assuming). Result: general web sources (driving-guide and
travel-blog sites, not a primary legal text) describe Cameroon's urban
speed limit as commonly cited at 50 km/h, with some sources saying 60.
**This is not a verified legal citation** — no authoritative primary
source (an official Highway Code text, government gazette, or CEMAC legal
document) was found and confirmed during this pass.

Given that, and given SUMO's alternative — its generic non-urban
typemap default of **100 km/h** for trunk/primary/secondary roads, used
automatically wherever no speed data exists — is clearly *worse*, not
neutral, for a dense urban corridor, a **PROVISIONAL MODEL ASSUMPTION** of
50 km/h was applied to the ~48 corridor/feeder segments lacking a tag,
**scoped only to those named roads**, not network-wide. This is explicitly
labeled provisional, grounded only in (a) the 2 real in-corridor OSM tags
and (b) weak secondary corroboration, and must be replaced with field data
or a verified legal citation before any calibration claim is made.

Implemented in `scripts/patch_osm_tags.py` (`SPEED_OVERRIDE_WAYS`,
`SPEED_OVERRIDE_KMH = "50"`).

All other roads in the network (residential streets etc., outside the
named corridor/feeder set) were **not** touched and still fall back to
SUMO's generic typemap defaults — a known, out-of-scope limitation for
this pass.

## 3. Intersection / geometry warnings

Cross-referenced every OSM way ID named in the original conversion's
warnings ([`../../simulation/network/netconvert_warnings.txt`](../../simulation/network/netconvert_warnings.txt))
against the corridor/feeder way-ID list to separate corridor-relevant
issues from the many purely residential ones (which were intentionally
left alone, per this task's scope).

**Corridor/feeder-relevant issues identified** (8 of ~38 total warnings):
junction clusters and an "intersecting left turns" warning at the Place
d'Awae / Rue 4.007 junction (the Mvog-Mbi end), a sharp angle on Boulevard
de l'OCAM, an "intersecting left turns" warning on Rue 3.007, a junction
cluster and turning-radius speed reduction on Rue 3.010, and a junction
cluster on Avenue John F. Kennedy.

**Fix applied**: `netconvert`'s own suggested remedy —
`--default.junctions.radius 10` (up from SUMO's default of ~4m), added to
`scripts/convert_osm_to_sumo.sh`. This is a **geometry parameter**, not
traffic data: it changes how tightly turn lanes are drawn/connected at
junctions, asserting nothing new about lanes, speeds, or signals.

**Result — honest, not fully resolved**: this measurably changed junction
topology (netconvert's `--junctions.join` clustering is itself sensitive to
radius, more than expected going in — junction count dropped from 701 to
667, edge count from 692 to 683 real edges, as some near-duplicate
junctions now merge that didn't before). One corridor-adjacent
"intersecting left turns" warning (near Place Charles Atangana) was
resolved. **Two corridor-critical ones were not**: the Rue 3.007 junction
(`cluster_4642971881_4642971884`) and the Place d'Awae/Rue 4.007 junction
at the Mvog-Mbi end (`cluster_6641240534_6641240537_6641240541`) still
report intersecting left turns at radius 10. A further radius increase was
**not** attempted, because it already introduced a new warning elsewhere
in the network (outside the corridor) — pushing it further is a
diminishing-returns, network-wide trade-off that deserves its own
dedicated pass, not a blind parameter search here. These two remain an
**open limitation**, to be resolved either by a targeted per-junction node
patch or by field-verified geometry, not a global parameter.

## 4. Turn restriction

Investigated the single dropped `no_left_turn` restriction (relation
`14151685`, from-way `727379371`, to-way `1061207468`, via-node
`2156095653`) by fetching the two missing member ways directly from the
OSM API (read-only, for documentation — this did **not** change the study
boundary or the raw extract).

**Finding: this restriction is not on our study corridor at all.** The
via-node's real coordinates are **3.8785607, 11.5159311** — roughly 1.5 km
north of this study area's northern boundary (max lat 3.86465) and ~3.3 km
from Mvog-Mbi. It only appears in our raw extract because the OSM `map`
endpoint includes every node referenced by any way that touches the
bounding box, even nodes far outside it. There is no way to "represent
this restriction correctly within the extracted network" because it does
not belong to this network — so, per this task's explicit instruction, it
was **not** fabricated or force-added. **No turn restriction exists in the
network's study area**, and none was found to add. This is a documented
absence, not an oversight.

## 5. Traffic signals

**No traffic lights were invented.** The network still has **zero**
`tlLogic` entries (unchanged by this cleaning pass). Investigating the
single `highway=traffic_signals` node in the raw extract (node
`4377502633`) the same way as the turn restriction: its real coordinates
are **3.8708376, 11.5342232** — also well outside the study boundary
(~930 m east, ~950 m north of it). **This corridor's real extraction area
contains zero OSM-tagged traffic signals.** (This corrects an earlier,
weaker guess in `simulation/network/README.md` that the node might be a
mid-block pedestrian signal within the network — it is not in the network
area at all.)

**Major intersections whose real control method needs field
verification**, since none currently has any signal data and all are
modeled as default priority (or roundabout) junctions:

- **Place d'Awae** (Mvog-Mbi end) — unverified: signal, roundabout
  give-way, or uncontrolled priority in reality?
- **Place Ahmadou Ahidjo** — OSM tags it `junction=roundabout`; modeled as
  such, but whether it is signal-assisted in practice is unverified.
- **The Rue 3.007 junction complex** (`cluster_4642971881_4642971884`,
  also flagged above for geometry) — a busy junction near Poste Centrale
  with no signal data.
- **The Avenue John F. Kennedy junction cluster** — same, unverified.

## 6. Road condition

**No changes made.** Existing OSM `surface` tags (125 asphalt, 45 ground,
8 paved, 5 concrete, 2 paving_stones — see
[`corridor-osm-extraction.md`](corridor-osm-extraction.md)) are preserved
exactly as extracted; this pass did not add, remove, or infer any surface
values. No pothole/deterioration data was invented, per this task's
explicit instruction — there is currently no source for it.

**Preparation for later**: road condition is intended (per the project's
principles) to become a simulation variable, most naturally implemented in
SUMO as a per-edge speed/quality modifier (e.g. a reduced effective
`maxspeed` or a custom edge parameter consumed by a later analytics/
scenario layer) layered on top of the `maxspeed` values established above,
rather than by altering the base network. No such mechanism is implemented
yet — this is a structural note for the scenario-engine work, not a
change made in this pass.

## Validation: before vs. after

Same synthetic smoke test (`scripts/generate_synthetic_demand.sh`, seed
42, then `scripts/run_baseline_smoke_test.sh`), rerun against the cleaned
network without changing any demand-generation parameters:

| Metric | Before | After | Note |
|---|---|---|---|
| Vehicles inserted | 258 / 258 | 258 / 258 | unchanged |
| Vehicles arrived | 237 | 233 | see explanation below |
| Still en route at t=1800 | 21 | 25 | see explanation below |
| Collisions | 0 | 0 | unchanged |
| Teleports | 0 | 0 | unchanged |
| Simulation completion | reached t=1800 | reached t=1800 | unchanged |
| Mean route length (completed trips) | 2027.1 m | 1964.8 m | shorter: fewer redundant micro-edges after junction merging |
| Mean speed (completed trips) | 15.86 m/s | 12.91 m/s | **expected** — see below |
| Mean duration (completed trips) | 124.1 s | 152.8 s | **expected** — see below |
| Mean time loss | 26.83 s | 22.67 s | slightly lower |
| Mean depart delay | 0.00 s | 0.02 s | negligible |

**The network was not silently broken** — it still loads, still completes
the full 1,800 s run, and still has zero collisions/teleports.

**Why speed dropped and fewer vehicles arrived — this is the expected
effect of the speed cleaning, not a regression.** Before cleaning, almost
every corridor/feeder edge had no `maxspeed` tag and silently used SUMO's
generic **100 km/h** typemap default — unrealistically fast for a dense
urban corridor. After cleaning, those same edges use the provisional
**50 km/h** assumption (§2). Vehicles now travel slower, so fewer complete
their trip within the fixed 1,800 s window (237 → 233) and more are still
en route at cutoff (21 → 25). This is the intended, transparent effect of
replacing a worse silent default with a documented provisional one — not
evidence of new network damage.

## Unresolved limitations carried forward

- Lane counts on Place d'Awae, Rue 1.001, the Place Ahmadou Ahidjo link,
  Rue 3.010, Rue 3.012, and **Rue 4.007** (the Mvog-Mbi endpoint road
  itself) are still SUMO generic defaults, not OSM or assumed data.
- The 50 km/h speed value is a **provisional model assumption**, not a
  verified legal or observed value — needs either an authoritative source
  or field/observed data.
- Two corridor-critical junctions (Rue 3.007; Place d'Awae/Rue 4.007) still
  report intersecting-left-turn geometry warnings even after the radius
  fix; unresolved, needs targeted per-junction work.
- Real control method (signal vs. priority vs. roundabout) is unverified
  at every major corridor junction — zero OSM signal data exists within
  the study area.
- No turn restrictions exist anywhere in the network — the one nearby OSM
  restriction turned out to be outside the study area, not applicable.
- Road surface data is present but unused; no road-condition modeling
  exists yet.

**This network is still not calibrated and still not validated against
observed traffic.** This pass only improves trustworthiness ahead of that
future work — it does not constitute it.
