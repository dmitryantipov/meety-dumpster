// meety-dumpster v1 (frozen 2026-11-18) — 8-bit dumpster fire around the Waveshare ESP32-C6-LCD-1.47 (concept C, chosen 2026-10-20).
// Everything outside sits on a 2.5 mm voxel grid; the internals come from core.scad.
//
// Parts / filaments:
//   body                     your colour (blue / green / pink)
//   lid ×2 (identical)       black or gray
//   deck (trash floor+bags)  black or gray (the plunger hangs off its underside)
//   cartridge                black / PETG-CF (meety-case shell, no in-wall buttons)
//   flame (+ light pipe)     white / clear (one solid part since v0.21: the look comes from the slicer's infill)
// Assembly: board -> cartridge (4 screws as meety-case) -> press it straight down between the side walls and the
// back spring fingers. On the bench: flame stem pressed down into the deck U = one button. Button in (left edge under
// the lip, lower the right side) -> lids snap onto the hinge fins.
// fire = false: light pipe only (a glowing pixel-coal plinth on the trash) -> the lids close.
//
// Two frames: internal (glass face at y=0, everything in core.scad) and exterior ext() = internal shifted to the
// front face (y_face) so the voxel grid starts at the front of the bezel, and in X onto the active area's centre.
include <core.scad>
use <meety-case/pixel_text.scad>

side  = "R";               // R: USB-C out the right wall · L: USB-C out the left wall (mirror build, see core.scad)
fire  = true;              // flame on the button; false: no flame, lids close
part  = "all";             // all | body | cartridge | light_pipe_nf | deck | flame | lid_l | lid_r | glass | board
print = false;             // true: single part in print orientation on z=0
show_board = false;

p = 2.5;                   // voxel
NX = 18; ND = 8; NH = 12;  // body in voxels: floor under the cartridge, lids just clear the bags; 18 wide since v0.12 so
                           // the body can centre on the screen (thick non-USB wall holds the side finger)
W = NX * p; D = ND * p; H = NH * p;   // 45 × 20 × 30
t = p;                     // back wall
floor_z = p;               // inner floor = cartridge bottom
zc = floor_z + cart_hz;    // 13.45 screen centre
xl = -xi;                  // left wall inner face
yb = y_face + D - t;       // 16.25 back wall inner face

x_ext = active_c;          // exterior centred on the active pixels (R frame): the window sits symmetric in the front
module extr() translate([x_ext, y_face, 0]) children();                        // body_r (built in R, mirrored for L)
module ext() translate([side == "L" ? -x_ext : x_ext, y_face, 0]) children();   // parts placed in the side's own frame
module vox(x, y, z, nx = 1, ny = 1, nz = 1) translate([x * p, y * p, z * p]) cube([nx * p, ny * p, nz * p]);

// 45° corbel under a proud band (prints without support; reads as the band's shadow). Exterior frame.
module corbel_x(y0, y1, z, d, s) translate([s > 0 ? W / 2 : -W / 2, y0, z]) rotate([-90, 0, 0]) linear_extrude(y1 - y0)
    polygon([[0, 0], [s * d, 0], [0, d]]);
module corbel_y(x0, x1, z, d, s, y) translate([x0, y, z]) rotate([90, 0, 90]) linear_extrude(x1 - x0)
    polygon([[0, 0], [s * d, 0], [0, -d]]);

// lids: snap hinges (v0.14). Per lid, two fins stand off the back wall on 45° gussets, free above; the lid's one
// barrel sits between them and a 45° cone bump on each barrel end clicks into a cone dimple in the fin. The fins spread
// to let the bumps in (no pin, nothing to thread; too much force pops a lid off instead of breaking it) and stay
// pushed out bump_pre when seated, which is the hinge friction. Range: closed (flame removed) -> flame -> flipped back.
// Exterior frame.
lw = (NX + 2) / 2 * p - 0.1;                   // 24.9 lid width (two lids cover the rim)
lid_x0 = [-W / 2 - p, 0.1];                    // left / right lid X start
kn_r   = 2.0;                                  // lid barrel radius
kn_g   = 0.4;                                  // barrel sweep over the shelf
fin_t  = 1.8;                                  // fin thickness (X)
fin_r  = 2.2;                                  // fin top radius around the axis
fin_m  = 4.0;                                  // fin inset from the lid end
fin_x  = [fin_m, lw - fin_m - fin_t];          // fin X start (lid frame)
fin_root = 5 * p;                              // the fin's front edge leaves the back wall here (45° up to yF)
fin_cx = 0.8;                                  // X room beside a fin (it spreads ≈0.7 on assembly)
fin_cy = 0.5;                                  // fin front edge behind the rim
bump_g = 0.2;                                  // barrel end to fin face
bump_r = 1.4;                                  // bump base radius on the barrel end (45° cone)
bump_h = 0.9;                                  // bump height: fins spread bump_h - bump_g = 0.7 going in
bump_pre = 0.2;                                // fins stay pushed out this much when seated (friction)
// v0.20 lid: the barrel ends press into the fins (bump_ov each) so the flat end faces carry the preload; smaller bumps
// so they sit loose in the v0.14 dimples (body unchanged) and the spread going in stays bump_ov + lb_h
bump_ov = 0.25;                                // barrel end into the unspread fin face = seated spread
lb_r = 0.9; lb_h = 0.5;                        // lid bump: base radius, height (dimple: r 1.0 at the face, 0.8 deep)
kn_ch = 0.35;                                  // 45° chamfer on the barrel end rim: lead-in past the fin edge
ax_y = D + p + fin_cy + fin_r;                 // hinge axis Y (behind the rim)
ax_z = H + kn_r;                               // axis Z: lid inner face lies on the rim when closed
lid_len = ax_y + p;                            // axis to the front edge of the front rim
notch_a = 2.8;                                 // lid plate cut back this far from the axis at the fins
xb = [fin_x[0] + fin_t + bump_g, fin_x[1] - bump_g];   // barrel ends (lid frame)
xbl = [fin_x[0] + fin_t - bump_ov, fin_x[1] + bump_ov];   // v0.20 barrel ends (lid frame); xb still sets the dimples + plate notches
// hinge shelf (v0.13): full-width ledge behind the rim, kn_g under the barrel's sweep, 45° underside onto the back
// wall; slotted around the fins since v0.14. Stops a flipped-back lid.
shelf_y = D + 3 * p;                           // back edge (exterior Y)
shelf_z = ax_z - kn_r - kn_g;                  // top
shelf_t = p;                                   // thickness at the back edge
function fin_xe(i, j) = lid_x0[i] + fin_x[j];  // fin X start (exterior)
lid_rest = 20;                                 // fire: the lids lie on the flame at this angle
lid_ang = fire ? [lid_rest, lid_rest] : [108, 78];         // display angles (0 = closed, 90 = upright, >90 = flipped back); fire: on the flame
// v0.20 lid ↔ flame coupling: a key on the flame's lid plane under each lid's centre drops into a pocket in the lid's inner
// face (loose: located, never pressed). Lid frame: along the lid from the axis (u), up off the inner face (v). The front face
// leans back tan(45° - lid_rest) per unit height, so it is a 45° overhang on the flame printed front-down.
cp_u = [21, 24];           // key base, along the lid
cp_w = 3.5;                // key width (X)
cp_h = 1.2;                // key height off the lid plane
cp_k = tan(45 - lid_rest);
cp_cx = 0.6;               // pocket clearance in X: full button travel rolls the flame ≈0.4 sideways at the key
cp_cu = 0.45;              // along the lid (the far key drops ≈0.85, ≈0.3 of it along the lid)
cp_cz = 0.4;               // pocket deeper than the key

// USB-C port: stadium around the plug head (internal frame, right wall)
module usb_port() translate([xi - 0.01, usb_y, zc]) rotate([0, 90, 0]) linear_extrude(10)
    hull() for (s = [-1, 1]) translate([s * (usb_head[0] - usb_head[1]) / 2, 0]) circle(d = usb_head[1], $fn = 40);


module side_m() if (side == "L") mirror([1, 0, 0]) children(); else children();
// pixel "meety" on the side away from the USB port, always reading left-to-right
lbl_z = 11; lbl_p = 0.75;
module label_cut() if (side == "L") ext() translate([W / 2, D / 2, lbl_z]) rotate([90, 0, 90]) linear_extrude(1.2, center = true) pixel_text("meety", lbl_p);
                   else ext() translate([-W / 2, D / 2, lbl_z]) rotate([90, 0, -90]) linear_extrude(1.2, center = true) pixel_text("meety", lbl_p);
module body() difference() { side_m() body_r(); label_cut(); }

module body_shell() {
    difference() { vox(-NX / 2, 0, 0, NX, ND, NH); for (sx = [-1, 1], sy = [0, 1]) translate([sx * W / 2, sy * D, H]) cube([2 * p, 2 * p, 2 * p], center = true); }
    // rim: one voxel proud all round, notched corners, 45° corbel underneath
    difference() {
        union() {
            vox(-NX / 2 - 1, -1, NH - 1, NX + 2, ND + 2, 1);
            for (s = [-1, 1]) corbel_x(0, D, H - p, p, s);
            for (s = [0, 1]) corbel_y(-W / 2, W / 2, H - p, p, s ? 1 : -1, s ? D : 0);
        }
        for (sx = [-1, 1], sy = [0, 1]) translate([sx * (W / 2 + p), -p + sy * (D + 2 * p), H - p]) cube([2 * p, 2 * p, 2 * p + 0.1], center = true);
    }
    // fork sleeves high on the sides (front-load dumpster style), above the USB port, open at both ends, + corbels
    for (sx = [-1, 1]) {
        difference() {
            vox(sx > 0 ? NX / 2 : -NX / 2 - 1, 0, NH - 3, 1, ND, 1);
            for (y = [-1, D - 1.5]) translate([sx * (W / 2 + p / 2) - q / 2, y, (NH - 3) * p + q / 2]) cube([q, 2.5, q]);
        }
        corbel_x(0, D, (NH - 3) * p, p, sx);
    }
    // steel corner posts on the vertical edges, up to the rim corbel
    for (x = [-W / 2, W / 2], y = [0, D]) translate([x - q, y - q, 0]) cube([p, p, (NH - 2) * p]);
    // back: ribs behind the lid barrels and between the lids, hinge shelf on top
    for (x = [lid_x0[0] + lw / 2, (lid_x0[0] + lw + lid_x0[1]) / 2, lid_x0[1] + lw / 2])
        translate([x - p / 2, D - 0.01, 0]) cube([p, q + 0.01, (NH - 2) * p]);
    translate([-W / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(W)
        polygon([[D - 0.01, shelf_z], [shelf_y, shelf_z], [shelf_y, shelf_z - shelf_t], [D - 0.01, shelf_z - shelf_t - (shelf_y - D)]]);
}
q = p / 2;                 // detail pixel

// wheels ×4 (black, like the lids): pixel disc, recessed hub, square peg pressed (+ CA) into a blind pocket in the
// side wall. They float 0.3 over the table so the body's flat base still sits on the tape.
wheel_bm = [" XXX ", "XXXXX", "XXOXX", "XXXXX", " XXX "];   // O = recessed hub
wheel_t = 2.0; wheel_hub = 0.6; peg = [2.5, 1.4]; peg_clr = 0.05;
wheel_y = [q + 2.5 * q, D - q - 2.5 * q];      // centres (exterior Y), clear of the corner posts
wheel_z = 0.3 + 2.5 * q;
module px_bm(bm, chars, s) for (r = [0 : len(bm) - 1], c = [0 : len(bm[r]) - 1])
    if (search(bm[r][c], chars) != []) translate([c * s, (len(bm) - 1 - r) * s]) square(s + 0.001);
// wheel frame: outer face on z=0, peg up (+z)
module wheel_flat() {
    linear_extrude(wheel_hub + 0.01) translate([-2.5 * q, -2.5 * q]) px_bm(wheel_bm, "X", q);
    translate([0, 0, wheel_hub]) linear_extrude(wheel_t - wheel_hub) translate([-2.5 * q, -2.5 * q]) px_bm(wheel_bm, "XO", q);
    translate([-peg[0] / 2, -peg[0] / 2, wheel_t - 0.01]) cube([peg[0], peg[0], peg[1] + 0.01]);
}
module wheel_at(sx, y) translate([sx * (W / 2 + wheel_t), y, wheel_z]) rotate([0, -sx * 90, 0]) wheel_flat();
module wheel_pockets() for (sx = [-1, 1], y = wheel_y)
    translate([sx * (W / 2 - (peg[1] + 0.1) / 2 + 0.01), y, wheel_z]) cube([peg[1] + 0.1 + 0.02, peg[0] + 2 * peg_clr, peg[0] + 2 * peg_clr], center = true);

module body_r() union() {
    difference() {
        union() {
            difference() {
                extr() body_shell();
                translate([-xi, y_skin, floor_z]) cube([2 * xi, yb - y_skin, H]);    // hollow
            }
            intersection() {
                union() { core_add(zc, floor_z, yb); anchor_clamp(zc, xl, [y_cback + 0.25, yb]); }
                extr() vox(-NX / 2, 0, 0, NX, ND, NH);
            }
        }
        core_cut(zc, floor_z);
        extr() wheel_pockets();
        usb_port();
        extr() for (i = [0, 1], j = [0, 1]) translate([fin_xe(i, j) - fin_cx, 0, 0]) rotate([90, 0, 90]) linear_extrude(fin_t + 2 * fin_cx)
            polygon([[D + p - 0.01, fin_root + p - 0.01], [shelf_y + 1, fin_root + shelf_y + 1 - D], [shelf_y + 1, H + p], [D + p - 0.01, H + p]]);   // fin slots
    }
    extr() fins();
}

// hinge fins: plate on a 45° gusset off the back wall, free above the gusset, round top around the axis; cone dimple
// on the face toward the barrel, made as the bump shifted bump_pre toward the barrel (+0.3 deeper for the tip)
module fins() for (i = [0, 1], j = [0, 1]) difference() {
    let(yF = ax_y - fin_r, yB = ax_y + fin_r) translate([fin_xe(i, j), 0, 0]) rotate([90, 0, 90]) linear_extrude(fin_t)
        polygon(concat([[D - 0.01, fin_root - (yB - D)], [yB, fin_root]], arc([ax_y, ax_z], fin_r, 0, 180),
                       [[yF, fin_root + yF - D], [D - 0.01, fin_root]]));
    let(s = j == 0 ? -1 : 1) translate([lid_x0[i] + xb[j] - s * bump_pre, ax_y, ax_z]) rotate([0, s * 90, 0])
        cylinder(r1 = bump_r, r2 = bump_r - bump_h - 0.3, h = bump_h + 0.3, $fn = 32);
}

// ---------- lids: identical parts ----------
// lid frame: X across (0..lw), Y = along the lid from the hinge axis (y=0) to the free edge, Z = thickness:
// inner face z=0 (on the bed when printing, on the rim when closed), axis at z=kn_r; knuckles stand proud on top.
module lid_flat() difference() {
  union() {
    difference() {
        cube([lw, lid_len, p]);
        translate([fin_x[0] - fin_cx, -1, -1]) cube([fin_t + fin_cx + bump_g, notch_a + 1, p + 2]);
        translate([xb[1], -1, -1]) cube([fin_t + fin_cx + bump_g, notch_a + 1, p + 2]);
    }
    translate([0, 0, kn_r]) rotate([0, 90, 0]) hull() for (x = [[xbl[0], kn_r - kn_ch], [xbl[0] + kn_ch, kn_r], [xbl[1] - kn_ch, kn_r], [xbl[1], kn_r - kn_ch]])
        translate([0, 0, x[0]]) cylinder(r = x[1], h = 0.001, $fn = 40);
    for (j = [0, 1]) translate([xbl[j], 0, kn_r]) rotate([0, j ? 90 : -90, 0]) cylinder(r1 = lb_r, r2 = lb_r - lb_h, h = lb_h, $fn = 32);   // snap bumps
    for (i = [0 : 2]) translate([p + i * (lw - 3 * p) / 2, notch_a + p, p - 0.01]) cube([p, lid_len - notch_a - (i == 1 ? p : 3 * p), 0.8]);   // ribs; the middle one runs out to the handle over the pocket
    translate([lw / 2 - 1.5 * p, lid_len - 0.01, 0]) cube([3 * p, 0.6 * p, p]);    // handle on the free edge
  }
  cp_key(cp_cx, cp_cu, cp_cz, -1);                                             // coupling pocket
}
// a = opening angle: 0 closed on the rim, 90 upright, ≈205 flipped back onto the shelf
module at_lid(i, a) ext() translate([lid_x0[i], ax_y, ax_z]) rotate([-a, 0, 0]) mirror([0, 1, 0]) translate([0, 0, -kn_r]) children();
module lid(i, a = 0) at_lid(i, a) lid_flat();
// coupling key (lid frame), grown by the clearances for the pocket; zb = bottom (below the inner face)
module cp_key(cx = 0, cu = 0, cz = 0, zb = -0.3) translate([lw / 2 - cp_w / 2 - cx, 0, 0]) rotate([90, 0, 90]) linear_extrude(cp_w + 2 * cx)
    polygon([[cp_u[0] - cu, zb], [cp_u[1] + cu - zb * cp_k, zb], [cp_u[1] + cu - (cp_h + cz) * cp_k, cp_h + cz], [cp_u[0] - cu, cp_h + cz]]);

// ---------- deck + trash (internal frame) ----------
deck_py = [y_skin + deck_clr, yb - deck_clr];
// [x, y, w, d, h]: on the plate, clear of the leaves, fence and light-pipe notch; h ≤ 2.2 so closed lids clear them
bags = [[14.5, 3.8, 5, 4.8, 2.2], [15.5, 12.3, 4, 5, 2.0], [3, 12.8, 6, 4, 2.2], [-5.5, 12.6, 5, 3.5, 1.9], [-12.3, 8.1, 3.4, 2.6, 1.7], [12, 8.0, 2.8, 2.6, 1.7]];

// ---------- button: deck + flame, press-fitted ----------
// fire build (v0.19): flame and light pipe are one part, solid since v0.21 (was hollow; infill is now the slicer's job).
// Its stem (the old light pipe footprint) presses into the ribbed U and ends over the PMMA edge, so LED1 lights it; a block round the stem
// stands on the deck (vertical stop) and carries the flame up over the front rim. The flame's top is the lids' inner
// plane at lid_rest: both lids lie on it. Above that plane only the front fl_t of the flame exists, in front of the lid
// edges and handles, so the tips stand in front of the lids. Pixels are front-flush. Prints FRONT FACE DOWN; the
// stem/block front sits behind the body's front wall, so it is a ceiling 6.6 over the bed -> supports from the plate.
// v0.20: a key per lid stands on the lid plane (cp_key) and drops into a pocket in the lid; tips stay fl_lx clear beside the handles.
fp = 1.75;                 // flame pixel
fl_bm = [                  // row 0 = top; X outer, O mid, Y core
    "  X          X      ",
    "  XX     X   XX     ",
    "  XOX   XX   XOX  X ",
    " XXOX  XOX  XXOX XX ",
    " XOOXX XOXX XOOXXOX ",
    "XXOYOXXOOOXXOYOXOOXX",
    "XOOYYOOOYOOOOYYOOYOX",
    "XOYYYYOYYYYOYYYYYYOX",
    "XOOYYYYYYYYYYYYYYOOX",
    " XOOOOOOOOOOOOOOOOX ",
];
fl_gap = 1.2;              // flame bottom over the front rim (the far end dips ≈1.0 at full button travel)
fl_lc = 0.3;               // tips in front of the lid edge / handle
fl_lx = 0.9;               // tips beside a handle: full button travel rolls the flame ≈0.56 sideways at handle height
fl_bx = 7;                 // block round the stem, half width (internal X)
fl_yb = stem_y[1];         // back of the stem, block and flame
fl_yf = y_face - 2 * p;    // flame front: a voxel in front of the rim
fl_z0 = H + fl_gap;        // flame bottom
fl_xo = side == "L" ? -x_ext : x_ext;          // centred on the body (ext X = 0), the stem stays on the switch
NR = len(fl_bm); NC = len(fl_bm[0]);
// lid inner face at lid_rest (internal Y, Z): axis + kn_r along n, front edge lid_len along d (handle 0.6 p further)
fl_ax = [ax_y + y_face, ax_z];
fl_n = [-sin(lid_rest), -cos(lid_rest)]; fl_dl = [-cos(lid_rest), sin(lid_rest)];
fl_edge = fl_ax + kn_r * fl_n + lid_len * fl_dl;                // plate inner front corner
fl_hedge = fl_ax + kn_r * fl_n + (lid_len + 0.6 * p) * fl_dl;   // handle inner front corner
fl_hx = [for (i = [0, 1]) [lid_x0[i] + lw / 2 - 1.5 * p - fl_lx, lid_x0[i] + lw / 2 + 1.5 * p + fl_lx] + [fl_xo, fl_xo]];
// [x0, x1, back of the tips]: in front of the plate edge, further forward at the handles (both lean back going up)
fl_zones = [[-40, fl_hx[0][0], fl_edge[0] - fl_lc], [fl_hx[0][0], fl_hx[0][1], fl_hedge[0] - fl_lc], [fl_hx[0][1], fl_hx[1][0], fl_edge[0] - fl_lc],
            [fl_hx[1][0], fl_hx[1][1], fl_hedge[0] - fl_lc], [fl_hx[1][1], 40, fl_edge[0] - fl_lc]];
plinth_x = 5 * fp; plinth_d = 8;               // fire = false: clear plinth on the deck
assert(-plinth_x > xl + 0.2 + anchor_w + leaf[0] + 0.2, "plinth runs into the leaves");
assert(-fl_bx > xl + 0.2 + anchor_w + leaf[0] + 0.2, "flame block runs into the leaves");
assert(len([for (b = bags) if (abs(b[0]) - b[2] / 2 < fl_bx + 0.3 && b[1] - b[3] / 2 < fl_yb + 0.3) 1]) == 0, "flame block hits a bag");
assert(deck_top(zc) + max([for (b = bags) b[4]]) < fl_z0 - 1.2, "flame comes down onto the bags");
assert(fl_hedge[0] - fl_lc - fl_yf >= fp - 0.05, "tips too thin in front of the handles");
module fl_cells(chars) for (r = [0 : NR - 1], c = [0 : NC - 1]) if (search(fl_bm[r][c], chars) != [])
    translate([fl_xo + (c - NC / 2) * fp, fl_z0 + (NR - 1 - r) * fp]) square(fp + 0.001);
module fl_y(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();   // 2D (X, Z) → y0..y1
// where the flame may be: under the lids' plane, or in front of their edges
module fl_keep() union() {
    translate([0, fl_ax[0], fl_ax[1]]) rotate([-lid_rest, 0, 0]) translate([-50, -50, -kn_r - 100]) cube(100);
    for (z = fl_zones) translate([z[0], fl_yf - 1, 0]) cube([z[1] - z[0], z[2] - fl_yf + 1, 100]);
}

// pixel trash on a 0.6 grid: tied bags (two tiers, clipped corners, knot) and a tin can lying along X
tq = 0.6;
module clip2(w, dd, c) difference() { square([w, dd]); for (x = [0, w - c], y = [0, dd - c]) translate([x - 0.001, y - 0.001]) square(c + 0.002); }
module px_bag(w, dd, h) {
    linear_extrude(h * 0.55) clip2(w, dd, tq);
    translate([tq, tq, h * 0.55 - 0.01]) linear_extrude(h * 0.3) clip2(w - 2 * tq, dd - 2 * tq, tq);
    translate([w / 2 - tq / 2, dd / 2 - tq / 2, h * 0.85 - 0.02]) cube([tq, tq, h * 0.15 + 0.02]);
}
module px_can(w, dd, h) {
    rotate([90, 0, 90]) linear_extrude(w) translate([0, 0]) union() {
        translate([tq, 0]) square([dd - 2 * tq, h]);
        translate([0, tq]) square([dd, h - 2 * tq]);
    }
    for (x = [tq, w - 2 * tq]) translate([x, -0.15, tq - 0.15]) cube([tq, dd + 0.3, h - 2 * tq + 0.3]);   // rims
}
module deck_part() {
    deck(zc, xl, deck_py) translate([-xi, y_skin]) square([2 * xi, yb - y_skin]);
    for (i = [0 : len(bags) - 1]) let(b = bags[i]) translate([b[0] - b[2] / 2, b[1] - b[3] / 2, deck_top(zc) - 0.01])
        if (i == 4) px_can(b[2], b[3], b[4]); else px_bag(b[2], b[3], b[4]);
}
// no-fire plinth top: a bed of pixel coals (# top, + 0.35 down, space = 0.7-deep crack), cut down so lids still close
coals = ["#### ##+# ### ", "#+## # ### ##+", "### ### #+####", " ## +## ### + ", "#+# ###+# #+##", "### ##+## ####"];
module pipe_part() {
    light_pipe(zc);
    difference() {
        translate([-plinth_x, stem_y[0], deck_top(zc)]) cube([2 * plinth_x, plinth_d, fp]);
        for (c = [["+ ", 0.35], [" ", 0.7]]) translate([-plinth_x, stem_y[0] + (plinth_d - 6 * q) / 2, deck_top(zc) + fp - c[1]])
            linear_extrude(1) px_bm(coals, c[0], q);
    }
}
// fire build: stem + block + flame, solid (v0.21)
module flame() union() {
    for (i = [0, 1]) at_lid(i, lid_rest) cp_key();                                  // coupling keys
    light_pipe(zc);
    translate([-fl_bx, stem_y[0], deck_top(zc)]) cube([2 * fl_bx, fl_yb - stem_y[0], fl_z0 - deck_top(zc) + 0.01]);
    intersection() { fl_y(fl_yf, fl_yb) fl_cells("XOY"); fl_keep(); }
}

// ---------- assembly / print layout ----------
module P(name) if (part == "all" || part == name) children();

if (!print) {
    P("body") body();
    P("cartridge") cartridge(zc, side);
    P("deck") side_m() deck_part();                                 // at rest = as printed
    if (fire) P("flame") flame(); else P("light_pipe_nf") pipe_part();
    if (fire && part == "light_pipe_nf") pipe_part();
    P("lid_l") lid(0, lid_ang[0]);
    P("lid_r") lid(1, lid_ang[1]);
    P("lid_l0") lid(0, 0);                                        // closed poses, for the hinge sweep check
    P("lid_r0") lid(1, 0);
    P("wheels") ext() for (sx = [-1, 1], y = wheel_y) wheel_at(sx, y);
    P("glass") if (side == "L") rot_l(zc) screen_face(zc); else screen_face(zc);
    if (show_board) P("board") cart_tf(zc, side) { import("meety-case/ref/waveshare_board_shellframe_wt.stl"); import("meety-case/ref/waveshare_board_shellframe_hulls.stl"); }
} else {
    if (part == "body") body();                                                   // upright, base on the bed; organic supports under the window bridge
    if (part == "wheel") wheel_flat();                                            // print 4; outer face down
    if (part == "lid") lid_flat();                                                // print 2; ribs up
    if (part == "deck") translate([0, 0, -(zc + cart_hz + pl_rest)]) side_m() deck_part();   // flat, bags up, plunger tip on the bed: supports under the plate
    if (part == "flame") translate([0, 0, -fl_yf]) rotate([90, 0, 0]) flame();              // front face down; supports under the stem/block front
    if (part == "light_pipe_nf") translate([0, 0, -stem_y[0]]) rotate([90, 0, 0]) pipe_part();       // front face down: light runs along the layers
    if (part == "cartridge") translate([0, 0, -z_front]) from_dumpster(zc) if (side == "L") rot_l(zc) cartridge(zc, "L"); else cartridge(zc);   // skirt edge down, like meety-case
}
