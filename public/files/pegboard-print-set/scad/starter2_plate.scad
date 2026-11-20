// ============================================================================
//  STARTER 2x2 PLATE — ribbed corner seed jig for Proposals 1, 2, 4, 5
//  (also serves as the Proposal 5 convertible body — pin inserts drop
//  into any bush seat)
//  Ribbed frame version: ~55% less plastic than the solid plate.
//  PRINT: flat side down, bosses up. No supports.
// ============================================================================
include <params.scad>
include <frame.scad>

seed_cols = 2;
seed_rows = 2;

span    = edge_offset + (max(seed_cols, seed_rows) - 1) * pitch; // 75
clamp_p = span + clamp_gap;                                      // 100
reach   = clamp_p + edge_margin;                                 // 115
tab_pos = [for (f = tab_frac) f * reach];
screw_pos = screw_stations(reach, tab_pos);
xs = [for (i = [0 : seed_cols - 1]) edge_offset + i * pitch];    // 25, 75
ys = xs;

module starter2_plate() {
    difference() {
        union() {
            rib_plate(0, 0, reach, reach, xs, ys);
            // pads under the clamp holes (they sit in window cells)
            translate([clamp_p - 10, edge_offset - rib_w / 2, 0])
                cube([20, rib_w, base_t]);
            translate([edge_offset - rib_w / 2, clamp_p - 10, 0])
                cube([rib_w, 20, base_t]);
            for (x = xs, y = ys) guide_boss(x, y);
        }
        for (x = xs, y = ys) guide_bores(x, y);
        translate([clamp_p, edge_offset, -0.01])
            cylinder(d = clamp_hole_d, h = base_t + 0.02);
        translate([edge_offset, clamp_p, -0.01])
            cylinder(d = clamp_hole_d, h = base_t + 0.02);
        for (c = tab_pos) {
            translate([0, c - notch_w / 2, -0.01])
                cube([notch_d, notch_w, base_t + 0.02]);
            translate([c - notch_w / 2, 0, -0.01])
                cube([notch_w, notch_d, base_t + 0.02]);
        }
        // M3 pilot holes for the fence screws — into the solid edge band
        for (sy = screw_pos) {
            translate([-0.5, sy, screw_z])
                rotate([0, 90, 0])
                    cylinder(d = screw_pilot, h = screw_depth + 0.5);
            translate([sy, -0.5, screw_z])
                rotate([-90, 0, 0])
                    cylinder(d = screw_pilot, h = screw_depth + 0.5);
        }
    }
}

starter2_plate();
