// V3 shared customizer settings. Dimensions are millimetres.

// Board hole pattern
hole_d = 10;             // [3:0.1:30] Finished hole / twist-bit diameter
grid_pitch = 50;         // [15:0.1:100] Centre-to-centre hole spacing
edge_offset = 25;        // [0:0.1:100] First hole centre from both board edges
board_cols = 10;         // [1:1:100] Number of holes across the board
board_rows = 10;         // [1:1:100] Number of holes down the board
panel_t = 18;            // [3:0.1:50] Board thickness

// A1 mini print envelope
build_x = 180;
build_y = 180;
bed_edge_clearance = 3;  // Keep the part this far from each bed edge

// Twist-drill guide and bushing
bush_od = 12;            // Metal guide bush outside diameter
bush_id = 10;            // Metal guide bush inside diameter; match the bit
bush_seat_d = 11.9;      // Printed press-fit socket; tune with a test coupon
bush_seat_h = 8;
bit_clearance = 0.4;     // Clearance below the metal bush
pin_clearance = 0.2;     // Locating pin undersize relative to the drilled hole
bit_clear_d = hole_d + bit_clearance;

// Shared body dimensions
base_t = 6;
boss_wall = 4;            // Plastic wall around the bush seat
boss_d = max(max(bush_od, bush_seat_d), bit_clear_d) + 2 * boss_wall;
boss_h = 8;
rib_w = 8;
border_w = 8;
$fn = 48;
pin_len = 10;
pin_chamfer_h = 1.2;
pin_chamfer_radial = 0.6;
pin_mount_clearance = 0.25; // Bore allowance around each removable pin stem
pin_head_d = 14;
pin_head_h = 1.6;
pin_head_recess_clearance = 0.3;
pin_pad_d = 18;
pin_set_spacing = 18;

// The indexing tile keeps a 2x2 pin pattern and uses every remaining
// grid station as a drill guide. The default 4x4 tile gives 12 guides.
index_cols = 4;           // [3:1:8] Grid stations across the indexing tile
index_rows = 4;           // [3:1:8] Grid stations down the indexing tile

// Corner starter joint. The fence is a separate printable piece that mates
// with the plate; together they are the corner-starter tool.
clamp_hole_d = 6;
clamp_gap = 25;
edge_margin = 15;
fence_t = 4;
fence_top = 8;
notch_d = 6;
notch_w = 10;
tab_d = 5.5;
tab_w = 8;
tab_t = 4.4;
tab_z = 0.8;
tab_fractions = [0.28, 0.72];

// Derived dimensions and point lists
pin_d = hole_d - pin_clearance;
pin_mount_d = pin_d + pin_mount_clearance;
pin_head_recess_d = pin_head_d + pin_head_recess_clearance;
seed_x = [edge_offset, edge_offset + grid_pitch];
seed_y = [edge_offset, edge_offset + grid_pitch];
seed_points = [for (x = seed_x, y = seed_y) [x, y]];
index_pin_points = [[0, 0], [grid_pitch, 0], [0, grid_pitch], [grid_pitch, grid_pitch]];
index_guide_points = [
    for (ix = [0 : index_cols - 1], iy = [0 : index_rows - 1])
        if (!(ix < 2 && iy < 2)) [ix * grid_pitch, iy * grid_pitch]
];
index_x0 = -boss_d / 2;
index_y0 = -boss_d / 2;
index_x1 = (index_cols - 1) * grid_pitch + boss_d / 2;
index_y1 = (index_rows - 1) * grid_pitch + boss_d / 2;
index_size_x = index_x1 - index_x0;
index_size_y = index_y1 - index_y0;
index_guide_count = len(index_guide_points);

starter_last_x = edge_offset + grid_pitch;
starter_last_y = edge_offset + grid_pitch;
starter_clamp_x = starter_last_x + clamp_gap;
starter_clamp_y = starter_last_y + clamp_gap;
starter_reach = max(starter_clamp_x, starter_clamp_y) + edge_margin;
starter_tab_positions = [for (f = tab_fractions) f * starter_reach];

assert(hole_d > pin_clearance, "Hole diameter must exceed pin clearance.");
assert(pin_mount_d > pin_d, "Pin mounting bore must allow a printable fit.");
assert(pin_head_recess_d < pin_pad_d, "Pin-head pocket needs material around it.");
assert(bush_id >= hole_d, "Choose a guide bush ID that fits the selected drill bit.");
assert(bush_seat_d > bush_id, "Bush seat must be larger than the bush bore.");
assert(bush_seat_d < bush_od + 0.6, "Bush seat fit is unusually loose; check the bush OD.");
assert(boss_h >= bush_seat_h, "Bush seat cannot be deeper than the guide boss.");
assert(grid_pitch >= boss_d + 2, "Grid pitch is too tight for the guide bosses.");
assert(index_cols >= 3 && index_rows >= 3, "Indexing tile needs at least 3x3 stations.");
assert(index_size_x <= build_x - 2 * bed_edge_clearance,
       str("Indexing tile is too wide for the selected bed: ", index_size_x, " mm."));
assert(index_size_y <= build_y - 2 * bed_edge_clearance,
       str("Indexing tile is too deep for the selected bed: ", index_size_y, " mm."));
assert(starter_reach <= build_x && starter_reach <= build_y,
       "Corner starter plate exceeds the selected printer bed.");
assert(board_cols >= 2 && board_rows >= 2, "Board must have at least a 2x2 hole grid.");
