// ============================================================================
//  RAIL FRAME — Proposal 4 (indexed rail)
//  Ladder frame: pins under the y=0 beam locate in two adjacent holes;
//  the y=50 beam is the carriage track over the row being drilled;
//  detent holes at x=0 and x=50 take the rail_key lock.
//  PRINT: as modelled — pins point UP (they point down in use). No supports.
// ============================================================================
include <params.scad>

beam_t   = 8;      // guide rail height (carriage slot ~8.6 clears this)
beam_w   = 12;     // guide rail width (carriage slot ~12.6 clears this)
pinbeam_w = 14;
x0 = -10; x1 = 2 * pitch + 10;   // spans pin 0, pin 50, a little past

module pin_post(x, y) {
    translate([x, y, base_t - pin_embed]) {
        cylinder(d = pin_d, h = pin_embed + pin_len - chamfer_h);
        translate([0, 0, pin_embed + pin_len - chamfer_h])
            cylinder(d1 = pin_d, d2 = pin_d - 2 * chamfer_d, h = chamfer_h);
    }
}

module rail_frame() {
    difference() {
        union() {
            // pin beam (y = 0)
            translate([(x0+x1)/2, 0, base_t/2])
                rounded_box([x1-x0, pinbeam_w, base_t]);
            pin_post(0, 0);
            pin_post(pitch, 0);
            // guide rail beam (y = pitch), taller = the track
            translate([(x0+x1)/2, pitch, beam_t/2])
                rounded_box([x1-x0, beam_w, beam_t]);
            // cross ties at both pin stations
            for (tx = [0, pitch])
                translate([tx, pitch/2, base_t/2])
                    rounded_box([12, pitch + pinbeam_w/2 + beam_w/2, base_t]);
        }
        // carriage lock detents in the rail beam at both stops
        for (tx = [0, pitch])
            translate([tx, pitch, beam_t - 4])
                cylinder(d = 6.3, h = 4.02);
    }
}

rail_frame();
