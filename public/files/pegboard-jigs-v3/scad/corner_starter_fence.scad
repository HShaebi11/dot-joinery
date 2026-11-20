// V3 CORNER STARTER FENCE
// The two walls register against the outside faces of the board corner.
// Print with the long wall bottom edges on the bed; use a brim if needed.
include <params.scad>

module corner_starter_fence() {
    union() {
        // L-shaped fence walls span from below the panel top to a short lip above it.
        translate([-fence_t, -fence_t, -panel_t])
            cube([fence_t, starter_reach + fence_t, panel_t + fence_top]);
        translate([-fence_t, -fence_t, -panel_t])
            cube([starter_reach + fence_t, fence_t, panel_t + fence_top]);

        // Tabs fit into the pockets in corner_starter_plate.scad.
        for (c = starter_tab_positions) {
            translate([-0.01, c - tab_w / 2, tab_z])
                cube([tab_d + 0.01, tab_w, tab_t]);
            translate([c - tab_w / 2, -0.01, tab_z])
                cube([tab_w, tab_d + 0.01, tab_t]);
        }
    }
}

corner_starter_fence();
