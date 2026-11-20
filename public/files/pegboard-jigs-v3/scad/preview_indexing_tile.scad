// Visual assembly preview only; export body and pin set separately.
include <params.scad>

color("#45634c") import("../stl/indexing_tile.stl");

module installed_pin() {
    rotate([180, 0, 0]) {
        cylinder(d = pin_head_d, h = pin_head_h);
        translate([0, 0, pin_head_h])
            cylinder(d = pin_d, h = base_t + pin_len - pin_chamfer_h);
        translate([0, 0, pin_head_h + base_t + pin_len - pin_chamfer_h])
            cylinder(d1 = pin_d,
                     d2 = pin_d - 2 * pin_chamfer_radial,
                     h = pin_chamfer_h);
    }
}

for (p = index_pin_points)
    translate([p[0], p[1], base_t + pin_head_h])
        color("#397d89") installed_pin();
