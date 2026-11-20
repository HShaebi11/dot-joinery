// ============================================================================
//  CORNER BASE — plate half of the two-piece corner first-hole jig
//  For drilling the hole grid of an 18mm plywood pegboard panel.
//
//  Pattern assumed: 10mm holes on a 50mm grid, first hole 25mm from each edge.
//
//  Coordinate convention (matches the other jigs in this folder):
//    - Panel top surface  = z = 0   (plate bottom sits on this plane)
//    - Panel interior     = x > 0, y > 0   (panel corner at the origin)
//    - Plate edges at x = 0 and y = 0 are FLUSH with the panel edge faces.
//
//  This is the flat-printing half: it lies flat on the bed, bosses up,
//  no supports, no bridging. It mates with corner_fence.scad via six
//  edge notch pockets (the fence's tabs drop in — see that file).
//  Assemble with a thin film of CA glue; the notches self-align the fence.
//
//  Joint dimensions MUST match corner_fence.scad — keep them in sync.
// ============================================================================

// ------------------------- PANEL / PATTERN -------------------------
edge_offset = 25;   // [mm] first hole centre distance from each edge
pitch       = 50;   // [mm] hole grid spacing
panel_t     = 18;   // [mm] plywood thickness (fence reaches this far below z=0)

// --------------------------- SEED GUIDES ---------------------------
// 2x2 (default) seeds rows AND columns; 2x1 = row pair; 1x1 = single.
seed_cols = 2;
seed_rows = 2;

// --------------------- DRILL GUIDES / METAL BUSH --------------------
bush_od     = 12;    // [mm] bush outside diameter (reference only)
bush_hole_d = 11.9;  // [mm] seat diameter — press fit into PLA/PETG.
                     //   too tight  -> try 11.7 ;  slip+glue -> try 12.1
bit_clear_d = 10.4;  // [mm] bit clearance hole through the plate (0.2mm/side)
bush_seat_h = 8;     // [mm] counterbore depth inside the boss
boss_od     = 26;    // [mm] boss diameter around each guide
boss_h      = 8;     // [mm] boss height above the plate

// ------------------------------ BODY -------------------------------
plate_t      = 5;    // [mm] base plate thickness
clamp_hole_d = 6;    // [mm] clamp hole diameter (M6 bolt / holdfast / dog)
clamp_gap    = 25;   // [mm] clamp holes sit this far beyond the guide field
edge_margin  = 15;   // [mm] plate edge margin past the clamp holes

// --------------------- FENCE JOINT (notches) ------------------------
// Pockets cut into the x=0 and y=0 edges; the fence tabs (corner_fence.scad)
// drop in. notch_d > tab reach, notch_w > tab_w, full plate thickness.
notch_d    = 8.4;    // [mm] notch depth into the plate edge
notch_w    = 12;     // [mm] notch width along the edge
                     //   (tab_w=10 -> 1mm clearance per side)
tab_frac   = [0.18, 0.5, 0.82];  // notch/tab positions as fractions of reach

// ---------------------------- COMPUTED -----------------------------
span_x  = edge_offset + (seed_cols - 1) * pitch;
span_y  = edge_offset + (seed_rows - 1) * pitch;
span    = max(span_x, span_y);
clamp_p = span + clamp_gap;
reach   = clamp_p + edge_margin;   // plate extent from the corner
tab_pos = [for (f = tab_frac) f * reach];

assert(seed_cols >= 1 && seed_rows >= 1, "seed_cols / seed_rows must be >= 1");
assert(bush_hole_d > bit_clear_d, "bush seat must be larger than bit clearance");
assert(bush_seat_h <= boss_h, "bush seat deeper than boss");
assert(notch_w > 10, "notch_w must exceed tab_w=10");

module corner_base() {
    difference() {
        union() {
            // ---- base plate: sits on panel top, z = 0..plate_t ----
            // x,y in [0, reach] — edges flush with the panel edge faces
            cube([reach, reach, plate_t]);

            // ---- guide bosses ----
            for (i = [0 : seed_cols - 1])
                for (j = [0 : seed_rows - 1])
                    translate([edge_offset + i * pitch,
                               edge_offset + j * pitch,
                               plate_t])
                        cylinder(d = boss_od, h = boss_h);
        }

        // ---- bush seats (counterbore) + bit clearance ----
        for (i = [0 : seed_cols - 1])
            for (j = [0 : seed_rows - 1]) {
                translate([edge_offset + i * pitch,
                           edge_offset + j * pitch,
                           plate_t + boss_h - bush_seat_h])
                    cylinder(d = bush_hole_d, h = bush_seat_h + 0.02);
                translate([edge_offset + i * pitch,
                           edge_offset + j * pitch,
                           -0.01])
                    cylinder(d = bit_clear_d, h = plate_t + boss_h + 0.02);
            }

        // ---- clamp holes through the plate ----
        translate([clamp_p, edge_offset, -0.01])
            cylinder(d = clamp_hole_d, h = plate_t + 0.02);
        translate([edge_offset, clamp_p, -0.01])
            cylinder(d = clamp_hole_d, h = plate_t + 0.02);

        // ---- edge notches for the fence tabs (x=0 and y=0 edges) ----
        for (c = tab_pos) {
            // notch into the x = 0 edge
            translate([0, c - notch_w / 2, -0.01])
                cube([notch_d, notch_w, plate_t + 0.02]);
            // notch into the y = 0 edge
            translate([c - notch_w / 2, 0, -0.01])
                cube([notch_w, notch_d, plate_t + 0.02]);
        }
    }
}

corner_base();
