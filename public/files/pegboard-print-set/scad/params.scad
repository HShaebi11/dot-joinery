// ============================================================================
//  SHARED PARAMETERS — pegboard jig print set
//  10mm holes on a 50mm grid, 18mm plywood, first hole 25mm from each edge.
//  Include this file in every part so dimensions stay in sync.
// ============================================================================

pitch        = 50;    // [mm] grid spacing
hole_d       = 10;    // [mm] drilled hole / bit size (reference)
edge_offset  = 25;    // [mm] first hole centre from each edge
panel_t      = 18;    // [mm] plywood thickness (fence reach below z=0)

// Locating pins — drop into drilled holes. All pin parts print PINS-UP.
pin_d      = 9.8;     // snug in a 10mm hole (9.9 tighter, 9.5 looser)
pin_len    = 10;      // engagement depth
pin_embed  = 3;       // root embedded in the base
chamfer_h  = 1.2;
chamfer_d  = 0.7;

// Drill guides — 12mm OD / 10mm ID metal bush press fit
bush_hole_d  = 11.9;  // press-fit seat (11.7 tighter, 12.1 slip+glue)
bit_clear_d  = 10.4;  // 0.2mm/side clearance
bush_seat_h  = 8;
boss_od      = 24;
boss_h       = 8;

// Base plates
base_t       = 6;
margin       = boss_od / 2 + 6;   // plate margin around stations

// Fence joint — must match between plate notches and fence tabs
notch_d      = 8.4;
notch_w      = 12;
tab_w        = 10;
tab_t        = 4.4;
tab_z0       = 0.3;
tab_in       = 8;
tab_frac     = [0.18, 0.5, 0.82];
fence_t      = 4;
fence_top    = 14;
clamp_gap    = 25;
edge_margin  = 15;
clamp_hole_d = 6;

// Edge rounding — plan-view corner radius, helps high-speed printing
corner_r     = 6;      // [mm] on plates / rib frames
corner_r_s   = 3;      // [mm] on small parts (carriage, inserts)
edge_break   = 0.8;    // [mm] small chamfer on exposed vertical-part edges

// Fence→plate screws — horizontal M3 self-tappers through the fence
// wall into the plate edge band, in the solid gaps between notches.
// Shared by plate (pilot) and fence (through) so positions always match.
screw_d       = 3;      // [mm] M3
screw_clear   = 3.4;    // through-hole Ø in the fence wall
screw_pilot   = 2.4;    // pilot hole Ø into the plate edge
screw_depth   = 9.5;    // pilot depth — stays inside the 10mm border band
screw_z       = 3;      // hole centre height (mid plate thickness)
screw_min_gap = 10;     // smallest solid edge interval that takes a screw

// Solid intervals along a fence edge = reach minus the notch pockets.
// Returns centre positions for the screw holes (same on both parts).
function screw_stations(reach, tab_pos) =
    let(
        flat   = [for (c = tab_pos, e = [-notch_w / 2, notch_w / 2]) c + e],
        bounds = concat([0], flat, [reach]),
        pairs  = [for (i = [0 : 2 : len(bounds) - 2])
                      [bounds[i], bounds[i + 1]]]
    )
    [for (p = pairs) if (p[1] - p[0] >= screw_min_gap)
        (p[0] + p[1]) / 2];
