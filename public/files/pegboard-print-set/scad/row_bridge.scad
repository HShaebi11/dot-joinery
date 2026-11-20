// ============================================================================
//  ROW BRIDGE — Proposals 1 & 2, ribbed version
//  Two pins at (0,0),(50,0) reference the finished row;
//  two guides at (0,50),(50,50) drill the next row. Rotate for columns.
//  PRINT: as modelled — pins point UP (they point down in use). No supports.
// ============================================================================
include <params.scad>
include <frame.scad>

pins   = [[0, 0], [pitch, 0]];
guides = [[0, pitch], [pitch, pitch]];
x0 = -margin; x1 = pitch + margin;      // -18 .. 68  (86mm)
y0 = -margin; y1 = pitch + margin;

module row_bridge() {
    difference() {
        union() {
            rib_plate(x0, y0, x1, y1, [0, pitch], [0, pitch]);
            for (p = pins) pin_post(p[0], p[1]);
            for (g = guides) guide_boss(g[0], g[1]);
        }
        for (g = guides) guide_bores(g[0], g[1]);
    }
}

row_bridge();
