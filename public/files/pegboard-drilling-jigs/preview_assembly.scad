// ============================================================================
//  ASSEMBLY PREVIEW — for documentation renders only, NOT for printing.
//  Shows the jigs in place on a piece of pegboard panel: the two-piece
//  corner jig assembled (base plate + fence joined at the notches),
//  the indexing bar mid-row, and the row seeder.
// ============================================================================

use <corner_base.scad>
use <corner_fence.scad>
use <indexing_bar.scad>
use <row_seeder.scad>

// ---------------- illustrative panel ----------------
panel_w = 620;
panel_d = 460;
panel_t = 18;

// grid of "already drilled" holes near the corner for context
hole_step = 50;
hole_off  = 25;
hole_d    = 10.2;

module hole_grid() {
    for (ix = [0 : 6])
        for (iy = [0 : 4])
            translate([hole_off + ix * hole_step, hole_off + iy * hole_step, 0])
                cylinder(d = hole_d, h = panel_t + 0.1);
}

difference() {
    translate([0, 0, -panel_t])
        cube([panel_w, panel_d, panel_t]);
    translate([0, 0, -panel_t - 0.05])
        hole_grid();
}

// ---- corner jig on the panel corner (origin), assembled ----
corner_base();
corner_fence();

// ---- indexing bar walking row y = 25 (pins in the seed pair) ----
translate([hole_off, hole_off, 0])
    indexing_bar();

// ---- row seeder further along: pin in hole (325,175), guides -> next row --
translate([325, 175, 0])
    row_seeder();
