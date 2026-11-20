// ============================================================================
//  RAIL KEY — Proposal 4 lock peg (print 2)
//  Drops through the carriage lock hole into the rail detent.
//  PRINT: standing on the head. Tiny footprint — use a brim.
// ============================================================================
include <params.scad>

module rail_key() {
    cylinder(d = 10, h = 2.2);                     // finger head
    translate([0, 0, 2.2])
        cylinder(d1 = 10, d2 = 8, h = 0.8);        // edge break
    translate([0, 0, 3])
        cylinder(d = 6.0, h = 9);                // shaft into Ø6.2/6.3 holes
    translate([0, 0, 12])
        cylinder(d1 = 6.0, d2 = 4.6, h = 1.2);   // lead-in
}

rail_key();
