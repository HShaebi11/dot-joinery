// ============================================================================
//  STARTER 3x3 FENCE — L-bracket for the 165mm starter3_plate
//  Joint: tabs locate in the plate notches; M3 self-tappers through the
//  walls into the plate edge band clamp it (no glue needed).
//  PRINT: as modelled — wall bottom edges on the bed, USE A BRIM.
// ============================================================================
include <params.scad>
include <frame.scad>

seed_cols = 3;
seed_rows = 3;

span    = edge_offset + (max(seed_cols, seed_rows) - 1) * pitch; // 125
clamp_p = span + clamp_gap;
reach   = clamp_p + edge_margin;                                 // 165
tab_pos = [for (f = tab_frac) f * reach];
screw_pos = screw_stations(reach, tab_pos);

corner_r_f = 3;    // outer corner clip radius
chamfer_t  = 1.5;  // top edge chamfer — vertical
chamfer_i  = 0.9;  // top edge chamfer — horizontal inset
z_top      = panel_t + fence_top;                                // 32

// L footprint with the outer (-fence_t,-fence_t) corner clipped by an arc.
module fence_outline() {
    r = corner_r_f;
    polygon(concat(
        [[-fence_t, -fence_t + r],
         [-fence_t, reach],
         [0, reach],
         [0, 0],
         [reach, 0],
         [reach, -fence_t],
         [-fence_t + r, -fence_t]],
        [for (a = [247.5, 225, 202.5])
            [-fence_t + r + r * cos(a), -fence_t + r + r * sin(a)]]
    ));
}

module starter3_fence() {
    difference() {
        union() {
            intersection() {
                union() {
                    // wall A — chamfered top
                    hull() {
                        translate([-fence_t, -fence_t, -panel_t])
                            cube([fence_t, reach + fence_t,
                                  z_top - chamfer_t]);
                        translate([-fence_t + chamfer_i,
                                   -fence_t + chamfer_i,
                                   -panel_t + z_top - chamfer_t])
                            cube([fence_t - 2 * chamfer_i,
                                  reach + fence_t - 2 * chamfer_i,
                                  chamfer_t]);
                    }
                    // wall B — chamfered top
                    hull() {
                        translate([-fence_t, -fence_t, -panel_t])
                            cube([reach + fence_t, fence_t,
                                  z_top - chamfer_t]);
                        translate([-fence_t + chamfer_i,
                                   -fence_t + chamfer_i,
                                   -panel_t + z_top - chamfer_t])
                            cube([reach + fence_t - 2 * chamfer_i,
                                  fence_t - 2 * chamfer_i,
                                  chamfer_t]);
                    }
                }
                translate([0, 0, -panel_t - 0.1])
                    linear_extrude(z_top + 0.2)
                        fence_outline();
            }
            // tabs stay outside the outline clip — they must reach into
            // the plate region (x>0,y>0) to engage the notches
            for (c = tab_pos) {
                translate([-2, c - tab_w / 2, tab_z0])
                    cube([2 + tab_in, tab_w, tab_t]);
                translate([c - tab_w / 2, -2, tab_z0])
                    cube([tab_w, 2 + tab_in, tab_t]);
            }
        }
        // M3 through-holes — line up with the plate pilot holes
        for (sy = screw_pos) {
            translate([-fence_t - 0.6, sy, screw_z])
                rotate([0, 90, 0])
                    cylinder(d = screw_clear, h = fence_t + 1.2);
            translate([sy, -fence_t - 0.6, screw_z])
                rotate([-90, 0, 0])
                    cylinder(d = screw_clear, h = fence_t + 1.2);
        }
    }
}

starter3_fence();
