# Pegboard drilling jig — v3 design

V3 is a customizable two-tool system for a square hole grid. The first tool
registers on a board corner and drills a 2×2 seed. The second tool has four
matching locating pins and a configurable field of drill guides.

The initial cutter profile is for an ordinary twist drill with a metal guide
bush. A Forstner or hole-saw profile is a later design step because its wider
cutter needs a different clearance and pilot-guide arrangement.

The 10 mm hole, 50 mm pitch, and 25 mm edge offset are starting values carried
over from the earlier jig. Check that they match the panel you plan to drill;
the edge offset in particular was an assumption in the previous design.

## Default design

- Finished holes: **10 mm**
- Grid spacing: **50 mm**
- First-hole edge offset: **25 mm**
- Board thickness: **18 mm**
- Corner starter: **2×2 guides**
- Indexing tile: **4×4 stations**, with **4 removable locating pins + 12 guides**
- Printer target: **Bambu Lab A1 mini, 180×180×180 mm build volume**
- Indexing tile footprint: **170×170 mm** at the defaults

The indexing tile's pins occupy the first 2×2 stations. All other stations are
drill guides. At the default 4×4 setting, move it by two grid pitches so the
pins land in four holes from the previous placement. For smaller tiles, the
step is `index_cols - 2` pitches across and `index_rows - 2` pitches down.
The board grid is extended in overlapping tile regions; a partial final
placement is fine at board edges.

## Customizer settings

Edit `scad/params.scad` or use OpenSCAD's Customizer:

- `hole_d`, `grid_pitch`, and `edge_offset` define the board's pattern.
- `board_cols` and `board_rows` describe the board. Total holes are their
  product. For equal edge offsets, nominal board width is
  `2 * edge_offset + (board_cols - 1) * grid_pitch`; height uses
  `board_rows` in place of `board_cols`. The jig geometry itself is independent
  of the board's overall size.
- `bush_id` should match the drill-bit diameter. `bush_od` and
  `bush_seat_d` describe the metal bush and its printed press-fit socket.
- `pin_clearance` tunes how tightly the locating pins fit the drilled holes;
  `pin_mount_clearance` tunes the removable pins' fit in the tile body.
- `index_cols` and `index_rows` change the indexing-tile station field. The
  four pins remain a 2×2 pattern; every other station becomes a guide.
- `build_x`, `build_y`, and `bed_edge_clearance` enforce the printer limit.
  OpenSCAD stops with an assertion if the selected tile does not fit.

For an ordinary twist bit, the default 4×4 layout gives twelve drill guides
per placement. Smaller beds or wider grid spacing can require a smaller tile.
The default 170 mm footprint leaves 5 mm to each A1 mini bed edge; print the
tile without a brim. The design is deliberately kept within the stated bed
envelope, but slicer preview should confirm the actual orientation and skirt
settings before printing.

## Parts and assembly

The corner-starter tool has a flat guide plate and a separate L fence. These
two printed pieces mate through tabs and pockets; dry-fit first, then glue the
joint after checking that the fence sits square. Together they form the first
tool. The indexing tool is a flat-printing body plus four small pin inserts.
`indexing_pin_set.scad` lays out all four inserts for one print. They press into
the tile from the top face, with the chamfered ends pointing down in use.
`preview_corner_starter.scad` shows the assembled starter; export its plate
and fence as separate STLs.
`preview_indexing_tile.scad` shows the indexing body with its four pins
installed; export the body and pin set separately.

Print the starter plate flat with the bosses up. Print the fence standing on
its two long bottom edges; a brim may help. Print the indexing body flat with
the guide bosses up. Print the pin set with the four heads on the bed.

1. Glue the starter's fence square to its plate, then set it against both
   board edges and clamp it.
2. Drill four seed holes through its bushes.
3. Fit the four pin inserts into the indexing body.
4. Remove the starter, seat the indexing pins in the seed holes, clamp the tile
   on its open perimeter rails, and drill the twelve guide positions.
5. Leapfrog by the configured tile step, using four finished holes as
   references. At the default 4×4 setting, the step is two rows or columns.

Use metal drill bushes. The plastic seats are tunable press fits, not a
substitute for a hardened guide. Print a small fit coupon before the full
tools. Tune `bush_seat_d` and `pin_clearance` to the filament, printer, and
actual hardware.

## Export

From the project folder:

```sh
openscad -o stl/corner_starter_plate.stl scad/corner_starter_plate.scad
openscad -o stl/corner_starter_fence.stl scad/corner_starter_fence.scad
openscad -o stl/indexing_tile.stl scad/indexing_tile.scad
openscad -o stl/indexing_pin_set.stl scad/indexing_pin_set.scad
```

This is the first parametric design pass. The next design checks are the tab
fit, bush-seat fit, pin fit, index-tile clamping access, and a scrap-board
alignment run before relying on it for a full panel.

## Web configurator and case study

Open `index.html` to configure a board pattern, view the 3D tools, and step
through the corner-seed and tile-indexing sequence. The configurator reports
the board hole count and nominal size, limits the tile layout to the A1 mini
bed, and downloads the selected settings as JSON. It uses Three.js from a CDN,
so serve the folder over HTTP instead of opening it with a `file://` URL:

```sh
cd pegboard-jigs-v3
python3 -m http.server 8000
```

Then open `http://localhost:8000`. See [`CASE_STUDY.md`](CASE_STUDY.md) for the
design rationale, formulas, workflow, and validation status.

The browser tool previews configurations and exports their settings. The
included STL files are the default 10 mm / 50 mm / 25 mm profile. To generate
custom print geometry, update `scad/params.scad` and export the OpenSCAD parts.
