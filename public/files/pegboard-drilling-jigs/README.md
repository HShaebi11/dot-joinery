# Pegboard Drilling Jigs

Parametric 3D-printable jigs for drilling the hole grid of 18mm plywood
pegboard panels: **10mm holes on a 50mm grid, first hole 25mm from each edge**
(3,658 holes across your panels).

**v2 — clean-print edition.** The corner jig is now two flat-printing
pieces instead of one bridged part, and the pin parts print pins-up.
No supports anywhere in the system.

Sources exist in two forms: OpenSCAD (`.scad`, edit numbers → re-export
STL) and a Fusion 360 Python generator (`pegboard_jigs_fusion.py`).

## Parts

| File | Part | Size (approx) | Print volume |
|---|---|---|---|
| `corner_base.scad` | Corner jig — base plate | 115 × 115 × 13 mm | ~55 cm³ |
| `corner_fence.scad` | Corner jig — L fence | 119 × 119 × 32 mm | ~20 cm³ |
| `indexing_bar.scad` | Row indexing bar | 228 × 50 × 24 mm | ~77 cm³ |
| `row_seeder.scad` | Row/column seeder | 86 × 86 × 23 mm | ~45 cm³ |

STL files and preview PNGs are already rendered next to the sources.

### 1. Corner jig — two pieces (`corner_base` + `corner_fence`)

**Why two pieces:** the fence must reach 18mm *below* the panel-top plane
to bear on the panel's edge faces, so a one-piece jig can never print
flat — the plate would bridge ~110mm between the walls. Split version:
each piece prints clean with zero supports.

- **Base** (`corner_base`): flat plate with the seed-guide bosses, two
  clamp holes, and six notch pockets milled into its two edges. Prints
  flat, bosses up.
- **Fence** (`corner_fence`): two walls wrap the outside of the panel
  corner and bear against both edge faces (full 18mm of contact). Three
  tabs per wall reach inward and drop into the base's notches — the joint
  self-aligns the fence square to the plate.

**Assembly:** dry-fit the fence onto the base (tabs into notches), then a
thin film of CA glue on the tab/notch faces and the wall/plate edge
joint. It's a permanent tool — glue is the right call. If a tab is too
snug, sand it lightly; too loose, a wrap of tape while the glue sets.

Guide bosses take pressed-in **metal bushes (12mm OD / 10mm ID)** for a
10mm bit. Default `seed_cols = seed_rows = 2` drills a **2×2 seed block**
(25/75mm positions) which starts the indexing bar in *both* row and
column directions. Set `2×1` for a row pair only, `1×1` for a single hole.

**Keep the joint params in sync** between the two files: `notch_d`,
`notch_w`, `tab_frac` (base) vs `tab_in`, `tab_w`, `tab_t`, `tab_z0`,
`tab_frac` (fence). If you change `seed_cols/rows` or margins, `reach`
changes and tab positions move automatically — both files compute them
the same way.

### 2. Indexing bar (`indexing_bar.scad`)

Stations on one 50mm pitch: **pin, pin, guide × N** — pins at x = 0/50,
guides starting at x = 100.

- Two Ø9.8mm locating pins underneath drop into already-drilled holes.
- N bush-guided positions drill N new holes per placement
  (`guide_count = 3` default; set 2 for a ~180mm bar that fits
  A1-mini-class beds).
- Leapfrog rule: after each pass, re-seat the pins in the **two most
  recently drilled holes** and step forward.
- Flip end-for-end to walk the other direction; rotate 90° for columns.

### 3. Row seeder (`row_seeder.scad`)

Small triangle plate: one locating pin + three bush positions at
(0,+50), (+50,+50), (+50,0) relative to the pin.

Drop the pin into the hole directly "behind" the new row (previous row,
same column) and the two active guides land exactly on the new row's
first two grid positions — **no measuring, ever**. Rotate 180° to seed
the opposite direction; the B+C pair seeds columns for column-major work.

This third jig is my addition: the original two-jig spec had no way to
seed rows 2..N without measuring. With it, the whole panel is self-indexing.

## Workflow

1. **Corner jig** on the panel corner → drill the 2×2 seed block → remove.
2. **Indexing bar** pins into a seed pair → drill N holes → leapfrog
   forward → repeat to the end of the row.
3. **Row seeder** pin into the hole behind the next row → drill its two
   seed holes → back to the bar for that row.
4. Repeat row by row (or column by column) to the panel edges.

## Key parameters (same names in every file)

| Parameter | Default | Meaning |
|---|---|---|
| `pitch` | 50 | hole grid spacing (mm) |
| `edge_offset` | 25 | first hole distance from edges (mm) |
| `panel_t` | 18 | plywood thickness (mm) |
| `guide_count` | 3 | indexing-bar guides (bar.scad only) |
| `bush_hole_d` | 11.9 | bush seat Ø — press fit for 12mm-OD bush |
| `bit_clear_d` | 10.4 | bit clearance Ø below the bush seat |
| `bush_seat_h` | 8 | counterbore depth in each boss |
| `pin_d` | 9.8 | locating pin Ø — snug in 10mm holes |
| `pin_len` | 10 | pin engagement depth (mm) |
| `clamp_hole_d` | 6 | clamp hole Ø (corner base) |

### Fit tuning

- **Bush seats too tight / cracked:** raise `bush_hole_d` toward 12.1
  (slip fit + a drop of CA glue). Too loose: lower toward 11.7.
- **Pins rattly in holes:** raise `pin_d` to 9.9. Won't enter: lower to 9.5.
- **Fence tabs too snug:** increase `notch_w`/`notch_d` slightly in
  `corner_base.scad` (and matching `tab_w`/`tab_in` stays put) — or just
  sand the tabs. Too loose: decrease `notch_w`.
- **Different panel thickness:** set `panel_t` (corner fence reaches
  this far below the panel top; they assume the panel sits flat).
- **Different grid:** change `pitch` / `edge_offset` — the indexing bar's
  stations are all derived from `pitch`, but re-check pin/guide spacing
  stays on the grid.

## Print notes — the clean-print recipe

- **Material:** PLA or PETG, 4+ perimeters, ≥40% infill. PETG is tougher
  for the thin pin roots; PLA is fine.
- **Corner base:** as exported — flat side down, bosses up. Zero support.
- **Corner fence:** as exported — wall bottom edges on the bed.
  **Use a brim** — bed contact is two 4mm-wide strips. Zero support.
- **Indexing bar / row seeder:** **flip upside-down so the pins point
  UP** — pins then print last as clean vertical posts on top of the
  plate. No supports, no delicate first-layer pins. (Brim optional.)
- **Bushes:** press into the Ø11.9 seats from the top until they bottom
  on the Ø10.4 shoulder. A bush longer than the boss simply protrudes —
  that's good, more bit guidance.

## Honest caveats (carried over from the design spec)

- The **25mm edge offset is a prototype assumption** — confirm against
  your pegboard layout before drilling 3,658 holes. Change `edge_offset`
  everywhere if needed.
- Bush/pin fits are nominal — **test-print the seeder first** (smallest
  part) and check pin entry + bush press fit before printing the bar.
- The indexing scheme is verified geometrically (stations, spacing,
  leapfrog rule), but do a **dry run on scrap plywood** before committing
  a full panel — check for drift at row ends and panel far edges.
- The fence/base glue joint is strong for a jig but permanent — if a
  joint ever fails, re-print just that piece.

## Files

- `corner_base.scad`, `corner_fence.scad`, `indexing_bar.scad`,
  `row_seeder.scad` — parametric OpenSCAD sources (edit → re-export STL)
- `corner_base.stl`, `corner_fence.stl`, `indexing_bar.stl`,
  `row_seeder.stl` — ready to slice
- `pegboard_jigs_fusion.py` — **Fusion 360 version** of the same four
  bodies (already in your Fusion Scripts folder)
- `preview_assembly.scad/.png` — assembled system on a panel (reference)

## Fusion 360 version

`pegboard_jigs_fusion.py` builds all four bodies inside Fusion and
exports STLs to `fusion_stl/` (`Corner Base.stl`, `Corner Fence.stl`,
`Indexing Bar.stl`, `Row Seeder.stl`).

**To run:** Fusion 360 → Utilities → Scripts and Add-Ins (`Shift+S`) →
select `pegboard_jigs_fusion.py` → **Run**. A new design opens with the
four bodies laid out side by side.

All dimensions are the same named parameters at the top of the file
(millimetres), including `BAR_GUIDES` for the indexing bar. The script
sanity-checks each body's bounding box and warns if anything looks off
(e.g. a flipped sketch plane).

**Print orientation for the Fusion STLs is identical to the OpenSCAD
ones** — flip bar/seeder upside-down in the slicer so pins point up.

## Using the OpenSCAD files

OpenSCAD is installed at `~/Applications/OpenSCAD.app`. Open any `.scad`
file, tweak the parameters at the top, and export STL (F6) or use the
Customizer (F11) for a slider UI. `preview_assembly.scad` renders the
whole system on a panel for reference — not for printing.
