// ============================================================================
//  GRID TILE — Proposal 3, ribbed version
//  3x3 stations on a 50mm pitch: pins in the x=0 column locate on the
//  finished column; six guides drill the next two columns. Rotate 90 deg
//  to seed the next band from a finished row.
//  PRINT: as modelled — pins point UP (they point down in use). No supports.
// ============================================================================
include <params.scad>
include <frame.scad>

pins   = [[0, 0], [0, pitch], [0, 2 * pitch]];
guides = [for (i = [1, 2], j = [0, 1, 2]) [i * pitch, j * pitch]];
x0 = -margin; x1 = 2 * pitch + margin;   // -18 .. 118  (136mm)
y0 = -margin; y1 = 2 * pitch + margin;

module grid_tile() {
    difference() {
        union() {
            rib_plate(x0, y0, x1, y1, [0, pitch, 2 * pitch], [0, pitch, 2 * pitch]);
            for (p = pins) pin_post(p[0], p[1]);
            for (g = guides) guide_boss(g[0], g[1]);
        }
        for (g = guides) guide_bores(g[0], g[1]);
    }
}

grid_tile();
