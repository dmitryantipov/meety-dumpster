// meety-dumpster — shared bits: board placement in the dumpster frame, screen window, flames, trash.
//
// Dumpster frame: X across the front (viewer's right = +X), Y depth (front face y=0 → back +Y), Z up (table z=0).
// LCD glass is flush with the front face (y=0). Board stands landscape, BOOT edge up, USB-C on the right.
include <BOSL2/std.scad>
include <meety-case/dimensions.scad>
use <meety-case/board.scad>

z_glass_s = z_pcb_back - pcb[2] - lcd[2];          // -7.6 glass face in the shell frame
xc_s      = board_dx + pcb[0] / 2;                 // 18.35 board centre along X (shell)
yc_s      = cav[1] / 2;                            // 10.15
// glass outline from the Waveshare STEP (dumpster X): 36.99 × 19.39, offset +0.325 toward the USB end;
// active area sits ~1 mm toward the far end (driver ledge at the USB end)
glass_x   = [-18.175, 18.825];
glass_hz  = 9.695;
active_c  = -1.05;
win_clr   = 0.15;
// visible top glass (polarizer, STEP top layer): 33.65 × 18.78 r2.85, its face is y=0; the TFT glass (glass_x, with the
// driver ledge + flex at the USB end) sits 0.15 behind it
vis_x     = [-17.885, 15.765];
vis_hz    = 9.39;
vis_r     = 2.85;
tft_dy    = 0.15;

// shell frame (x along board from USB end, y BOOT-up, z toward back) → dumpster frame, screen centred at (0, 0, zc)
module to_dumpster(zc) multmatrix([[-1, 0, 0, xc_s], [0, 0, 1, -z_glass_s], [0, 1, 0, zc - yc_s], [0, 0, 0, 1]]) children();

module board_d(zc) to_dumpster(zc) board();

// BOOT stem tip in the dumpster frame (the fire has to end up pushing this down)
function stem_tip(zc) = [-(board_dx + sw_x - xc_s), sw_z - z_glass_s, zc + pcb[1] / 2 + stem[1]];

module screen_window(zc, t) translate([glass_x[0] - win_clr, -1, zc - glass_hz - win_clr]) cube([glass_x[1] - glass_x[0] + 2 * win_clr, t + 2, 2 * (glass_hz + win_clr)]);

// fake screen content for renders: dark glass + an 8-bit flame glyph
module screen_face(zc) {
    color([0.05, 0.05, 0.07]) translate([glass_x[0], 0.01, zc - glass_hz]) cube([glass_x[1] - glass_x[0], 0.2, 2 * glass_hz]);
    color([0.1, 0.12, 0.2]) translate([active_c, -0.02, zc]) cuboid([32.35, 0.1, 17.39], anchor = FRONT);
}

// ---------- flames ----------
// 2D tongue: two cubic edges from a base segment [bl, br] to a sharp tip. lean = tip-axis slope (dx/dz, + = right);
// the body swings the other way first (S-curve), so the flame looks like it's licking upward.
function tongue2d(bl, br, tip, lean = 0, n = 18) = let(
        h = tip[1] - (bl[1] + br[1]) / 2, w = br[0] - bl[0],
        d = [lean, 1] / norm([lean, 1]), p = [d[1], -d[0]],          // tip axis, its right-hand normal
        L = bezier_curve([bl, bl + [-w * 0.35 - lean * h * 0.15, h * 0.35], tip - d * h * 0.5 - p * w * 0.12, tip], n),
        R = bezier_curve([br, br + [w * 0.35 - lean * h * 0.15, h * 0.35], tip - d * h * 0.4 + p * w * 0.05, tip], n))
    concat(L, reverse(R));
// flame silhouette, base centred on the origin, ~h tall; style "classic" (3 tongues) or "cartoon" (fat + flicks)
function flame_tongues(style, h) = let(s = h / 32) [for (t = (style == "cartoon") ? [
        [[-11, 1], [11, 1], [2.5, 33], 0.45],  // fat body, tip flicks right
        [[-12.5, 3], [-4, 9], [-14.5, 25], -0.9],  // left flick, curling out
        [[4, 8], [12.5, 3], [15, 21], 1.0],    // right flick
        [[-6, 12], [1, 14], [-5.5, 28], -0.35],    // inner flick
    ] : [
        [[-7, 1], [7, 1], [-1, 32], -0.25],    // main
        [[-11, 2], [-3, 4], [-12, 22], -0.55],
        [[2, 4], [10, 2], [11, 25], 0.45],
        [[-4, 6], [3, 8], [3.5, 27], 0.3],     // inner, between main and right
    ]) tongue2d(t[0] * s, t[1] * s, t[2] * s, t[3] * s)];

function flame_region(style = "classic", h = 32) = let(s = h / 32,
        belly = [for (p = ellipse(r = [(style == "cartoon" ? 12.5 : 11) * s, (style == "cartoon" ? 7.75 : 6.8) * s], $fn = 48))
                    p + [0, (style == "cartoon" ? 7 : 5.5) * s]])
    union(concat([belly], flame_tongues(style, h)));

module flame2d(style = "classic", h = 32) region(flame_region(style, h));

// rounded-slab 3D flame standing on z=0, centred in Y, thickness th: flat core, quarter-round edges built from
// stacked round offsets (offset_sweep spikes at the sharp tips)
module flame3d(style = "classic", h = 32, th = 9, steps = 6) {
    r = min(th / 2 - 0.5, 2.5);
    core = th - 2 * r;
    rotate([90, 0, 0]) {
        translate([0, 0, -core / 2]) linear_extrude(core) flame2d(style, h);
        for (sd = [-1, 1], i = [0 : steps - 1]) let(u0 = i / steps, u1 = (i + 1) / steps,
                inset = r * (1 - sqrt(1 - pow(u1, 2))))
            mirror([0, 0, sd < 0 ? 1 : 0]) translate([0, 0, core / 2 + r * u0 - 0.001])
                linear_extrude(r * (u1 - u0) + 0.002) offset(r = -inset) flame2d(style, h);
    }
}

// split for printing: opaque root below z_split, light-transmitting top above
module flame_split(style, h, th, z_split, part = "both") {
    if (part != "top") color([0.95, 0.30, 0.05]) intersection() { flame3d(style, h, th); translate([0, 0, -1]) cuboid([h * 2, th + 2, z_split + 1], anchor = BOTTOM); }
    if (part != "root") color([1.0, 0.82, 0.25]) difference() { flame3d(style, h, th); translate([0, 0, -1]) cuboid([h * 2, th + 2, z_split + 1], anchor = BOTTOM); }
}

// pixel flame bitmap (row 0 = top). X = outer (red), O = mid (orange), Y = core (yellow)
px_flame = [
    "      X       ",
    "     XX    X  ",
    "  X  XOX   XX ",
    "  XX XOXX XXX ",
    " XXX XOOX XOX ",
    " XOXXXOOXXXOX ",
    " XOOXOOYOXOOX ",
    "XXOOOOYYOOOOXX",
    "XOOOYOYYYOYOOX",
    "XOOYYYYYYYYOOX",
    "XOOYYYYYYYYOOX",
    " XOOYYYYYYOOX ",
    "  XXOOOOOOXX  ",
];
module px_flame_layer(p, chars) {
    R = len(px_flame);
    for (r = [0 : R - 1], c = [0 : len(px_flame[r]) - 1])
        if (search(px_flame[r][c], chars) != [])
            translate([(c - len(px_flame[r]) / 2) * p, (R - 1 - r) * p]) square(p + 0.001);
}

// ---------- trash ----------
// knotted garbage bag, sitting on z=0: lumpy squashed body, small neck, two tie ears
module trash_bag(d = 10, sq = 0.7) {
    hull() {
        scale([1, 0.9, sq]) translate([0, 0, d / 2]) sphere(d = d, $fn = 28);
        translate([d * 0.12, 0, d * sq * 0.45]) scale([0.9, 1, 0.8]) sphere(d = d * 0.95, $fn = 24);
    }
    translate([0, 0, d * sq - 0.4]) cyl(d1 = d * 0.3, d2 = d * 0.14, h = d * 0.18, anchor = BOTTOM, $fn = 16);
    for (s = [-1, 1]) translate([s * d * 0.08, 0, d * sq + d * 0.16]) rotate([0, s * 45, 0]) scale([1, 0.35, 0.55]) sphere(d = d * 0.28, $fn = 16);
}

// pillowed extrusion of 2D children: flat core with quarter-round top/bottom edges (stacked round offsets)
module pillow(h, r, steps = 5) {
    core = h - 2 * r;
    translate([0, 0, r]) linear_extrude(core) children();
    for (sd = [0, 1], i = [0 : steps - 1]) let(u0 = i / steps, u1 = (i + 1) / steps, inset = r * (1 - sqrt(1 - pow(u1, 2))))
        translate([0, 0, sd == 0 ? r - r * u1 : r + core + r * u0]) linear_extrude(r * (u1 - u0) + 0.002) offset(r = -inset) children();
}

// tin can, lying on z=0 along X
module tin_can(d = 6, l = 8) translate([0, 0, d / 2]) rotate([0, 90, 0]) difference() {
    union() { cyl(d = d, h = l, rounding = 0.5, $fn = 32); for (z = [-l / 4, l / 4]) cyl(d = d + 0.4, h = 0.6, $fn = 32); }
    translate([0, 0, l / 2]) cyl(d = d - 1, h = 1.2, $fn = 32);
}
