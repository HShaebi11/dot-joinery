// ============================================================================
//  PIN INSERT — Proposal 5 (convertible jig), print 2
//  Drops into any guide socket: Ø11.8 plug seats in the Ø11.9 bush seat,
//  Ø9.8 pin hangs below into the drilled hole. Flange stays on top.
//  Bore stack it passes through: base_t 6 + boss_h 8 = 14mm, then
//  pin_len 10 below the plate face.
//  PRINT: as modelled — flange on the bed, pin as a tower. No supports.
// ============================================================================
include <params.scad>

flange_d = 18;
flange_t = 3;
plug_d   = 11.8;
plug_h   = bush_seat_h;              // 8 — fills the bush seat
stack    = base_t + boss_h;          // 14 — bore depth the pin traverses

module pin_insert() {
    cylinder(d = flange_d, h = flange_t - 0.8);                 // flange (on bed)
    translate([0, 0, flange_t - 0.8])
        cylinder(d1 = flange_d, d2 = flange_d - 1.6, h = 0.8);  // edge break
    translate([0, 0, flange_t])
        cylinder(d = plug_d, h = plug_h);                       // plug
    translate([0, 0, flange_t + plug_h]) {
        cylinder(d = pin_d, h = stack + pin_len - chamfer_h);   // pin shaft
        translate([0, 0, stack + pin_len - chamfer_h])
            cylinder(d1 = pin_d, d2 = pin_d - 2 * chamfer_d,
                     h = chamfer_h);                            // lead-in
    }
}

pin_insert();
