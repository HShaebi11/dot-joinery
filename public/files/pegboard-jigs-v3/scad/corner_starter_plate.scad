// V3 CORNER STARTER PLATE
// Four metal-bushed guides make the matching 2x2 locating pattern.
include <params.scad>

notch_centres = starter_tab_positions;

module guide_boss(x, y) {
    translate([x, y, base_t]) cylinder(d = boss_d, h = boss_h);
}

module guide_bore(x, y) {
    translate([x, y, base_t + boss_h - bush_seat_h])
        cylinder(d = bush_seat_d, h = bush_seat_h + 0.02);
    translate([x, y, -0.01])
        cylinder(d = bit_clear_d, h = base_t + boss_h + 0.02);
}

module corner_starter_plate() {
    difference() {
        union() {
            cube([starter_reach, starter_reach, base_t]);
            for (p = seed_points) guide_boss(p[0], p[1]);
        }

        for (p = seed_points) guide_bore(p[0], p[1]);

        // Clamp holes sit beyond the seed square.
        translate([starter_clamp_x, edge_offset, -0.01])
            cylinder(d = clamp_hole_d, h = base_t + 0.02);
        translate([edge_offset, starter_clamp_y, -0.01])
            cylinder(d = clamp_hole_d, h = base_t + 0.02);

        // Two matching tab pockets along each panel edge.
        for (c = notch_centres) {
            translate([-0.01, c - notch_w / 2, -0.01])
                cube([notch_d + 0.01, notch_w, base_t + 0.02]);
            translate([c - notch_w / 2, -0.01, -0.01])
                cube([notch_w, notch_d + 0.01, base_t + 0.02]);
        }
    }
}

corner_starter_plate();
