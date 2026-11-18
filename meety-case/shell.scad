// Rear shell + stand for Waveshare ESP32-C6-LCD-1.47
// Parametric rebuild of the Onshape part (mating geometry exact) + button-variant features.
include <BOSL2/std.scad>
include <dimensions.scad>
use <pixel_text.scad>

variant = "slide";   // "slide" | "flex" | "pin" | "wallflex" | "wallflex_flip" | "v2" | "none"   ("slide" and "flex" share rails)
print   = true;      // false → design frame (for overlay checks)

module outer_block() {
    translate([-wall, -wall, z_front])
        cuboid([cav[0] + 2 * wall, cav[1] + 2 * wall, z_flange - z_front],
               rounding = out_r, edges = "Z", anchor = BOTTOM + LEFT + FRONT);
    translate([0, 0, z_flange - eps])
        cuboid([cav[0], cav[1], z_back - z_flange + eps],
               rounding = cav_r, edges = "Z", anchor = BOTTOM + LEFT + FRONT);
}

module cavity() {
    translate([0, 0, z_front - 1])
        cuboid([cav[0], cav[1], 1 + z_floor - z_front],
               rounding = cav_r, edges = "Z", anchor = BOTTOM + LEFT + FRONT);
}

module pocket() {
    translate([0, 0, z_floor - eps])
        linear_extrude(pocket_depth + eps)
            difference() {
                polygon(pocket_poly);
                for (p = boss_pts) translate(p) circle(r = boss_r);
            }
}

// Ø2 through floor into the screw-head recess on the back
module holes() {
    for (p = boss_pts)
        translate([p[0], p[1], z_floor - eps]) cyl(d = hole_d, h = z_flange - z_floor + 2 * eps, anchor = BOTTOM);
}

// screw-head recesses in the slab (z_flange..z_back):
//  USB end: corner cut-outs 4x4 with concave r2 fillet centred on the hole
//  far end: stadium slots 4 wide from the edge, round end centred on the hole
module recesses() {
    h = z_back - z_flange + 2 * eps;
    translate([0, 0, z_flange]) linear_extrude(h) {
        for (p = [boss_pts[0], boss_pts[1]]) {
            sy = p[1] < cav[1] / 2 ? -1 : 1;
            translate(p) circle(r = recess_r);
            translate([p[0] - 3, sy < 0 ? p[1] - 3 : p[1] - 2]) square([3, 5]);   // strip toward end wall
            translate([p[0] - 3, sy < 0 ? p[1] - 3 : p[1]]) square([5, 3]);       // strip toward long wall
        }
        for (p = [boss_pts[2], boss_pts[3]])
            hull() { translate(p) circle(r = recess_r); translate([cav[0] + 1, p[1]]) circle(r = recess_r); }
    }
}

module usb_cut() {
    w = usb_notch_y[1] - usb_notch_y[0];
    translate([-wall - eps, usb_notch_y[0], z_front - eps])
        cube([wall + 2 * eps, w, z_floor - z_front + 2 * eps]);
    translate([-wall - eps, 0, 0]) rotate([90, 0, 90])
        linear_extrude(wall + eps + usb_relief_x)
            hull() {
                for (y = usb_relief_y) translate([y, 0]) circle(r = usb_relief_r);
                translate([usb_notch_y[0], -1]) square([w, 1]);
            }
}

module notches() {
    h = notch_z_top - z_front + eps;
    translate([boot_notch_x[0], cav[1] - eps, z_front - eps])
        cube([boot_notch_x[1] - boot_notch_x[0], wall + 2 * eps, h]);
    translate([reset_notch_x[0], -wall - eps, z_front - eps])
        cube([reset_notch_x[1] - reset_notch_x[0], wall + 2 * eps, h]);
}

// stand leg: YZ profile (parallelogram + root fillet) extruded along X
module stand_leg(root_y = leg_root_y) {
    d  = [-cos(leg_ang), sin(leg_ang)];      // (dy, dz) along leg
    n  = [-sin(leg_ang), -cos(leg_ang)];     // inner-face outward normal
    ro = [root_y, z_back];
    ri = ro - [leg_t, 0];
    to = ro + leg_len * d;
    ti = ri + leg_len * d;
    cz = z_back + leg_r;
    t  = (cz - ri[1] - leg_r * n[1]) / d[1];
    c  = ri + t * d + leg_r * n;             // fillet centre (12.372, 7.1)
    pen = 0.5;
    pts = concat(
        [[c[0], z_back - pen], [c[0], z_back]],
        arc(r = leg_r, cp = c, angle = [-90, 90 - leg_ang], n = 36),
        [ti, to, ro, [ro[0] - 0.3, z_back - pen]]
    );
    translate([leg_x[0], 0, 0]) rotate([90, 0, 90])
        linear_extrude(leg_x[1] - leg_x[0]) polygon(pts);
}

// ---------- V1/V2 rail towers on both end walls ----------
module rail_tower_block(side) {
    x0 = side < 0 ? -wall - tower_t : cav[0] - cav_r;
    x1 = side < 0 ? cav_r : cav[0] + wall + tower_t;
    edge = side < 0 ? LEFT + BACK : RIGHT + BACK;
    translate([x0, tower_y0, z_front])
        cuboid([x1 - x0, y_wall_top - tower_y0, z_back - z_front],
               rounding = 1.5, edges = [edge], anchor = BOTTOM + LEFT + FRONT);
}

// vertical groove (open at top) + deeper undercut at the bottom, in the tower's outer face
module rail_groove(side) {
    xf = side < 0 ? -wall - tower_t : cav[0] + wall + tower_t;   // tower outer face
    z0 = groove_zc - groove_w / 2;
    translate([side < 0 ? xf - eps : xf - groove_d, y_step, z0])
        cube([groove_d + eps, y_wall_top - y_step + 1, groove_w]);
    translate([side < 0 ? xf - eps : xf - undercut_d, undercut_y0, z0])
        cube([undercut_d + eps, y_step - undercut_y0 + eps, groove_w]);
}

// ---------- meety-case: leaf flexure in a band on the top wall ----------
module wall_flexure(nub_x = wf_pad_c[0]) {
    y0 = y_wall_top - eps;
    r  = wf_gap / 2;
    xs = wf_root_x + wf_root_solid;
    taper = [for (i = [0:24]) let(u = i / 24, s = u * u * (3 - 2 * u))
             [xs + u * wf_taper, y_wf_out - s * (y_wf_out - y0)]];
    tip = [for (a = [180:-10:90]) [wf_tip_x + wf_tip_r + wf_tip_r * cos(a), y_wf_out - wf_tip_r + wf_tip_r * sin(a)]];
    translate([0, 0, wf_z[0]]) linear_extrude(wf_z[1] - wf_z[0])
        difference() {
            polygon(concat([[wf_tip_x, y0]], tip, taper));
            hull() {   // slot behind the leaf, round end at the root
                translate([wf_tip_x - 1, y0 - eps]) square([wf_root_x - r - wf_tip_x + 1, y_wf_in - y0 + eps]);
                translate([wf_root_x - r, y_wall_top + r]) circle(r = r, $fn = 32);
            }
        }
    // nub, 45° underside (−Z = bed side) so it prints without overhang
    h  = y_wf_in - y_wf_pad;
    z0 = wf_pad_c[1] - wf_pad[1] / 2;
    z1 = wf_pad_c[1] + wf_pad[1] / 2;
    translate([nub_x - wf_pad[0] / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(wf_pad[0])
        polygon([[y_wf_in + eps, z0 - h], [y_wf_pad, z0], [y_wf_pad, z1], [y_wf_in + eps, z1]]);
    // press-me ribs over the nub
    for (i = [0 : wf_rib_n - 1])
        translate([nub_x + (i - (wf_rib_n - 1) / 2) * wf_rib_pitch, y_wf_out - eps, wf_pad_c[1]])
            cuboid([wf_rib[0], wf_rib[1] + eps, wf_rib[2]], rounding = 0.3,
                   edges = [BACK + LEFT, BACK + RIGHT], anchor = FRONT);
}

// ---------- v2: ambidextrous stand ----------
module v2_leg() {
    stand_leg(y_leg_root);
    // fill under the leg root so the foot face runs flush onto the flange outer edge
    translate([leg_x[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(leg_x[1] - leg_x[0])
        polygon([[cav[1] - 0.1, z_flange - 0.3], [y_wall_top, z_flange - 0.3], [y_wall_top, z_flange],
                 [y_leg_root, z_back], [cav[1] - 0.1, z_back]]);
}

module v2_stand() {
    v2_leg();
    mirror_y() v2_leg();
    // bridge between the inner tip faces
    zt = z_back + leg_len * sin(leg_ang);
    yin = function(z) y_leg_root - leg_t - (z - z_back) / tan(leg_ang);   // inner face of the y=20.3-side leg
    z0 = zt - leg_bridge_t; pen = 0.3;
    translate([leg_x[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(leg_x[1] - leg_x[0])
        polygon([[cav[1] - yin(z0) - pen, z0], [yin(z0) + pen, z0], [yin(zt) + pen, zt], [cav[1] - yin(zt) - pen, zt]]);
}

// ---------- v2: pixel label on the y=20.3-side leg (mirror for the other) ----------
// frame on the leg's outer face: r = reading direction, u = "up" when this leg is the upper one, n = outward
module v2_label_cut() {
    a  = leg_ang;
    n  = [0, sin(a), cos(a)];
    u  = [0, cos(a), -sin(a)];               // toward the leg root (= the device's top wall in that pose)
    r  = [1, 0, 0];
    ro = [y_leg_root, z_back];
    mid = ro + leg_len / 2 * [-cos(a), sin(a)];
    c  = [(leg_x[0] + leg_x[1]) / 2, mid[0], mid[1]];
    multmatrix([[r[0], u[0], n[0], c[0]], [r[1], u[1], n[1], c[1]], [r[2], u[2], n[2], c[2]], [0, 0, 0, 1]])
        translate([0, 0, -label_depth]) linear_extrude(label_depth + 0.5) pixel_text(label_text, label_px);
}

// ---------- v2: in-wall flex button (top-wall frame; mirror_y() for the other wall) ----------
module v2_button_add(nub_x, notch_x) {
    h0 = notch_x[0] - wb_hood_lead;
    translate([h0, y_wb_hood, wb_hood_z[0]])
        cuboid([wb_neck_x[1] - h0, wb_hood_t, wb_hood_z[1] - wb_hood_z[0]], chamfer = wb_hood_ch,
               edges = [TOP + BACK], anchor = BOTTOM + LEFT + FRONT);
    translate([wb_neck_x[0], y_wall_top - eps, wb_tongue_z[0]])
        cube([wb_neck_x[1] - wb_neck_x[0], wb_gap + 2 * eps, wb_tongue_z[1] - wb_tongue_z[0]]);
    // nub, face flush with the wall opening, 45 deg underside
    h  = y_wb_hood - y_wf_pad;
    z0 = wf_pad_c[1] - wf_pad[1] / 2;
    z1 = wf_pad_c[1] + wf_pad[1] / 2;
    translate([nub_x - wf_pad[0] / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(wf_pad[0])
        polygon([[y_wb_hood + eps, z0 - h], [y_wf_pad, z0], [y_wf_pad, z1], [y_wb_hood + eps, z1]]);
}

module v2_button_cut() {
    r = wb_slit / 2;
    translate([0, y_wall_top + eps, 0]) rotate([90, 0, 0]) linear_extrude(wall + 2 * eps) {
        for (zz = [wb_top_z, wb_bot_z]) hull() {
            translate([wb_free_x[0], zz[0]]) square([wb_root_x - r - wb_free_x[0], zz[1] - zz[0]]);
            translate([wb_root_x - r, zz[0] + r]) circle(r = r, $fn = 24);
        }
        translate([wb_free_x[0], wb_bot_z[0]]) square([wb_free_x[1] - wb_free_x[0], wb_top_z[1] - wb_bot_z[0]]);
    }
}

// mirror children across the board's width (y = cav[1]/2): stand + flexure move to the y=0 (RESET-notch) wall
module mirror_y() { translate([0, cav[1] / 2, 0]) mirror([0, 1, 0]) translate([0, -cav[1] / 2, 0]) children(); }

// ---------- V3 key tower on top wall ----------
module key_tower_block() {
    translate([plunger_c[0] - tower3[0] / 2, y_wall_top - eps, tower3_z[0]])
        cuboid([tower3[0], tower3[1] + eps, tower3_z[1] - tower3_z[0]],
               rounding = tower3_r, edges = [TOP + LEFT, TOP + RIGHT],
               anchor = BOTTOM + LEFT + FRONT);
}

module key_tower_cuts() {
    translate([plunger_c[0], y_wall_top, bore_cz])
        cuboid([bore[0], tower3[1] + 1, bore[1]], anchor = FRONT);
    r = (pin_d + pin_clr) / 2;
    hull() for (y = [pin_slot_y[0] + r, pin_slot_y[1] - r])
        translate([plunger_c[0], y, bore_cz])
            rotate([0, 90, 0]) cyl(r = r, h = tower3[0] + 2, anchor = CENTER);
}

module shell(variant = variant) {
    rails = variant == "slide" || variant == "flex";
    flip  = variant == "wallflex_flip";   // USB-C on the left when standing, flex presses the y=0 wall switch
    v2    = variant == "v2";              // ambidextrous stand, in-wall buttons on both walls
    union() {
        difference() {
            union() {
                outer_block();
                if (v2) v2_stand();
                else if (flip) mirror_y() stand_leg();
                else stand_leg();
                if (rails) for (s = [-1, 1]) rail_tower_block(s);
                if (variant == "pin") key_tower_block();
                if (variant == "wallflex") wall_flexure();
                if (flip) mirror_y() wall_flexure(wf_pad_x_flip);
            }
            cavity();
            pocket();
            holes();
            recesses();
            usb_cut();
            notches();
            if (rails) for (s = [-1, 1]) rail_groove(s);
            if (variant == "pin") key_tower_cuts();
            if (v2) { v2_button_cut(); mirror_y() v2_button_cut(); }
            if (v2) { v2_label_cut(); mirror_y() translate([leg_x[0] + leg_x[1], 0, 0]) mirror([1, 0, 0]) v2_label_cut(); }
        }
        if (v2) {
            v2_button_add(wf_pad_c[0], boot_notch_x);
            mirror_y() v2_button_add(wf_pad_x_flip, reset_notch_x);
        }
    }
}

// print orientation: skirt edge on bed, back/stand up. Supports: cavity only.
module shell_print(variant = variant) {
    translate([0, 0, -z_front]) shell(variant);
}

if (print) shell_print(variant); else shell(variant);
