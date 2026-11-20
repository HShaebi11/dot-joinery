# V3 pegboard jig — case study

## Problem

Drilling a large, evenly spaced hole grid into a plywood panel requires a
repeatable reference. Measuring every hole is slow, and small placement errors
can accumulate. V3 uses a corner reference once, then carries that reference
forward through the holes already drilled.

## Design goal

Build a configurable two-tool system that:

- starts from a panel corner and drills a matching 2×2 seed;
- registers the indexing tool with four pins in those four seed holes;
- drills as many new holes per placement as the A1 mini can print in one
  rigid tile;
- supports an ordinary twist drill guided by a metal bush;
- exposes board, cutter, fit, and tile settings in a browser configurator.

The wider-cutter profile for Forstner bits and hole saws is a later step. Those
cutters need a guide for the pilot and a separate opening for the wide cutting
head.

## System

### 1. Corner starter

The corner starter uses an L-shaped fence to register against both panel
edges. Four guide bushes sit on the selected square grid positions:

```text
●  ●
●  ●
```

At the default 50 mm pitch and 25 mm edge offset, the seed centres are at
(25,25), (75,25), (25,75), and (75,75) mm from the panel corner. The fence is
printed separately from the flat guide plate and glued square after a dry fit.

### 2. Four-pin indexing tile

The tile repeats the same 2×2 locator pattern in its first four stations. Every
other station in the configured tile is a guide. The default 4×4 layout is:

```text
P  P  G  G
P  P  G  G
G  G  G  G
G  G  G  G
```

`P` marks a locating pin; `G` marks a drill guide. The layout yields twelve
new guide positions per full placement. Four removable pins are used so the
large tile body can print flat with its guide bosses up.

The tile advances by the overlap that remains after reserving its 2×2 pin
field: `tile columns - 2` grid steps horizontally and `tile rows - 2` steps
vertically. At the default 4×4 setting, that is two pitches in either
direction. Each next placement lands its four pins in holes from the prior
placement.

## Customization model

The web tool at [`index.html`](index.html) exposes:

- board hole count across and down;
- finished hole / drill-bit diameter;
- centre-to-centre pitch and first-hole edge offset;
- panel thickness;
- tile station rows and columns, constrained by the printer bed;
- bush dimensions, printed bush-seat diameter, and pin clearance.

The board hole count is `columns × rows`. With equal edge offsets, nominal
panel width is:

```text
2 × edge offset + (columns - 1) × pitch
```

Nominal panel height uses rows in place of columns. The guide count is:

```text
tile columns × tile rows - 4 locating pins
```

The body envelope is estimated as `(stations - 1) × pitch + boss diameter`.
At 10 mm holes, 50 mm pitch, and 20 mm guide bosses, a 4×4 tile is 170×170 mm.
A 5×5 tile would exceed the A1 mini's 180×180 mm build area at this pitch.
Smaller pitches may allow more stations, provided the guide bosses retain
enough material between them.

## Drilling workflow

1. Set the corner starter's L fence against both panel edges and clamp it.
2. Drill the four seed holes through the metal guide bushes.
3. Fit the four locating pins into the indexing body.
4. Remove the starter. Seat the indexing pins in all four seed holes and
   clamp the tile to the panel.
5. Drill through each highlighted guide position.
6. Lift and move the tile by its configured overlap step. Seat all four pins
   in finished holes before drilling again.
7. Repeat the tile placements across the board. A partial final tile handles
   the outer rows and columns.

The browser walkthrough builds this placement sequence from board and tile
settings, highlights the current guide positions, and reports how many holes
are covered by the plan.

## Print and fit decisions

- Printer envelope: Bambu Lab A1 mini, 180×180×180 mm.
- Default indexing body: 170×170×14 mm; 5 mm nominal bed-edge margin.
- Starter plate: 115×115×14 mm; fence: 119×119×26 mm.
- Four pin inserts print as a separate set, 68×14×17.6 mm in the default
  arrangement.
- A metal 12 mm OD / 10 mm ID bush is the default twist-drill guide.
- The printed bush seat and pin sockets remain adjustable for the actual
  filament, printer, and purchased bush.

The browser configurator updates the demonstration model and downloads a JSON
settings summary. The bundled STL files are the default profile; custom print
geometry comes from the parametric OpenSCAD sources.

## Validation and next work

OpenSCAD generated the current default STL files as manifold solids. That
checks the model construction, not the real printed fits or drilling accuracy.
The first physical prototype should check the bush seat, pin fit, fence
alignment, and clamp access, followed by an alignment run on scrap plywood.
Those measurements can then tune the shared parameters.

The next cutter profile should treat a Forstner bit or hole saw as a separate
guide system: guide the centre pilot while leaving clearance for the larger
cutting head. The twist-drill profile remains the initial v3 scope.
