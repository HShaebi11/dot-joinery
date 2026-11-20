// ============================================================================
//  LEAPFROG BAR — Proposal 1 indexing bar
//  Stations: pin x=0, pin x=50, guide x=100. One new hole per placement.
//  PRINT: as modelled — pins point UP (they point down in use). No supports.
// ============================================================================
include <params.scad>
include <frame.scad>

bar_w   = 44;
start_m = 15;
end_m   = boss_od / 2 + 4;
x0 = -start_m;
x1 = 2 * pitch + end_m;   // last station (guide) + margin -> ~131mm

module pin_post(x, y) {
    translate([x, y, base_t - pin_embed]) {
        cylinder(d = pin_d, h = pin_embed + pin_len - chamfer_h);
        translate([0, 0, pin_embed + pin_len - chamfer_h])
            cylinder(d1 = pin_d, d2 = pin_d - 2 * chamfer_d, h = chamfer_h);
    }
}

module leapfrog_bar() {
    difference() {
        union() {
            intersection() {
                translate([(x0+x1)/2, 0, base_t/2])
                    rounded_box([x1-x0, bar_w, base_t]);
                rounded_outline(x0, -bar_w / 2, x1, bar_w / 2, base_t);
            }
            pin_post(0, 0);
            pin_post(pitch, 0);
            translate([2 * pitch, 0, base_t])
                cylinder(d = boss_od, h = boss_h);
        }
        translate([2 * pitch, 0, base_t + boss_h - bush_seat_h])
            cylinder(d = bush_hole_d, h = bush_seat_h + 0.02);
        translate([2 * pitch, 0, -0.01])
            cylinder(d = bit_clear_d, h = base_t + boss_h + 0.02);
        // lightening / grip cutouts along the web — kept clear of the
        // pins (Ø9.8 at x=0/50) and the guide boss (Ø24 at x=100)
        for (cx = [pitch / 2, 2 * pitch - 25])
            translate([cx, 0, -0.01])
                cylinder(d = 8, h = base_t + 0.02);
    }
}

leapfrog_bar();
