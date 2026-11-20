// ============================================================================
//  RAIL CARRIAGE — Proposal 4
//  Drops over the rail beam: a 12.6 x 8.6 channel in the bottom face
//  straddles the 12 x 8 track. Bush seat + bore at centre. Lock hole
//  takes rail_key.
//  PRINT: as modelled — slot faces the bed; the 12.6mm tunnel roof
//  bridges in one layer. No supports.
// ============================================================================
include <params.scad>
include <frame.scad>

block_x = 34;         // along the rail
block_y = 30;         // across the rail
block_z = 18;
slot_w  = 12.6;       // rail beam 12 + 0.6 clearance
slot_d  = 8.6;        // rail beam 8 + 0.6 clearance
lock_d  = 6.2;

module rail_carriage() {
    difference() {
        intersection() {
            translate([0, 0, block_z/2])
                rounded_box([block_x, block_y, block_z], corner_r_s);
            rounded_outline(-block_x / 2, -block_y / 2,
                            block_x / 2, block_y / 2, block_z,
                            corner_r_s);
        }
        // bottom slot that straddles the rail (open at z=0 face)
        translate([-block_x / 2 - 0.01, -slot_w / 2, -0.01])
            cube([block_x + 0.02, slot_w, slot_d]);
        // drill bore + bush seat
        translate([0, 0, -0.01])
            cylinder(d = bit_clear_d, h = block_z + 0.02);
        translate([0, 0, block_z - bush_seat_h])
            cylinder(d = bush_hole_d, h = bush_seat_h + 0.02);
        // lock key hole (through top into the slot)
        translate([block_x / 2 - 6, 0, slot_d])
            cylinder(d = lock_d, h = block_z - slot_d + 0.02);
    }
}

rail_carriage();
