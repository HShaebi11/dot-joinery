# ============================================================================
#  PEGBOARD DRILLING JIGS — Fusion 360 generator  (v2, clean-print edition)
#
#  Builds FOUR parametric bodies in a new Fusion design:
#    1. Corner Base    (flat plate: seed guides, clamp holes, edge notches)
#    2. Corner Fence   (L-bracket: wraps panel edges, tabs lock into notches)
#    3. Indexing Bar   (2 pins + N bush-guided holes on the 50mm pitch)
#    4. Row Seeder     (1 pin + 3 bush positions, seeds next row/column)
#
#  Pattern: 10mm holes on a 50mm grid, first hole 25mm from each edge,
#  18mm plywood. Metal bushes: 12mm OD / 10mm ID for a 10mm bit.
#
#  WHY TWO PIECES for the corner jig: the fence must reach 18mm BELOW the
#  panel-top plane to bear on the panel edge faces, so a single-piece jig
#  can never print flat — the plate would bridge ~110mm between the walls.
#  Split version: base prints flat (zero support), fence prints standing
#  on its wall feet (zero support). Tabs + notches self-align; glue it.
#
#  PRINT ORIENTATION NOTES (for the exported STLs):
#    - Corner Base : as exported — flat side down, bosses up.
#    - Corner Fence: as exported — wall bottom edges on the bed + BRIM.
#    - Indexing Bar / Row Seeder: FLIP upside-down so pins point UP —
#      pins then print last as clean vertical posts (no supports).
#
#  HOW TO RUN (inside Fusion 360):
#    Utilities -> Scripts and Add-Ins -> select this file -> Run
#
#  NOTE: the Fusion API works in CENTIMETRES internally — all parameters
#  below are in MILLIMETRES and converted by cm() at the geometry calls.
# ============================================================================

import os
import traceback

import adsk.core
import adsk.fusion

# ------------------------- PARAMETERS (mm) -------------------------
# ---- panel / pattern ----
PITCH       = 50.0    # hole grid spacing
EDGE_OFFSET = 25.0    # first hole distance from each edge
PANEL_T     = 18.0    # plywood thickness (fence reaches this far below z=0)

# ---- corner jig seed block (cols x rows of guide holes) ----
SEED_COLS = 2         # 2x2 seeds rows AND columns; 2x1 = row pair; 1x1 = single
SEED_ROWS = 2

# ---- drill guides / metal bushes ----
BUSH_HOLE_D = 11.9    # bush seat dia — press fit for 12mm-OD bush
                      #   tighter 11.7 | slip fit + glue 12.1
BIT_CLEAR_D = 10.4    # bit clearance below the bush seat
BUSH_SEAT_H = 8.0     # counterbore depth inside each boss

# ---- locating pins (underside) ----
PIN_D      = 9.8      # snug in a 10mm hole — rattle? -> 9.9 ; tight? -> 9.5
PIN_LEN    = 10.0     # engagement depth below the base
PIN_EMBED  = 3.0      # root embedded inside the base
PIN_TIP_H  = 1.2      # lead-in step height at the tip
PIN_TIP_D  = 8.4      # tip diameter (step instead of chamfer — prints better)

# ---- corner BASE (flat plate half) ----
C_PLATE_T      = 5.0   # base plate thickness
C_BOSS_OD      = 26.0  # guide boss diameter
C_BOSS_H       = 8.0   # boss height above plate
C_CLAMP_D      = 6.0   # clamp hole diameter
C_CLAMP_GAP    = 25.0  # clamp holes sit this far beyond the guide field
C_EDGE_MARGIN  = 15.0  # plate edge margin past the clamp holes
# --- fence joint: notch pockets in the plate edges (match the fence tabs) ---
C_NOTCH_D      = 8.4   # notch depth into the plate edge
C_NOTCH_W      = 12.0  # notch width along the edge (tab is 10 -> 1mm/side)
C_TAB_FRAC     = (0.18, 0.5, 0.82)   # tab/notch positions as fraction of reach

# ---- corner FENCE (L-bracket half) ----
C_FENCE_T      = 4.0   # fence wall thickness
C_FENCE_TOP    = 14.0  # fence height above panel top surface (z=0)
C_TAB_W        = 10.0  # tab width
C_TAB_T        = 4.4   # tab height (0.3mm glue gap top and bottom)
C_TAB_Z0       = 0.3   # tab bottom height above panel top (z=0)
C_TAB_IN       = 8.0   # tab reach into the plate notch (< C_NOTCH_D)
C_TAB_EMBED    = 2.0   # tab root embedded in the wall

# ---- indexing bar body ----
B_BASE_T  = 6.0        # base plate thickness
B_W       = 50.0       # bar width
B_START_M = 12.0       # margin before the first pin
BAR_GUIDES = 3         # guides on the bar: 3 -> ~230mm long, 2 -> ~180mm
B_BOSS_OD = 24.0       # guide boss diameter
B_BOSS_H  = 8.0        # boss height above base

# ---- row seeder body ----
S_BASE_T = 5.0
S_MARGIN = B_BOSS_OD / 2.0 + 6.0   # plate margin around features

# ---- layout of the four bodies inside the document (mm) ----
CORNER_BASE_POS  = (0.0, 0.0)
CORNER_FENCE_POS = (170.0, 0.0)
BAR_POS    = (0.0, -160.0)
SEEDER_POS = (330.0, -160.0)

# ---- export ----
# STLs always go to the project folder when it exists (the copy Fusion runs
# may live in its own Scripts dir, so __file__ is not a reliable anchor).
_PROJECT_DIR = '/Users/hamzashaebi/Desktop/dot-joinery/public/files/pegboard-drilling-jigs'
if os.path.isdir(_PROJECT_DIR):
    EXPORT_DIR = os.path.join(_PROJECT_DIR, 'fusion_stl')
elif '__file__' in globals():
    EXPORT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fusion_stl')
else:
    EXPORT_DIR = os.path.join(_PROJECT_DIR, 'fusion_stl')
EXPORT_STL = True

# ==========================================================================
#  helpers — all lengths passed in mm, converted to cm for the API
# ==========================================================================

def cm(v):
    return v / 10.0


def vi(v_mm):
    """ValueInput wrapping an mm dimension (API wants cm internally)."""
    return adsk.core.ValueInput.createByReal(cm(v_mm))


def pt(x, y, z=0.0):
    return adsk.core.Point3D.create(cm(x), cm(y), cm(z))


def get_xy_plane(comp):
    try:
        return comp.xYConstructionPlane
    except Exception:
        return comp.origin.originPlanes.item(0)


def offset_plane(comp, base_plane, dist_mm):
    """Plane parallel to base_plane, `dist_mm` along its normal (mm)."""
    inp = comp.constructionPlanes.createInput()
    inp.setByOffset(base_plane, vi(dist_mm))
    return comp.constructionPlanes.add(inp)


def rect(sketch, x1, y1, x2, y2):
    sketch.sketchCurves.sketchLines.addTwoPointRectangle(pt(x1, y1), pt(x2, y2))


def circle(sketch, cx, cy, r):
    sketch.sketchCurves.sketchCircles.addByCenterRadius(pt(cx, cy), cm(r))


def profiles(sketch):
    return [sketch.profiles.item(i) for i in range(sketch.profiles.count)]


def extrude(comp, profile, dist_mm, op):
    return comp.features.extrudeFeatures.addSimple(profile, vi(dist_mm), op)


NEW  = adsk.fusion.FeatureOperations.NewBodyFeatureOperation
JOIN = adsk.fusion.FeatureOperations.JoinFeatureOperation
CUT  = adsk.fusion.FeatureOperations.CutFeatureOperation


# ==========================================================================
#  shared corner-jig dimensions (must match the .scad sources)
# ==========================================================================

def _corner_span():
    return max(EDGE_OFFSET + (SEED_COLS - 1) * PITCH,
               EDGE_OFFSET + (SEED_ROWS - 1) * PITCH)


def _corner_reach():
    return _corner_span() + C_CLAMP_GAP + C_EDGE_MARGIN


def _tab_positions():
    r = _corner_reach()
    return [f * r for f in C_TAB_FRAC]


def _guide_field_local():
    return [(EDGE_OFFSET + i * PITCH, EDGE_OFFSET + j * PITCH)
            for i in range(SEED_COLS) for j in range(SEED_ROWS)]


# ==========================================================================
#  part builders — each returns nothing; geometry lands in `comp`
#  ox, oy = layout offset (mm) applied to every XY coordinate
# ==========================================================================

def _sketch_circles(comp, plane, centers, radius):
    sk = comp.sketches.add(plane)
    for cx, cy in centers:
        circle(sk, cx, cy, radius)
    return sk


def _sketch_rect(comp, plane, x1, y1, x2, y2):
    sk = comp.sketches.add(plane)
    rect(sk, x1, y1, x2, y2)
    return sk


def _extrude_all(comp, sk, dist_mm, op):
    for p in profiles(sk):
        extrude(comp, p, dist_mm, op)


def build_corner_base(comp, ox, oy):
    """Flat plate half: seed guides, clamp holes, fence-tab notches."""
    xy = get_xy_plane(comp)
    reach = _corner_reach()
    clamp_p = _corner_span() + C_CLAMP_GAP
    guides = [(ox + gx, oy + gy) for gx, gy in _guide_field_local()]

    # 1) base plate on panel top (z = 0 .. C_PLATE_T); edges flush with
    #    the panel edge faces — the fence inner faces locate the corner.
    sk = _sketch_rect(comp, xy, ox, oy, ox + reach, oy + reach)
    _extrude_all(comp, sk, C_PLATE_T, NEW)

    # 2) guide bosses on plate top (embedded 0.5 into plate for a solid join)
    pb = offset_plane(comp, xy, C_PLATE_T - 0.5)
    sk = _sketch_circles(comp, pb, guides, C_BOSS_OD / 2.0)
    _extrude_all(comp, sk, C_BOSS_H + 0.5, JOIN)

    # 3) bush seats: ØBUSH_HOLE_D through the boss, stepped at plate top
    pc = offset_plane(comp, xy, C_PLATE_T)
    sk = _sketch_circles(comp, pc, guides, BUSH_HOLE_D / 2.0)
    _extrude_all(comp, sk, C_BOSS_H + 1.0, CUT)

    # 4) through-cuts start 0.2mm below the plate face for a clean break
    pz = offset_plane(comp, xy, -0.2)

    # 5) bit clearance ØBIT_CLEAR_D through the plate
    sk = _sketch_circles(comp, pz, guides, BIT_CLEAR_D / 2.0)
    _extrude_all(comp, sk, C_PLATE_T + 0.7, CUT)

    # 6) clamp holes through the plate
    clamps = [(ox + clamp_p, oy + EDGE_OFFSET),
              (ox + EDGE_OFFSET, oy + clamp_p)]
    sk = _sketch_circles(comp, pz, clamps, C_CLAMP_D / 2.0)
    _extrude_all(comp, sk, C_PLATE_T + 0.7, CUT)

    # 7) edge notches for the fence tabs — 3 per edge
    hw = C_NOTCH_W / 2.0
    for c in _tab_positions():
        # notch into the x = 0 edge
        sk = _sketch_rect(comp, pz, ox, oy + c - hw,
                          ox + C_NOTCH_D, oy + c + hw)
        _extrude_all(comp, sk, C_PLATE_T + 0.7, CUT)
        # notch into the y = 0 edge
        sk = _sketch_rect(comp, pz, ox + c - hw, oy,
                          ox + c + hw, oy + C_NOTCH_D)
        _extrude_all(comp, sk, C_PLATE_T + 0.7, CUT)


def build_corner_fence(comp, ox, oy):
    """L-bracket half: two walls wrapping the panel corner + joint tabs."""
    xy = get_xy_plane(comp)
    reach = _corner_reach()
    fence_l = reach

    # 1) wall against the y = 0 edge... build wall A first as the NEW body
    pz = offset_plane(comp, xy, -PANEL_T)
    sk = _sketch_rect(comp, pz,
                      ox - C_FENCE_T, oy - C_FENCE_T,
                      ox, oy + fence_l)
    _extrude_all(comp, sk, PANEL_T + C_FENCE_TOP, NEW)

    # 2) wall against the x = 0 edge
    sk = _sketch_rect(comp, pz,
                      ox - C_FENCE_T, oy - C_FENCE_T,
                      ox + fence_l, oy)
    _extrude_all(comp, sk, PANEL_T + C_FENCE_TOP, JOIN)

    # 3) tabs reaching into the plate notches (z = C_TAB_Z0 .. +C_TAB_T)
    pt_tab = offset_plane(comp, xy, C_TAB_Z0)
    hw = C_TAB_W / 2.0
    for c in _tab_positions():
        # wall-A tabs reach +x into the x = 0 edge notches
        sk = _sketch_rect(comp, pt_tab,
                          ox - C_TAB_EMBED, oy + c - hw,
                          ox + C_TAB_IN, oy + c + hw)
        _extrude_all(comp, sk, C_TAB_T, JOIN)
        # wall-B tabs reach +y into the y = 0 edge notches
        sk = _sketch_rect(comp, pt_tab,
                          ox + c - hw, oy - C_TAB_EMBED,
                          ox + c + hw, oy + C_TAB_IN)
        _extrude_all(comp, sk, C_TAB_T, JOIN)


def _build_guide_bar(comp, base_t, boss_od, boss_h,
                     pin_pts, guide_pts, plate_rect):
    """Shared construction for the indexing bar and the row seeder."""
    xy = get_xy_plane(comp)

    # 1) base plate
    sk = _sketch_rect(comp, xy, *plate_rect)
    _extrude_all(comp, sk, base_t, NEW)

    # 2) guide bosses (embedded 0.5 into the base)
    pb = offset_plane(comp, xy, base_t - 0.5)
    sk = _sketch_circles(comp, pb, guide_pts, boss_od / 2.0)
    _extrude_all(comp, sk, boss_h + 0.5, JOIN)

    # 3) bush seats ØBUSH_HOLE_D through the boss, stepped at base top
    pc = offset_plane(comp, xy, base_t)
    sk = _sketch_circles(comp, pc, guide_pts, BUSH_HOLE_D / 2.0)
    _extrude_all(comp, sk, boss_h + 1.0, CUT)

    # 4) bit clearance ØBIT_CLEAR_D through the base
    pz = offset_plane(comp, xy, -0.2)
    sk = _sketch_circles(comp, pz, guide_pts, BIT_CLEAR_D / 2.0)
    _extrude_all(comp, sk, base_t + 0.7, CUT)

    # 5) locating pins: stepped tip + shaft, pointing down (z < 0)
    p_tip = offset_plane(comp, xy, -PIN_LEN)
    sk = _sketch_circles(comp, p_tip, pin_pts, PIN_TIP_D / 2.0)
    _extrude_all(comp, sk, PIN_TIP_H + 0.2, JOIN)

    p_shaft = offset_plane(comp, xy, -PIN_LEN + PIN_TIP_H)
    sk = _sketch_circles(comp, p_shaft, pin_pts, PIN_D / 2.0)
    _extrude_all(comp, sk, PIN_LEN + PIN_EMBED - PIN_TIP_H + 0.2, JOIN)


def build_indexing_bar(comp, ox, oy):
    pitch = PITCH
    pin_pts = [(ox + 0.0, oy), (ox + pitch, oy)]
    lead = 2 * pitch
    guide_pts = [(ox + lead + i * pitch, oy) for i in range(BAR_GUIDES)]
    x_min = -B_START_M
    x_max = lead + (BAR_GUIDES - 1) * pitch + B_BOSS_OD / 2.0 + 4.0

    _build_guide_bar(comp, B_BASE_T, B_BOSS_OD, B_BOSS_H,
                     pin_pts, guide_pts,
                     (ox + x_min, oy - B_W / 2.0, ox + x_max, oy + B_W / 2.0))


def build_row_seeder(comp, ox, oy):
    m = S_MARGIN
    pin_pts = [(ox, oy)]
    guide_pts = [(ox, oy + PITCH), (ox + PITCH, oy + PITCH), (ox + PITCH, oy)]

    _build_guide_bar(comp, S_BASE_T, B_BOSS_OD, B_BOSS_H,
                     pin_pts, guide_pts,
                     (ox - m, oy - m, ox + PITCH + m, oy + PITCH + m))


# ==========================================================================
#  verification + export
# ==========================================================================

def _bounds_mm(body):
    bb = body.boundingBox
    return ((bb.minPoint.x * 10.0, bb.minPoint.y * 10.0, bb.minPoint.z * 10.0),
            (bb.maxPoint.x * 10.0, bb.maxPoint.y * 10.0, bb.maxPoint.z * 10.0))


def _check_bounds(body, name, exp_min, exp_max, log):
    mn, mx = _bounds_mm(body)
    tol = 0.6  # mm — catches missing features AND flipped sketch planes
    ok = all(abs(mn[i] - exp_min[i]) <= tol and abs(mx[i] - exp_max[i]) <= tol
             for i in range(3))
    if not ok:
        log('WARNING: %s bounds %s -> %s, expected about %s -> %s'
            % (name, tuple(round(v, 1) for v in mn),
               tuple(round(v, 1) for v in mx), exp_min, exp_max))
    return ok


def _export_bodies(design, named_bodies, log):
    if not EXPORT_STL:
        return
    os.makedirs(EXPORT_DIR, exist_ok=True)
    mgr = design.exportManager
    for name, body in named_bodies:
        try:
            opts = mgr.createSTLExportOptions(body)
            opts.filename = os.path.join(EXPORT_DIR, name + '.stl')
            opts.sendToPrintUtility = False
            opts.unitType = adsk.fusion.DistanceUnits.MillimeterDistanceUnits
            mgr.execute(opts)
            log('Exported %s' % opts.filename)
        except Exception as e:
            log('STL export failed for %s: %s' % (name, e))


def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui = app.userInterface

        doc = app.documents.add(adsk.core.DocumentTypes.FusionDesignDocumentType)
        design = adsk.fusion.Design.cast(doc.products.item(0))
        root = design.rootComponent

        messages = []

        def log(msg):
            messages.append(msg)

        # ---- build the four bodies ----
        jobs = [
            ('Corner Base',  build_corner_base,  CORNER_BASE_POS),
            ('Corner Fence', build_corner_fence, CORNER_FENCE_POS),
            ('Indexing Bar', build_indexing_bar, BAR_POS),
            ('Row Seeder',   build_row_seeder,   SEEDER_POS),
        ]
        named_bodies = []
        for name, fn, (ox, oy) in jobs:
            before = root.bRepBodies.count
            fn(root, ox, oy)
            new_bodies = [root.bRepBodies.item(i)
                          for i in range(before, root.bRepBodies.count)]
            for b in new_bodies:
                b.name = name
            named_bodies.extend([(name, b) for b in new_bodies])
            log('%s: %d body/bodies created' % (name, len(new_bodies)))

        # ---- sanity-check bounds (catches flipped offset planes) ----
        reach = _corner_reach()
        bar_x_max = (2 * PITCH + (BAR_GUIDES - 1) * PITCH
                     + B_BOSS_OD / 2.0 + 4.0)
        exp = {
            'Corner Base':   ((0, 0, 0), (reach, reach, C_PLATE_T + C_BOSS_H)),
            'Corner Fence':  ((-C_FENCE_T, -C_FENCE_T, -PANEL_T),
                              (reach, reach, C_FENCE_TOP)),
            'Indexing Bar':  ((-B_START_M, -B_W / 2.0, -PIN_LEN),
                              (bar_x_max, B_W / 2.0,
                               B_BASE_T + B_BOSS_H)),
            'Row Seeder':    ((-S_MARGIN, -S_MARGIN, -PIN_LEN),
                              (PITCH + S_MARGIN, PITCH + S_MARGIN,
                               S_BASE_T + B_BOSS_H)),
        }
        offsets = {'Corner Base': CORNER_BASE_POS,
                   'Corner Fence': CORNER_FENCE_POS,
                   'Indexing Bar': BAR_POS,
                   'Row Seeder': SEEDER_POS}
        for name, body in named_bodies:
            mn, mx = exp[name]
            ox, oy = offsets[name]
            _check_bounds(body, name,
                          (mn[0] + ox, mn[1] + oy, mn[2]),
                          (mx[0] + ox, mx[1] + oy, mx[2]), log)

        _export_bodies(design, named_bodies, log)

        summary = '\n'.join(messages) if messages else 'Done.'
        ui.messageBox('Pegboard jigs generated.\n\n' + summary +
                      ('\n\nSTLs in: ' + EXPORT_DIR) if EXPORT_STL else '')
    except Exception:
        if ui:
            ui.messageBox('FAILED:\n' + traceback.format_exc())
        else:
            raise
