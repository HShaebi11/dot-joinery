// V3 INDEXING PIN SET
// Print four loose copies in one batch. Flip each pin before installing it
// so its small chamfered end points down from the indexing tile.
include <params.scad>

module indexing_pin() {
    cylinder(d = pin_head_d, h = pin_head_h);
    translate([0, 0, pin_head_h])
        cylinder(d = pin_d,
                 h = base_t + pin_len - pin_chamfer_h);
    translate([0, 0, pin_head_h + base_t + pin_len - pin_chamfer_h])
        cylinder(d1 = pin_d,
                 d2 = pin_d - 2 * pin_chamfer_radial,
                 h = pin_chamfer_h);
}

for (i = [0 : 3])
    translate([i * pin_set_spacing, 0, 0]) indexing_pin();
