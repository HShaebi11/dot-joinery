// ============================================================================
//  ROW SEEDER — creates the two seed holes that start each new row/column
//  For drilling the hole grid of an 18mm plywood pegboard panel.
//
//  Pattern assumed: 10mm holes on a 50mm grid.
//
//  Coordinate convention (matches the other jigs in this folder):
//    - Panel top surface  = z = 0
//    - The seeder's locating pin sits at local (0, 0) and drops into a hole
//      that is ALREADY drilled. The three guide positions are relative to it:
//
//          A = (0,  +pitch)      row mode:  left seed of the new row
//          B = (+pitch, +pitch)  BOTH modes: diagonal seed
//          C = (+pitch, 0)       column mode: lower seed of the new column
//
//    Row-major use:    bushes in A + B  -> drills the seed pair for a new row
//    Column-major use: bushes in B + C  -> drills the seed pair for a new col
//    (all three positions have bush seats; the unused one just sits idle)
//
//  How it works:
//    - After a row is finished, the hole directly "above" the seeder pin
//      (previous row, same column) already exists. Drop the pin in it and the
//      two guides land exactly on the next row's first two grid positions.
//    - No measuring, no edge fences — the pin IS the reference.
//    - Rotate the seeder 180 deg to seed rows in the opposite direction.
//
//  PRINT: FLIP the part upside-down before slicing so the pin points UP —
//  it then prints last as a clean vertical post. No supports needed.
// ============================================================================

// ------------------------- PATTERN -------------------------
pitch  = 50;   // [mm] hole grid spacing
hole_d = 10;   // [mm] drilled hole / bit size (for reference)

// --------------------- LOCATING PIN (underside) --------------------
pin_d      = 9.8;  // [mm] pin diameter — snug in a 10mm hole
pin_len    = 10;   // [mm] pin engagement depth below the base
pin_embed  = 3;    // [mm] pin root embedded inside the base
chamfer_h  = 1.2;  // [mm] lead-in chamfer height at the pin tip
chamfer_d  = 0.7;  // [mm] radial chamfer size at the pin tip

// --------------------- DRILL GUIDES / METAL BUSH --------------------
bush_od     = 12;    // [mm] bush outside diameter (reference only)
bush_hole_d = 11.9;  // [mm] seat diameter — press fit into PLA/PETG
bit_clear_d = 10.4;  // [mm] bit clearance hole (0.2mm/side)
bush_seat_h = 8;     // [mm] counterbore depth inside the boss
boss_od     = 24;    // [mm] boss diameter around each guide
boss_h      = 8;     // [mm] boss height above the base

// ------------------------------ BODY -------------------------------
base_t  = 5;                          // [mm] base plate thickness
margin  = boss_od / 2 + 6;            // [mm] plate margin around features
plate_x0 = -margin;                   // plate extent (pin sits at 0,0)
plate_x1 = pitch + margin;
plate_y0 = -margin;
plate_y1 = pitch + margin;

// ---------------------------- COMPUTED -----------------------------
// guide stations relative to the pin at (0,0)
A = [0,        pitch];
B = [pitch,    pitch];
C = [pitch,    0];
guide_pts = [A, B, C];

assert(pin_d < hole_d, "pin must be smaller than the drilled holes");
assert(bush_hole_d > bit_clear_d, "bush seat must be larger than bit clearance");
assert(bush_seat_h <= boss_h, "bush seat deeper than boss");

module locating_pin(x, y) {
    // shaft: z from -pin_len + chamfer_h up to +pin_embed
    translate([x, y, -pin_len + chamfer_h])
        cylinder(d = pin_d, h = pin_len + pin_embed - chamfer_h);
    // lead-in chamfer: z from -pin_len up to -pin_len + chamfer_h
    translate([x, y, -pin_len])
        cylinder(d1 = pin_d - 2 * chamfer_d, d2 = pin_d, h = chamfer_h);
}

module row_seeder() {
    difference() {
        union() {
            // ---- base plate ----
            translate([plate_x0, plate_y0, 0])
                cube([plate_x1 - plate_x0, plate_y1 - plate_y0, base_t]);

            // ---- locating pin (point down into the reference hole) ----
            locating_pin(0, 0);

            // ---- guide bosses ----
            for (g = guide_pts)
                translate([g[0], g[1], base_t])
                    cylinder(d = boss_od, h = boss_h);
        }

        // ---- stepped guide holes: bush seat on top, bit clearance below ----
        for (g = guide_pts) {
            translate([g[0], g[1], base_t + boss_h - bush_seat_h])
                cylinder(d = bush_hole_d, h = bush_seat_h + 0.02);
            translate([g[0], g[1], -0.01])
                cylinder(d = bit_clear_d, h = base_t + boss_h + 0.02);
        }
    }
}

row_seeder();
