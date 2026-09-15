#!/usr/bin/env python3
"""Produces a derived, documented copy of the raw OSM extract with a small,
explicit set of tag overrides for the Mvog-Mbi -> Poste Centrale corridor
and its major feeder roads.

This does NOT modify data/raw/osm/ -- the raw extract stays untouched. It
writes a new file under data/processed/, so the override list here is the
single source of truth for every non-OSM value introduced into the network.
See docs/methodology/network-cleaning.md for the full rationale, sourcing,
and OBSERVED/ASSUMED/OSM-DERIVED/MODEL-DEFAULT classification of every
value below.

Usage: scripts/patch_osm_tags.py
"""
import xml.etree.ElementTree as ET

RAW = "data/raw/osm/mvogmbi_postecentrale_corridor.osm"
OUT = "data/processed/mvogmbi_postecentrale_corridor_cleaned.osm"

# --- ASSUMED lane counts -----------------------------------------------
# Applied ONLY where an untagged way segment shares a name with an adjacent
# segment of the SAME physical road that DOES carry an explicit OSM `lanes`
# tag, and that tagged value is consistent across every other tagged
# segment of that road within the extract. This is an inference from real
# OSM data on the same road, not an invented number -- but it IS an
# assumption, not an observation, and is documented as such.
#
# way_id -> (lanes value to apply, road name, source way id(s) providing evidence)
LANE_OVERRIDES = {
    # Boulevard de l'OCAM: 3 of 7 segments tagged lanes=2 (615207480,
    # 688078457, 1486879770); these 4 untagged segments get the same value.
    "630899558": ("2", "Boulevard de l'OCAM", "615207480/688078457/1486879770"),
    "630899576": ("2", "Boulevard de l'OCAM", "615207480/688078457/1486879770"),
    "688078455": ("2", "Boulevard de l'OCAM", "615207480/688078457/1486879770"),
    "688078456": ("2", "Boulevard de l'OCAM", "615207480/688078457/1486879770"),
    # Boulevard du 20 Mai 1972: 7 of 8 segments tagged lanes=2; this is the
    # only untagged one.
    "913211108": ("2", "Boulevard du 20 Mai 1972", "206009240/494826132/494826133/494826134/610000204/1240405040/1240405086"),
    # Rue Many Ewondo: 2 of 5 segments tagged lanes=2.
    "204406544": ("2", "Rue Many Ewondo", "48801969/1257140148"),
    "1241964746": ("2", "Rue Many Ewondo", "48801969/1257140148"),
    "1257140147": ("2", "Rue Many Ewondo", "48801969/1257140148"),
    # Avenue John F. Kennedy: 1 of 2 segments tagged lanes=2.
    "97257140": ("2", "Avenue John F. Kennedy", "236956785"),
    # Avenue du Pdt El Hadj Ahmadou Ahidjo: 1 of 2 segments tagged lanes=2.
    "727378247": ("2", "Avenue du Pdt El Hadj Ahmadou Ahidjo", "614502824"),
}

# --- PROVISIONAL speed assumption ---------------------------------------
# Applied to corridor + major feeder ways that have NO OSM maxspeed tag.
# Value: 50 km/h. Sourcing (see docs/methodology/network-cleaning.md for
# full discussion -- this is NOT a verified legal citation):
#   - Two segments already IN this extract carry a real OSM maxspeed=50 tag
#     (way 494826133 on Boulevard du 20 Mai 1972, way 35811035 on the
#     Place Ahmadou Ahidjo roundabout) -- both are corridor trunk roads.
#   - General web sources on Cameroonian traffic regulation describe 50
#     km/h as a commonly cited urban speed limit, but none found during
#     this pass is an authoritative primary legal text (see documentation).
# This is explicitly a PROVISIONAL MODEL ASSUMPTION, applied only to
# corridor/feeder ways, not network-wide, and clearly weaker evidence than
# the lane assumptions above (which are inferred from this extract's own
# OSM tags). It replaces SUMO's generic non-urban typemap default (100
# km/h for trunk/primary/secondary), which is worse, not neutral.
SPEED_OVERRIDE_KMH = "50"
SPEED_OVERRIDE_WAYS = {
    # Corridor
    "706737153", "736398871", "736398872",  # Place d'Awae
    "615207480", "630899558", "630899576", "688078455", "688078456", "688078457", "1486879770",  # Boulevard de l'OCAM
    "206159731", "206159732",  # Rue 1.001
    "206009240", "494826132", "494826134", "610000204", "913211108", "1240405040", "1240405086",  # Boulevard du 20 Mai 1972 (494826133 already tagged)
    "209214746",  # Place Ahmadou Ahidjo link (35811035 already tagged)
    "470045115", "615241214", "688531012", "740596757", "740596758",  # Rue 3.007
    # Feeders
    "615254596", "693675107", "693675108",  # Avenue Charles Atangana
    "48801969", "204406544", "1241964746", "1257140147", "1257140148",  # Rue Many Ewondo
    "97257140", "236956785",  # Avenue John F. Kennedy
    "614502824", "727378247",  # Avenue du Pdt El Hadj Ahmadou Ahidjo
    "615220838", "715620614", "1268244598",  # Rue 3.700
    "204406322", "713182026", "1061295729",  # Rue 3.010
    "199028552",  # Rue 3.012
    "615207479", "713516967", "713516971", "725285849",  # Rue 4.007
}

# Explicitly NOT touched (zero same-name evidence in this extract for
# lanes; documented as unresolved gaps requiring field verification --
# these still get SUMO's generic typemap default lane count, unchanged):
#   Place d'Awae (706737153/736398871/736398872), Rue 1.001 (206159731,
#   only neighbor evidence is a *different* value of 4 lanes -- too weak
#   to copy), Place Ahmadou Ahidjo link (209214746, not part of the
#   6-lane-tagged roundabout ring itself), Rue 3.010, Rue 3.012, and
#   Rue 4.007 (the road at the Mvog-Mbi endpoint itself).


def main():
    tree = ET.parse(RAW)
    root = tree.getroot()

    lanes_applied = 0
    speed_applied = 0

    for way in root.findall("way"):
        wid = way.get("id")
        tags = {t.get("k"): t for t in way.findall("tag")}

        if wid in LANE_OVERRIDES and "lanes" not in tags:
            value, _, _ = LANE_OVERRIDES[wid]
            tag = ET.SubElement(way, "tag")
            tag.set("k", "lanes")
            tag.set("v", value)
            lanes_applied += 1

        if wid in SPEED_OVERRIDE_WAYS and "maxspeed" not in tags:
            tag = ET.SubElement(way, "tag")
            tag.set("k", "maxspeed")
            tag.set("v", SPEED_OVERRIDE_KMH)
            speed_applied += 1

    tree.write(OUT, encoding="UTF-8", xml_declaration=True)
    print(f"Wrote {OUT}")
    print(f"Lane overrides applied: {lanes_applied} (expected {len(LANE_OVERRIDES)})")
    print(f"Speed overrides applied: {speed_applied} (expected <= {len(SPEED_OVERRIDE_WAYS)}, "
          f"fewer if any already had a tag)")


if __name__ == "__main__":
    main()
