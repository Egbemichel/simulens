# Corridor OSM Extraction — Methodology

This document records how the OpenStreetMap extraction area for the Carrefour
Mvog-Mbi → Poste Centrale study corridor was derived, so the result is
reproducible and auditable rather than a guessed boundary.

## 1. Confirmed inputs

Two endpoint coordinates were provided as reference points (not a bounding box):

| Point | Latitude | Longitude |
|---|---|---|
| Carrefour Mvog-Mbi | 3.85096 | 11.52165 |
| Poste Centrale | 3.86068 | 11.52054 |

Both were checked against live OpenStreetMap data via Nominatim reverse
geocoding before any extraction, to confirm they land on real, named OSM
features rather than empty space:

- `3.85096, 11.52165` → OSM node `6136100510`, `junction=yes`, name
  **"Carrefour Mvog Mbi"**, on `Rue 4.007`, Mvog-Mbi, Yaoundé IV.
- `3.86068, 11.52054` → OSM way `192838410`, `amenity=post_office`, name
  **"Poste Centrale"**, on `Rue 3.007`, Centre Administratif, Yaoundé III.

## 2. Identifying the connecting road

Rather than assume which named street links the two points, the actual
drivable OSM road graph was queried (Overpass API, all `highway=*` ways in a
generous exploratory bounding box around both points) and a shortest-path
search (Dijkstra, edge weight = real geodesic distance between consecutive
way nodes) was run from the OSM node nearest Mvog-Mbi to the OSM node
nearest Poste Centrale, restricted to drivable highway classes (`trunk`,
`primary`, `secondary`, `tertiary`, `residential`, and their `_link`
variants; footways, paths, steps and pedestrian ways excluded).

This produced a route of **~1,279 m** (vs. ~1,080 m straight-line between the
two endpoints — a realistic detour ratio for following real streets) through
the following named ways, in order:

1. **Place d'Awae** (trunk) — junction area at the Mvog-Mbi end
2. **Boulevard de l'OCAM** (trunk)
3. **Rue 1.001** (trunk, 4 lanes on part of its length)
4. **Boulevard du 20 Mai 1972** (trunk, 2 lanes, one-way)
5. **Place Ahmadou Ahidjo** (trunk, `junction=roundabout`, 6 lanes) — the
   major roundabout closest to Poste Centrale
6. **Rue 3.007** (primary, 2 lanes, one-way) — terminates at Poste Centrale

This is treated as the corridor's primary alignment. It was cross-checked
against an alternative hypothesis (that the corridor ran via **Avenue
Charles Atangana** and **Avenue John F. Kennedy**, both plausible from
general familiarity with central Yaoundé) — but the actual OSM geometry
shows Avenue Kennedy stays 280 m+ from Mvog-Mbi and Avenue Charles Atangana's
mapped extent stops well short of Poste Centrale, so neither forms a
continuous mapped path between the two endpoints. Only the route above is
supported by the actual, connected OSM graph data.

## 3. Deriving the extraction boundary

The bounding box of the traced route's geometry is:

- lat 3.85091 – 3.86195
- lon 11.52008 – 11.52233

A **~300 m buffer** (0.0027° in both axes at this latitude) was added on all
sides to capture immediate feeder roads and intersections without pulling in
an unnecessarily large part of Yaoundé. This buffer was validated by
confirming it captures — fully or at least at their point of intersection —
the named cross streets that plausibly affect corridor traffic: Avenue
Charles Atangana, Rue Many Ewondo, Avenue du Pdt El Hadj Ahmadou Ahidjo,
Avenue John F. Kennedy, Rue 3.700, Rue 3.010/3.012, Rue 4.007 (Mvog-Mbi's own
street), and the Place Charles Atangana and Place d'Awae junction areas.

**Final bounding box (WGS84, used for extraction):**

| | Latitude | Longitude |
|---|---|---|
| Min (SW corner) | 3.84821 | 11.51738 |
| Max (NE corner) | 3.86465 | 11.52503 |

Approximate size: 1.83 km (N–S) × 0.85 km (E–W) ≈ 1.56 km².

## 4. Extraction method

Data was pulled from the **official OSM API `map` endpoint**
(`https://api.openstreetmap.org/api/0.6/map?bbox=...`) — the same data the
openstreetmap.org "Export" button returns — rather than a third-party mirror,
so provenance is direct. This is implemented reproducibly in
[`scripts/fetch_osm_corridor.sh`](../../scripts/fetch_osm_corridor.sh).

Retrieved: 2026-09-15.
Output: [`data/raw/osm/mvogmbi_postecentrale_corridor.osm`](../../data/raw/osm/mvogmbi_postecentrale_corridor.osm)
License: © OpenStreetMap contributors, ODbL 1.0 (https://www.openstreetmap.org/copyright).

Contents: 27,921 nodes, 3,142 ways, 25 relations (full raw export — all
OSM feature types within the box, not filtered to roads only).

## 5. Known data-quality limitations

Inspecting the extract's `highway=*` ways (246 of the 3,142 total ways)
surfaced the following gaps, which matter for later SUMO conversion and
calibration:

- **Lane counts** are tagged on only 44/246 (~18%) of highway ways. Most
  residential and several secondary/tertiary ways have no `lanes` tag, so
  `netconvert` will fall back on its default lane-count heuristics for the
  untagged majority unless corrected.
- **Speed limits** (`maxspeed`) are tagged on only 5/246 ways — essentially
  absent. Simulated free-flow speeds will need to come from SUMO's
  highway-class defaults or a separate calibration step, not from the map
  data.
- **Traffic signals**: only 1 `highway=traffic_signals` node and 1
  `highway=stop` node exist in the whole extract; the two major junctions on
  the route (Place d'Awae, Place Ahmadou Ahidjo) are mapped as roundabouts
  rather than signalized, and no other corridor intersection carries signal
  data. Whether this reflects reality (few signals) or under-mapping is not
  yet verified against ground truth.
- **Turn restrictions**: only 1 `type=restriction` relation exists in the
  whole extract (a `no_left_turn`). Real turn restrictions elsewhere on the
  corridor, if any, are likely unmapped.
- **Surface data**: better coverage — 185/246 ways tagged, mostly `asphalt`
  (125) with some `ground` (45, unpaved), `paved` (8), `concrete` (5), and
  `paving_stones` (2). Still not a substitute for ground-truthed road
  condition (potholes, seasonal deterioration), which this project treats as
  a separate simulation variable to be defined later, not read off OSM tags.

None of these gaps were filled in — they are left as-is in the raw extract
and documented here so they are addressed explicitly during network cleaning
and calibration, not silently assumed away.

## 6. What this does not yet establish

- This extraction has **not** been converted to a SUMO network.
- No traffic demand, signal timing, or simulation results exist yet.
- This network has **not** been validated against observed traffic.

See [`../PROJECT_STATUS.md`](../PROJECT_STATUS.md) for the current status of
each of these.
