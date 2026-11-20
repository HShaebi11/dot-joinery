// ============================================================================
//  INDEXING BAR — repeats the 50mm hole pattern along a row or column
//  For drilling the hole grid of an 18mm plywood pegboard panel.
//
//  Pattern assumed: 10mm holes on a 50mm grid.
//
//  Coordinate convention (matches the other jigs in this folder):
//    - Panel top surface  = z = 0   (bar base sits on this plane)
//    - Bar axis            = local +x   (bar width along y, centred on y = 0)
//    - Locating pins hang BELOW the base (z < 0) and drop into drilled holes.
//
//  Layout along the bar — five stations on one 50mm pitch:
//      x = 0      locating pin 1
//      x = 50     locating pin 2
//      x = 100    drill guide 1
//      x = 150    drill guide 2
//      x = 200    drill guide 3
//
//  How it works (row-major example):
//    1. Drop the two pins into two adjacent holes that are already drilled
//       (the seed pair from the corner jig or the row seeder).
//    2. Drill through the three bush-guided holes -> three new holes.
//    3. Lift the bar, move it forward, and re-seat the pins in the TWO MOST
//       RECENTLY DRILLED holes (i.e. leapfrog 150mm each step).
//    4. Repeat to the end of the row. Flip the bar end-for-end to walk the
//       other direction; rotate it 90 deg to index a column instead.
//
//  NOTE: needs ~230mm of print bed in X for 3 guides (~180mm for 2).
//  All dimensions are parameters below.
//
//  PRINT: FLIP the part upside-down before slicing so the pins point UP.
//  Pins then print last as clean vertical posts — no supports, no brim
//  needed for the pins (a brim is still cheap insurance on the bosses).
// ============================================================================

// ------------------------- PATTERN -------------------------
pitch   = 50;    // [mm] hole grid spacing
hole_d  = 10;    // [mm] drilled hole / bit size (for reference)

// --------------------- LOCATING PINS (underside) --------------------
// Pins drop into already-drilled holes. Slightly undersized for a snug fit.
pin_d      = 9.8;  // [mm] pin diameter — snug in a 10mm hole.
                   //   rattly -> try 9.9 ;  won't enter -> try 9.5
pin_len    = 10;   // [mm] pin engagement depth below the base
pin_embed  = 3;    // [mm] pin root embedded inside the base
chamfer_h  = 1.2;  // [mm] lead-in chamfer height at the pin tip
chamfer_d  = 0.7;  // [mm] radial chamfer size at the pin tip

// --------------------- DRILL GUIDES / METAL BUSH --------------------
// Bush: 12mm OD, 10mm ID for a 10mm drill bit.
bush_od     = 12;    // [mm] bush outside diameter (reference only)
bush_hole_d = 11.9;  // [mm] seat diameter — press fit into PLA/PETG.
                     //   too tight  -> try 11.7
                     //   slip+glue  -> try 12.1
bit_clear_d = 10.4;  // [mm] bit clearance hole (0.2mm/side)
bush_seat_h = 8;     // [mm] counterbore depth inside the boss
boss_od     = 24;    // [mm] boss diameter around each guide
boss_h      = 8;     // [mm] boss height above the base

// ------------------------------ BODY -------------------------------
base_t   = 6;               // [mm] base plate thickness
bar_w    = 50;              // [mm] bar width
start_m  = 12;              // [mm] margin before the first pin
guide_count = 3;            // [count] drill guides on the bar.
                            //   3 -> ~230mm long (needs a big bed)
                            //   2 -> ~180mm long (fits A1-mini class beds)
end_m    = boss_od / 2 + 4; // [mm] margin after the last guide boss

// ---------------------------- COMPUTED -----------------------------
pin_xs   = [0, pitch];                    // pin stations
lead_x   = 2 * pitch;                     // first guide station
guide_xs = [for (i = [0 : guide_count - 1]) lead_x + i * pitch];
x_min    = -start_m;
x_max    = guide_xs[guide_count - 1] + end_m;

assert(pin_d < hole_d, "pins must be smaller than the drilled holes");
assert(guide_count >= 2, "need at least 2 guides so the leapfrog always works");
assert(bush_hole_d > bit_clear_d, "bush seat must be larger than bit clearance");
assert(bush_seat_h <= boss_h, "bush seat deeper than boss");

module locating_pin(x) {
    // shaft: z from -pin_len + chamfer_h up to +pin_embed
    translate([x, 0, -pin_len + chamfer_h])
        cylinder(d = pin_d, h = pin_len + pin_embed - chamfer_h);
    // lead-in chamfer: z from -pin_len up to -pin_len + chamfer_h
    translate([x, 0, -pin_len])
        cylinder(d1 = pin_d - 2 * chamfer_d, d2 = pin_d, h = chamfer_h);
}

module indexing_bar() {
    difference() {
        union() {
            // ---- base plate ----
            translate([x_min, -bar_w / 2, 0])
                cube([x_max - x_min, bar_w, base_t]);

            // ---- locating pins (point down into the holes) ----
            for (px = pin_xs) locating_pin(px);

            // ---- guide bosses ----
            for (gx = guide_xs)
                translate([gx, 0, base_t])
                    cylinder(d = boss_od, h = boss_h);
        }

        // ---- stepped guide holes: bush seat on top, bit clearance below ----
        for (gx = guide_xs) {
            translate([gx, 0, base_t + boss_h - bush_seat_h])
                cylinder(d = bush_hole_d, h = bush_seat_h + 0.02);
            translate([gx, 0, -0.01])
                cylinder(d = bit_clear_d, h = base_t + boss_h + 0.02);
        }
    }
}

indexing_bar();
