# Pegboard Jig Print Set — Bambu A1 mini slicing guide

Print-ready parts for all five proposals from the explorer (`pegboard-saddle-jig`).
Everything is modelled **already in print orientation** — no rotations needed in
the slicer, and **no supports anywhere**. Parts are split so nothing has to
print as one overhanging object, and the big plates are **ribbed frames**
(bosses + ribs, not solid slabs) to keep time and material down.

Pattern: **10mm holes, 50mm grid, 18mm plywood, 25mm edge offset**
(same as `pegboard-drilling-jigs`).

## Profile used (verified by actually slicing every part)

- Printer: **Bambu Lab A1 mini, 0.4 nozzle** (180×180 bed — largest part is 169mm)
- Process: **`profiles/jig_max_028_A1M.json`** — fully flattened profile
  (no `inherits`, so every value is explicit — BambuStudio's CLI does not
  resolve inheritance for file-based profiles). 0.28mm layers, **4 walls**,
  **20% gyroid** infill, ~160mm/s print speeds, arachne wall generator.
- Filament: **`profiles/jig_pla_a1m.json`** — Bambu PLA Basic values with
  225°C nozzle for better layer bonding. (The stock profile reports
  200°C / 12mm³/s, which starves fast printing.)
- G-code for this profile lives in **`gcode_jigmax/`**; `gcode/` keeps the
  older `fast_jig` slices for comparison.

## Parts → proposals (sliced G-code included in `gcode_jigmax/`)

| STL | Proposals | Print notes | Size mm | Time | PLA |
|---|---|---|---|---|---|
| `starter2_plate` | 1, 2, 4, 5 (starter / P5 body) | flat, bosses up | 115×115×6 | **2h 02m** | ~46g |
| `starter2_fence` | 1, 2, 4, 5 | walls on bed, **brim** | 119×119×32 | **55m** | ~34g |
| `leapfrog_bar` | 1 | pins up | 131×44×16 | **56m** | ~28g |
| `row_bridge` | 1, 2 | pins up | 86×86×16 | **1h 18m** | ~32g |
| `starter3_plate` | 3 | flat, bosses up | 165×165×14 | **3h 50m** | ~89g |
| `starter3_fence` | 3 | walls on bed, **brim** | 169×169×32 | **1h 11m** | ~48g |
| `grid_tile` | 3 | pins up | 136×136×16 | **2h 56m** | ~71g |
| `rail_frame` | 4 | pins up | 120×63×16 | **50m** | ~23g |
| `rail_carriage` | 4 | as exported; one 12.6mm bridge | 34×30×18 | **25m** | ~10g |
| `rail_key` ×2 | 4 | standing on head, **brim** | 12×12×13 | **4m** ea | ~1g |
| `pin_insert` ×2 | 5 | flange on bed, pin tower | 25×25×35 | **15m** ea | ~3g |

## Per-proposal kits

| Proposal | Parts | Total time | Total PLA |
|---|---|---:|---:|
| **1 — Leapfrog bar** | starter2 plate + fence + bar + bridge | **~5h 10m** | ~140g |
| **2 — Row bridge** | starter2 plate + fence + bridge | **~4h 15m** | ~112g |
| **3 — Grid tile** | starter3 plate + fence + tile | **~7h 55m** | ~208g |
| **4 — Indexed rail** | starter2 plate + fence + frame + carriage + 2 keys | **~4h 20m** | ~114g |
| **5 — Convertible** | starter2 plate + fence + 2 pin inserts | **~3h 25m** | ~86g |

All 11 parts together: **~15h** (was ~37h on the old `gcode/` slices) — the
extra wall loop + denser infill costs ~25% more filament but cuts print time
~60% *and* is stronger. `gcode/` still holds the leaner `fast_jig` variants
if you want minimum material instead.

## The exact CLI command (per part)

```sh
B=/Applications/BambuStudio.app/Contents/MacOS/BambuStudio
S="$HOME/Library/Application Support/BambuStudio/system/BBL"
M="$S/machine/Bambu Lab A1 mini 0.4 nozzle.json;$PWD/profiles/jig_max_028_A1M.json"
F="$PWD/profiles/jig_pla_a1m.json"
"$B" --slice 0 --arrange 1 --load-settings "$M" --load-filaments "$F" \
     --outputdir "gcode_jigmax/<part>" stl/<part>.stl
```

Batch:

```sh
for f in stl/*.stl; do n=$(basename "$f" .stl); mkdir -p "gcode_jigmax/$n"
  "$B" --slice 0 --arrange 1 --load-settings "$M" --load-filaments "$F" \
       --outputdir "gcode_jigmax/$n" "$f"; done
```

## Assembly notes

- **Bushes:** press 12mm OD / 10mm ID metal bushes into the Ø11.9 seats until
  they bottom on the Ø10.4 shoulder. Slip fit → raise `bush_hole_d` to 12.1 and
  add CA. PLA is brittle at these walls — press slowly, warm the boss if tight.
- **Pins** (bar/bridge/tile/frame): integral, printed as posts. In use they
  point DOWN into drilled holes — flip the part after printing. Sand the
  lead-in chamfer if they bind; drill a test hole first.
- **Starter fence → plate:** tabs locate in the edge notches; fit M3 × 12 mm
  pan-head/self-tapping screws through the fence clearance holes into the plate
  pilot holes. Tighten gently; PLA can split if overtightened. For a removable
  joint, use M3 machine screws with heat-set inserts installed in the plate
  (increase pilot/insert geometry before printing). The pilot holes are sized
  for self-tappers; do not force machine screws into them.
  `pin_insert` drops into any unused `starter2_plate` bush seat — Proposal 5's
  conversion needs zero extra hardware beyond 2 inserts.
- **Rail:** carriage drops over the y=50 track; `rail_key` pins it to the x=0
  or x=50 detent. Detents/keys are nominal — expect to sand the key.
- **Brim** matters most for: both fences, `rail_key`, `pin_insert`. Everything
  else has a fat footprint.

## Edit → re-export

All parametric sources are in `scad/` and share `params.scad` (pattern + fits)
and `frame.scad` (ribbed-plate + boss/pin modules):

```sh
~/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -o stl/<part>.stl scad/<part>.scad
```

## Honest caveats

- **Test `row_bridge` first** (3h, 25g): validates pin entry into a real
  drilled hole + bush press fit before committing to a full kit.
- The fast profile trades some toughness for time — fine for jigs, but don't
  lean the jig against a clamp crush; if a pin snaps, re-slice that part with
  `wall_loops` 4–5.
- Clearance, rail play and pin binding need a scrap-plywood dry run.
- Outer plate corners are rounded in plan view and small exposed corners have
  edge breaks to reduce sharp corners and ease fast printing. These are
  geometric corner treatments; they do not change functional locating faces,
  bush seats, or pin dimensions.
- Estimates are the slicer's own, A1 mini + PLA Basic.
