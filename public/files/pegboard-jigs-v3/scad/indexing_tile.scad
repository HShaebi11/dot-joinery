// V3 INDEXING TILE
// Four removable pins match the corner starter's 2x2 seed. Every other
// station in the tile is a drill guide. The body prints flat, bosses up.
include <params.scad>

module rib_x(y, x0, x1) {
    translate([(x0 + x1) / 2, y, base_t / 2])
        cube([x1 - x0, rib_w, base_t], center = true);
}

module rib_y(x, y0, y1) {
    translate([x, (y0 + y1) / 2, base_t / 2])
        cube([rib_w, y1 - y0, base_t], center = true);
}

module ribbed_plate() {
    union() {
        // Perimeter rails
        translate([(index_x0 + index_x1) / 2, index_y0 + border_w / 2, base_t / 2])
            cube([index_size_x, border_w, base_t], center = true);
        translate([(index_x0 + index_x1) / 2, index_y1 - border_w / 2, base_t / 2])
            cube([index_size_x, border_w, base_t], center = true);
        translate([index_x0 + border_w / 2, (index_y0 + index_y1) / 2, base_t / 2])
            cube([border_w, index_size_y, base_t], center = true);
        translate([index_x1 - border_w / 2, (index_y0 + index_y1) / 2, base_t / 2])
            cube([border_w, index_size_y, base_t], center = true);

        // Stiffening ribs run through each grid station.
        for (i = [0 : index_cols - 1]) rib_y(i * grid_pitch, index_y0, index_y1);
        for (j = [0 : index_rows - 1]) rib_x(j * grid_pitch, index_x0, index_x1);
    }
}

module guide_boss(x, y) {
    translate([x, y, base_t]) cylinder(d = boss_d, h = boss_h);
}

module pin_pad(x, y) {
    translate([x, y, base_t]) cylinder(d = pin_pad_d, h = pin_head_h);
}

module guide_bore(x, y) {
    translate([x, y, base_t + boss_h - bush_seat_h])
        cylinder(d = bush_seat_d, h = bush_seat_h + 0.02);
    translate([x, y, -0.01])
        cylinder(d = bit_clear_d, h = base_t + boss_h + 0.02);
}

module pin_socket(x, y) {
    translate([x, y, -0.01])
        cylinder(d = pin_mount_d, h = base_t + 0.02);
    translate([x, y, base_t - 0.01])
        cylinder(d = pin_head_recess_d, h = pin_head_h + 0.02);
}

module indexing_tile() {
    difference() {
        union() {
            ribbed_plate();
            for (p = index_pin_points) pin_pad(p[0], p[1]);
            for (p = index_guide_points) guide_boss(p[0], p[1]);
        }
        for (p = index_guide_points) guide_bore(p[0], p[1]);
        for (p = index_pin_points) pin_socket(p[0], p[1]);
    }
}

indexing_tile();
