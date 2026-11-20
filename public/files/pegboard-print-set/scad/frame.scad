// ============================================================================
//  RIBBED FRAME HELPER — replaces a solid plate with border + grid ribs.
//  Same stiffness where it matters (bosses clamped flat), ~half the plastic.
// ============================================================================

rib_w    = 10;   // [mm] grid rib width
border_w = 10;   // [mm] perimeter border width

// Plan-view rounded rectangle prism — trims vertical edges to radius r.
// Inset polygon + offset(r) keeps the flat edges on x0/x1/y0/y1.
module rounded_outline(x0, y0, x1, y1, h, r = corner_r) {
    translate([0, 0, -0.05])
        linear_extrude(h + 0.1)
            offset(r = r)
                polygon([[x0 + r, y0 + r],
                         [x1 - r, y0 + r],
                         [x1 - r, y1 - r],
                         [x0 + r, y1 - r]]);
}

// Rounded box helper for external edges. Keep radii small to preserve fits.
module rounded_box(size, r = edge_break) {
    // 2D rounded footprint extruded to preserve exact outer dimensions.
    translate([0,0,-size[2]/2]) linear_extrude(size[2])
        offset(r=r) square([size[0]-2*r,size[1]-2*r],center=true);
}

// x0,y0,x1,y1 = plate extent; xs/ys = station coordinates the ribs run through
module rib_plate(x0, y0, x1, y1, xs, ys) {
    intersection() {
        union() {
        // border ring
        translate([(x0+x1)/2, y0+border_w/2, base_t/2]) rounded_box([x1-x0,border_w,base_t]);
        translate([(x0+x1)/2, y1-border_w/2, base_t/2]) rounded_box([x1-x0,border_w,base_t]);
        translate([x0+border_w/2, (y0+y1)/2, base_t/2]) rounded_box([border_w,y1-y0,base_t]);
        translate([x1-border_w/2, (y0+y1)/2, base_t/2]) rounded_box([border_w,y1-y0,base_t]);
        // ribs through each station row/column
        for (y = ys)
            translate([(x0+x1)/2, y, base_t/2])
                rounded_box([x1-x0, rib_w, base_t]);
        for (x = xs)
            translate([x, (y0+y1)/2, base_t/2])
                rounded_box([rib_w, y1-y0, base_t]);
        }
        rounded_outline(x0, y0, x1, y1, base_t);
    }
}

module pin_post(x, y) {
    translate([x, y, base_t - pin_embed]) {
        cylinder(d = pin_d, h = pin_embed + pin_len - chamfer_h);
        translate([0, 0, pin_embed + pin_len - chamfer_h])
            cylinder(d1 = pin_d, d2 = pin_d - 2 * chamfer_d, h = chamfer_h);
    }
}

module guide_boss(x, y) {
    translate([x, y, base_t])
        cylinder(d = boss_od, h = boss_h);
}

module guide_bores(x, y) {
    translate([x, y, base_t + boss_h - bush_seat_h])
        cylinder(d = bush_hole_d, h = bush_seat_h + 0.02);
    translate([x, y, -0.01])
        cylinder(d = bit_clear_d, h = base_t + boss_h + 0.02);
}
