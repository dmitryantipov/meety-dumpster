// meety-dumpster core: everything that is the same whatever the dumpster looks like (dumpster frame, common.scad).
//
//  cartridge  meety-case v2 shell minus the stand and the in-wall buttons (board screws in as before; the top-wall
//             switch stem just pokes out of its notch) + a light
//             notch over the PMMA top edge (LED1 glow), a wire hole for an optional flame LED, and a pad the deck
//             anchor rests on
//  bezel      1.2 skin in front of the glass (y_face .. y_skin), 0.8 over the screen pocket; beveled window sized so
//             no pixel hides at view_a off-axis; the flex/driver ledge stays hidden behind it
//  fit        the cartridge drops STRAIGHT down into its final place: side walls hug it (fit_x), the skirt lands on
//             a frame band below the glass + strips beside it, spring fingers in front of the back wall press it forward,
//             one in the non-USB wall presses it onto the USB-side wall; each finger sits in a rigid cage (overtravel
//             stop behind, cheeks beside) so it can't be snapped.
//             Nothing may stick out of the walls in the cartridge's Y span above it (that is the drop path).
//  deck       "trash floor": rigid plate on two leaf flexures from an anchor bar (clamp on the side wall behind the
//             cartridge, pad on the cartridge top in front). A plunger under the plate (one part with it since v0.20) presses the
//             top-wall switch stem directly; its head lands on the cartridge wall = hard stop.
//  light pipe clear stem from over the PMMA top edge up through the deck; press-fits into a ribbed U in the deck and
//             moves with it (deck + pipe + flame = one button)
//  usb port   through the side wall for the USB-C plug head (concept cuts it)
//  push-out   two holes through the floor: push the cartridge up from below to take it out
include <common.scad>
use <meety-case/shell.scad>

y_skirt   = z_front - z_glass_s;                  // 3.4  cartridge front (skirt edge)
y_cback   = z_back - z_glass_s;                   // 10.7 cartridge back face
y_flange  = z_flange - z_glass_s;                 // 9.4  back face of the cartridge flange
cart_hx   = cav[0] / 2 + wall;                    // 19.15
cart_hz   = cav[1] / 2 + wall;                    // 10.95 (outer top wall face above zc)
cav_hz    = cav[1] / 2;                           // 10.15 (inner top wall face)
hood_dz   = y_wb_hood + wb_hood_t - yc_s;         // 12.45 hood outer face above zc

// bezel + fit
y_face    = -1.25;                                // dumpster front face
y_skin    = -0.05;                                // bezel back face: glass face 0.05 behind it, TFT glass 0.2
// window (v0.12): no active pixel hidden up to view_a off-axis. At the skin back the opening is win_m outside the active
// area (still over the black polarizer border), then bevels out at view_a to the front face
win_m     = 0.5;
view_a    = 45;
act_hw    = [32.35 / 2, 17.39 / 2];               // active area half-size (centre X active_c), rounded like the polarizer
// screen pocket (v0.12, a v0.11 glass cracked on the way in): glass to bezel / strips / band, X Y Z. The pocket runs from
// the band up out of the rim (drop path) and back to the skirt stop plane (left strip + band stay as the Y stop)
scr_gap   = [0.5, 0.45, 0.5];
scr_y1    = y_skirt;
fit_x     = 0.05;                                 // per side, cartridge to side walls (press fit; FDM eats the rest)
xi        = cart_hx + fit_x;                      // 19.2 side wall inner face
// back springs (v0.4 rigid rails were far too tight): fingers rooted in the floor, free behind; a bump near the top
// reaches rail_pre into the cartridge and the finger bends back. Lower down the finger face stays rail_gap off the
// cartridge (backstop). ≈ 4 N/mm per finger at the bump (PLA, t³ scaling).
rail_x    = [-10, 0, 10];                         // clear of the screw-head recesses at X ≈ ±16
rail_w    = 4;
rail_t    = 1.8;
rail_gap  = 0.3;
rail_pre  = 0.3;
rail_rf   = 1.0;                                  // root fillets: front one sits in the cartridge's bottom-back notch
rail_rb   = 1.5;                                  // (y 9.4..10.7, z < floor + 0.8); back one has 3.45 to the wall
// finger cage (v0.11): rigid U off the back wall + floor, cheeks rail_side beside the finger, rail_cheek thick. Back
// stop rail_stop behind the finger top = the max flex (v0.12: 0.8 was reached by a seated cartridge on the print).
// 1.5 at the top ≈ 1.0 % root strain (1.5·t·δ/L², L 20): the limit across PLA layers, comfortable in PETG
rail_stop  = 1.5;
rail_side  = 0.5;
rail_cheek = 1.2;
// side finger (v0.12) in the thick non-USB wall (-X in R): same profile, pushes the cartridge onto the USB-side wall
// (fit_x there); the -X wall stands rail_gap off the cartridge. Thinner + shorter stop so the outer skin keeps 1.4
// (under the 0.6-deep "meety" label). Y centre clear of the front wheel pocket, on the flat end face (y 3.4..9.4,
// z 5.3..21.6 between the shell's r2.8 corners)
side_y    = 7.3;
side_t    = 1.5;
side_stop = 1.2;
side_rb   = 1.0;
flex_rel  = [0.5, 0.3];                           // display flex at the USB end of the glass (STEP: x ≤ 19.0, y 0.15..2.1,
flex_rz   = 7;                                    // z ±6.2): pocket into the side wall / bezel skin back from zc - flex_rz up
// push-out holes through the floor under the cartridge bottom wall (clear of the switch notch and, in L, the light notch)
push_x    = [-7.25, 7.25];
push_y    = 6.4;
push_d    = 4.0;
ledge_z   = glass_hz + 0.2;                       // frame band top below zc: the glass bottom clears it

// PMMA light guide (STEP): top edge zc + 9.655, Y 1.55..4.25; LED1 under the LCD at X ≈ 0
pmma_top  = 9.655;
pipe_x    = 4.75;                                 // v0.4 light pipe half-width (sets the cartridge notch)
pcb_y0    = z_pcb_back - pcb[2] - z_glass_s;      // 4.3 PCB front face
notch_c   = [pipe_x + 0.2, 5.6];                  // cartridge light notch: |X| and back Y
// the stem rides with the deck: 0.5 clear of the notch sides / 0.45 of the bezel and notch back (deck play is 0.4),
// and pipe_gap above the PMMA edge + PCB top at rest (full 0.8 hood stroke moves its corner down ≤ 0.56)
stem_x    = 4.45;
stem_y    = [0.4, 5.15];
pipe_gap  = 0.6;
// press fit: half-round crush ribs stand pf proud of a pf_clr-clear wall (stem in the deck)
pf        = 0.15;
pf_clr    = 0.1;
rib_r     = 0.4;
wire_hole = [3, [6.2, 7.4]];                      // cartridge top wall: X width, Y span (behind the PCB)

// USB-C: receptacle centre (Y, Z) and the plug head the port is cut for
usb_y     = (z_pcb_back + usb_c[2] / 2) - z_glass_s;   // 6.73
usb_mouth_x = xc_s - (board_dx - usb_c_proud);    // 19.41 receptacle mouth (0.26 proud of the cartridge)
usb_head  = [11.4, 6.0];                          // port Z × Y stadium: plug head ≈ 10.6 × 5.1 (photo) + clearance
usb_rcpt  = [9.58, 3.25];                         // receptacle Z × Y (needs a relief slot down the wall)
notch_relief = [[9.6, 14.3], [2.75, 7.65]];        // floor pocket under the bottom-wall switch notch (X, Y)

// deck / flexure
deck_t    = 1.6;
anchor_w  = 4;                                    // anchor bar X width
leaf      = [4.9, 5, 0.6];                        // length X, width Y, thickness Z (front + back edge)
slit      = 0.8;
deck_clr  = 0.4;                                  // deck edge to walls
deck_pre  = 0.15;                                 // as printed, the plate sits this far below the v0.9 hood top (the
                                                  // body's anchor clamp is built for it); no hood since v0.10, so the
                                                  // deck stays at its as-printed height
// plunger (v0.10, part of the deck since v0.20): tip rests pl_rest over the cartridge wall top; the head lands on the wall
// after pl_travel. pl_rest 0.4 = the smallest of the v0.11 test set (just touches the STEP stem).
pl_rest   = 0.4;
pl_travel = 0.6;
pl_tip    = [1.2, 1.2];                           // X × Y, into the 2.8 × 3.5 stem notch
pl_head   = [4.8, 2.8];                           // X × Y, lands on the wall top beside / behind the notch
function pl_c(zc) = [stem_tip(zc)[0], stem_tip(zc)[1] - pl_tip[1] / 2];   // X centre, front Y (all parts flush there)
deck_rib_y = [1.6, 4.1];                          // crush ribs on the sides of the stem U
lip       = 2.2;                                  // anchor bevel / clamp lip

function deck_z(zc) = zc + hood_dz;               // v0.9 hood top (reference only)
function deck_z0(zc) = deck_z(zc) - deck_pre;     // as printed / anchor bottom
function deck_top(zc) = deck_z0(zc) + deck_t;

// side "R": USB-C on the right, BOOT edge up. side "L": board turned 180° in the screen plane -> USB-C on the left,
// the OTHER side switch is on top (the y=0-wall switch; RESET per the meety-case notes) and gets the hood.
module rot_l(zc) translate([0, 0, zc]) rotate([0, 180, 0]) translate([0, 0, -zc]) children();
module cart_tf(zc, side = "R") if (side == "L") rot_l(zc) to_dumpster(zc) children(); else to_dumpster(zc) children();
module from_dumpster(zc) multmatrix([[-1, 0, 0, xc_s], [0, 0, 1, yc_s - zc], [0, 1, 0, z_glass_s], [0, 0, 0, 1]]) children();

// ---------- cartridge (prints like meety-case: skirt edge down, supports in the cavity only) ----------
module cartridge(zc, side = "R") {
    s = side == "L" ? 1 : -1;                     // anchor end of the deck: far from the USB port
    difference() {
        union() {
            cart_tf(zc, side) union() {
                difference() {
                    outer_block();
                    cavity(); pocket(); holes(); recesses(); usb_cut(); notches();
                }
            }
            // pad under the deck anchor bar (0.1 below it at rest); starts in the top wall, clear of the cavity and
            // its r2 corner
            translate([s > 0 ? 15.4 : -17.3, y_skirt, zc + cav_hz + 0.05]) cube([1.9, y_flange - y_skirt, deck_z0(zc) - 0.1 - (zc + cav_hz + 0.05)]);
        }
        // light notch (open at the skirt edge, like the button notches) + wire hole
        translate([-notch_c[0], y_skirt - 1, zc + cav_hz - 0.5]) cube([2 * notch_c[0], notch_c[1] - y_skirt + 1, 2]);
        translate([-wire_hole[0] / 2, wire_hole[1][0], zc + cav_hz - 0.5]) cube([wire_hole[0], wire_hole[1][1] - wire_hole[1][0], 2]);
    }
}

// light pipe stem (as printed = at rest): from pipe_gap over the PMMA edge up
// to the deck top; the concept puts something on top that rests on the deck (vertical stop)
module light_pipe(zc) {
    zt = deck_top(zc) + 0.01;
    // only the front part reaches down to the PMMA edge; behind Y 4.2 the PCB top edge (zc + 10.17) is in the way
    for (b = [[pcb_y0 - 0.1, pmma_top], [stem_y[1], pcb[1] / 2]]) let(zb = zc + b[1] + pipe_gap)
        translate([-stem_x, stem_y[0], zb]) cube([2 * stem_x, b[0] - stem_y[0], zt - zb]);
}

// plunger at rest, hanging off the plate underside: tip over the stem, head under the plate
module plunger(zc) {
    w = zc + cart_hz; c = pl_c(zc);
    translate([c[0], c[1], 0]) {
        translate([-pl_tip[0] / 2, 0, w + pl_rest]) cube([pl_tip[0], pl_tip[1], pl_travel - pl_rest + 0.01]);
        translate([-pl_head[0] / 2, 0, w + pl_travel]) cube([pl_head[0], pl_head[1], deck_z0(zc) - w - pl_travel + 0.01]);
    }
}

// half-round crush ribs along Z (0..h) on both X faces of a press-fit hole whose walls are at ±(x + pf_clr); tips at
// ±(x - pf). Tapered at the end the mating part comes in from (top, or bottom with top = false).
module crush_ribs(x, ys, h, top = true) for (sx = [-1, 1], y = ys) translate([sx * (x - pf + rib_r), y, 0])
    translate([0, 0, top ? 0 : h]) mirror([0, 0, top ? 0 : 1]) {
        cylinder(r = rib_r, h = h - 0.4, $fn = 16);
        translate([0, 0, h - 0.41]) cylinder(r1 = rib_r, r2 = rib_r - pf - 0.05, h = 0.41, $fn = 16);
    }

// ---------- body additions / cuts (R frame; the concept clips core_add with its own outer solid) ----------
// spring finger profile (u = away from the cartridge face u0, z up): long lead-in on top, contact flat, 45° underside
// so the bump prints unsupported; concave root fillets so the finger can't snap off at the floor
function arc(c, r, a0, a1) = [for (i = [0 : 8]) c + r * [cos(a0 + (a1 - a0) * i / 8), sin(a0 + (a1 - a0) * i / 8)]];
function finger_pts(u0, t, rb, floor_z, zt) = let(uf = u0 + rail_gap, ut = u0 - rail_pre, ur = uf + t)
    concat([[uf - rail_rf, floor_z - 0.01], [ur + rb, floor_z - 0.01]], arc([ur + rb, floor_z + rb], rb, 270, 180),
           [[ur, zt], [uf, zt], [ut, zt - 2], [ut, zt - 5 + (uf - ut)], [uf, zt - 5]],
           arc([uf - rail_rf, floor_z + rail_rf], rail_rf, 0, -90));
function finger_zt(zc) = zc + cav_hz - 1;
module side_finger(zc, floor_z) translate([0, side_y + rail_w / 2, 0]) rotate([90, 0, 0]) linear_extrude(rail_w)
    mirror([1, 0]) polygon(finger_pts(cart_hx, side_t, side_rb, floor_z, finger_zt(zc)));
// its pocket in the wall: stop face side_stop behind the finger, 45° roof rising toward the cartridge
module side_pocket(zc, floor_z) let(us = cart_hx + rail_gap + side_t + side_stop, zt = finger_zt(zc) + 0.3)
    translate([0, side_y + rail_w / 2 + rail_side, 0]) rotate([90, 0, 0]) linear_extrude(rail_w + 2 * rail_side)
        mirror([1, 0]) polygon([[xi - 0.01, floor_z], [us, floor_z], [us, zt], [xi - 0.01, zt + us - xi]]);

// yb = back wall inner face
module core_add(zc, floor_z, yb) {
    // frame: band under the glass + strips beside it; the skirt lands on these (Y stop)
    translate([-xi, y_skin - 0.01, floor_z - 0.01]) cube([2 * xi, y_skirt - y_skin + 0.01, zc - ledge_z - floor_z + 0.01]);
    for (x = [[-xi, glass_x[0] - 0.2], [glass_x[1] + 0.2, xi]])
        translate([x[0], y_skin - 0.01, floor_z - 0.01]) cube([x[1] - x[0], y_skirt - y_skin + 0.01, zc + cart_hz - floor_z]);
    // back spring fingers (YZ profile) + the side finger
    zt = finger_zt(zc); yf = y_cback + rail_gap; yr = yf + rail_t;
    for (x = rail_x) translate([x - rail_w / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(rail_w)
        polygon(finger_pts(y_cback, rail_t, rail_rb, floor_z, zt));
    side_finger(zc, floor_z);
    // cages: stop face vertical down to clear of the back fillet, then 45° back to the floor (prints unsupported)
    ys = yr + rail_stop; z1 = floor_z + max(rail_rb + 1 - rail_stop, 0.5); hw = rail_w / 2 + rail_side + rail_cheek;
    for (x = rail_x) {
        translate([x - hw, 0, 0]) rotate([90, 0, 90]) linear_extrude(2 * hw)
            polygon([[ys, zt], [ys, z1], [ys + z1 - floor_z, floor_z - 0.01], [yb + 0.01, floor_z - 0.01], [yb + 0.01, zt]]);
        for (sx = [-1, 1]) translate([x + sx * (rail_w / 2 + rail_side + rail_cheek / 2) - rail_cheek / 2, yf + 0.3, floor_z - 0.01])
            cube([rail_cheek, yb - yf - 0.3 + 0.01, zt - floor_z + 0.01]);
    }
}

win_yk = y_skin - scr_gap[1];                   // skin back face (window at its smallest)
win_r0 = vis_r - 0.15;
lip_t  = 0.4;                                   // straight land at the window edge before the bevel (v0.16: no knife edge)
module win2d(o) translate([active_c, 0]) offset(r = win_r0 + o, $fn = 48) square(2 * (act_hw + [win_m, win_m] - [win_r0, win_r0]), center = true);

module core_cut(zc, floor_z) {
    // side finger pocket + the -X wall set rail_gap off the cartridge end (drop path: all the way up)
    difference() {
        union() {
            side_pocket(zc, floor_z);
            translate([-cart_hx - rail_gap, y_skirt, floor_z]) cube([cart_hx + rail_gap - xi + 0.01, y_cback - y_skirt, 50]);
        }
        side_finger(zc, floor_z);
    }
    // bezel window: active area + win_m at the skin back, straight for lip_t, then beveled out at view_a to the front face
    for (ys = [[win_yk + 0.01, win_yk - lip_t], [win_yk - lip_t, y_face - 1]]) hull() for (y = ys)
        translate([0, y, zc]) rotate([90, 0, 0]) linear_extrude(0.01) win2d(max(win_yk - lip_t - y, 0) * tan(view_a));
    // screen pocket: scr_gap around the glass, from the band up out of the top
    translate([glass_x[0] - scr_gap[0], win_yk, zc - glass_hz - scr_gap[2]]) cube([glass_x[1] - glass_x[0] + 2 * scr_gap[0], scr_y1 - win_yk, 50]);
    // flex relief at the USB end, from below the flex up out of the rim (drop path); stops at y 2.7 so the skirt keeps
    // a landing strip on that side
    translate([glass_x[1] - 0.6, y_skin - flex_rel[1], zc - flex_rz]) cube([xi + flex_rel[0] - glass_x[1] + 0.6, 2.7 - y_skin + flex_rel[1], 50]);
    // relief down the right wall for the proud receptacle (drop path) + floor pocket under the bottom switch stem
    translate([xi - 0.01, usb_y - usb_rcpt[1] / 2 - 0.5, zc - usb_rcpt[0] / 2 - 0.5]) cube([usb_mouth_x - xi + 0.5, usb_rcpt[1] + 1.0, 50]);
    translate([notch_relief[0][0], notch_relief[1][0], floor_z - 1]) cube([notch_relief[0][1] - notch_relief[0][0], notch_relief[1][1] - notch_relief[1][0], 1.01]);
    for (x = push_x) translate([x, push_y, -1]) cylinder(d = push_d, h = floor_z + 1.01, $fn = 32);
}

// anchor clamp on the left wall (xl = wall inner face): shelf under the anchor bar + 45° lip over its beveled edge.
// Deck goes in tilted: left edge under the lip, then lower the right side onto the hood. ys = Y span.
module anchor_clamp(zc, xl, ys) {
    z0 = deck_z0(zc); z1 = z0 + deck_t;
    g = 0.15 * sqrt(2);
    module yz(pts) translate([0, ys[1], 0]) rotate([90, 0, 0]) linear_extrude(ys[1] - ys[0]) polygon(pts);
    yz([[xl - 1, z0], [xl + anchor_w + 0.2, z0], [xl - 1, z0 - anchor_w - 1.2]]);                       // shelf, 45° underside
    yz([[xl - 1, z1 - lip - 1 + g], [xl + lip, z1 + g], [xl + lip, z1 + 0.6], [xl - 1, z1 + 0.6 + lip + 1]]);  // lip
}

// ---------- deck (prints flat, top up, on the plunger tip: build-plate supports under the plate) ----------
// children(0) = 2D outline of the opening at deck height (wall inner faces). xl = left wall inner face,
// py = [front, back] Y of the plate. Bags / fire collar are added by the concept.
module deck(zc, xl, py) {
    a0 = xl + 0.2; a1 = a0 + anchor_w;
    bands = [[py[0], py[0] + leaf[1]], [py[1] - leaf[1], py[1]]];
    translate([0, 0, deck_z0(zc)]) {
        difference() {                                // anchor bar, top-left edge beveled for the lip
            intersection() {
                linear_extrude(deck_t) offset(delta = -deck_clr) children(0);
                translate([a0, -50, 0]) cube([anchor_w, 200, deck_t]);
            }
            translate([a0 - 0.2, 0, deck_t]) rotate([0, 45, 0]) cube([lip * 1.414, 300, lip * 1.414], center = true);
        }
        intersection() {                              // leaves
            linear_extrude(leaf[2]) offset(delta = -deck_clr) children(0);
            for (b = bands) translate([a1 - 0.01, b[0], 0]) cube([leaf[0] + 0.02, b[1] - b[0], leaf[2]]);
        }
        difference() {                                // plate body
            linear_extrude(deck_t) offset(delta = -deck_clr) children(0);
            translate([-100, -50, -1]) cube([a1 + slit + 100, 200, deck_t + 2]);
            for (b = bands) translate([a1 - 1, b[0] - slit, -1]) cube([leaf[0] + 1, b[1] - b[0] + 2 * slit, deck_t + 2]);
            translate([-stem_x - pf_clr, -1, -1]) cube([2 * (stem_x + pf_clr), stem_y[1] + pf_clr + 1, deck_t + 2]);   // stem U
        }
        crush_ribs(stem_x, deck_rib_y, deck_t);
    }
    plunger(zc);
}
