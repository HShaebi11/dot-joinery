// ============================================================================
//  CORNER FENCE — L-bracket half of the two-piece corner first-hole jig
//  For drilling the hole grid of an 18mm plywood pegboard panel.
//
//  Pattern assumed: 10mm holes on a 50mm grid, first hole 25mm from each edge.
//
//  Coordinate convention (matches the other jigs in this folder):
//    - Panel top surface  = z = 0
//    - Panel interior     = x > 0, y > 0   (panel corner at the origin)
//    - Fence inner faces at x = 0 and y = 0 bear against the panel edge faces
//      for the full panel_t below z = 0 (plus fence_top above).
//
//  Two walls wrap the outside of the panel corner. Six tabs (three per wall)
//  reach inward and drop into the notches of corner_base.scad — that joint
//  registers the fence square to the plate; glue it and it's permanent.
//
//  PRINT: as modelled — the wall bottom edges (panel_t below z=0) stand on
//  the bed. Walls are vertical plates: clean print, no supports.
//  Use a BRIM — the bed contact is two 4mm-wide strips (~120mm each).
//
//  Joint dimensions MUST match corner_base.scad — keep them in sync.
// ============================================================================

// ------------------------- PANEL / PATTERN -------------------------
edge_offset = 25;   // [mm] first hole centre distance from each edge
pitch       = 50;   // [mm] hole grid spacing
panel_t     = 18;   // [mm] plywood thickness (fences reach this far below z=0)

// --------------------------- SEED GUIDES ---------------------------
// Must match corner_base.scad so `reach` (fence length) stays identical.
seed_cols = 2;
seed_rows = 2;

// ------------------------------ BODY -------------------------------
fence_t      = 4;    // [mm] fence wall thickness
fence_top    = 14;   // [mm] fence height above panel top surface (z=0)
clamp_gap    = 25;   // [mm] (kept for reach parity with corner_base.scad)
edge_margin  = 15;

// --------------------- FENCE JOINT (tabs) ---------------------------
// Tabs reach +x / +y into the plate's edge notches. tab_w < notch_w=12,
// tab reach (wall_embed + tab_in) < notch_d=8.4, z inside plate_t=5.
tab_w      = 10;     // [mm] tab width (1mm clearance per side in the notch)
tab_t      = 4.4;    // [mm] tab height (0.3mm glue gap top and bottom)
tab_z0     = 0.3;    // [mm] tab bottom height above panel top (z=0)
tab_in     = 8;      // [mm] tab reach into the plate notch
tab_frac   = [0.18, 0.5, 0.82];  // tab positions as fractions of reach

// ---------------------------- COMPUTED -----------------------------
span_x  = edge_offset + (seed_cols - 1) * pitch;
span_y  = edge_offset + (seed_rows - 1) * pitch;
span    = max(span_x, span_y);
clamp_p = span + clamp_gap;
reach   = clamp_p + edge_margin;   // fence length (must equal plate extent)
tab_pos = [for (f = tab_frac) f * reach];

assert(seed_cols >= 1 && seed_rows >= 1, "seed_cols / seed_rows must be >= 1");

module corner_fence() {
    union() {
        // ---- fence against left edge (x = 0), runs along +y ----
        // x in [-fence_t, 0], y in [-fence_t, reach], z in [-panel_t, fence_top]
        translate([-fence_t, -fence_t, -panel_t])
            cube([fence_t, reach + fence_t, panel_t + fence_top]);

        // ---- fence against bottom edge (y = 0), runs along +x ----
        // x in [-fence_t, reach], y in [-fence_t, 0]
        translate([-fence_t, -fence_t, -panel_t])
            cube([reach + fence_t, fence_t, panel_t + fence_top]);

        // ---- tabs into the plate notches (x = 0 edge wall) ----
        // reach +x: root embedded 2mm in the wall, tip at tab_in into notch
        for (c = tab_pos)
            translate([-2, c - tab_w / 2, tab_z0])
                cube([2 + tab_in, tab_w, tab_t]);

        // ---- tabs into the plate notches (y = 0 edge wall) ----
        // reach +y
        for (c = tab_pos)
            translate([c - tab_w / 2, -2, tab_z0])
                cube([tab_w, 2 + tab_in, tab_t]);
    }
}

corner_fence();
