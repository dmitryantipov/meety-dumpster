// ESP32-C6-LCD-1.47 rear shell + stand + BOOT button cap — shared dimensions
//
// Frame = Onshape STEP frame. Origin at cavity corner.
//   X along board length, USB end at x=0
//   Y across board, y=0 bottom wall, y=20.3 top wall (stand side, BOOT side)
//   Z: -4.2 skirt front edge (screen side) ... +3.1 back face
// Standing: top wall up, LCD leans back ~26°, stand leg behind.
// Print: shell skirt-edge down (+Z up), supports in cavity only. Caps top-face down.

eps = 0.01;
$fn = 48;

// ============ shell: MATING geometry, from Onshape STEP — keep exact ============
cav      = [36.7, 20.3];  // cavity (skirt inner)
cav_r    = 2.0;           // cavity / slab corner radius
wall     = 0.8;           // skirt + flange thickness
z_front  = -4.2;          // skirt front edge
z_floor  = 0;             // cavity floor = standoff seats
z_flange = 1.8;           // outer ring top
z_back   = 3.1;           // back face
out_r    = 2.8;           // outer vertical-edge radius
y_wall_top = cav[1] + wall;   // 21.1  outer face of top wall

pocket_depth = 1.6;       // recess in floor, z 0..1.6 (clears TF slot; USB-C sits in relief)
// pocket outline: octagon through boss centres and boss edge points, minus boss discs
boss_r   = 2.0;
// boss_pts / pocket_poly: derived from the board holes below (v1 Onshape: x 2 / 34.7 = 32.7 spacing; board is 32.0)
hole_d   = 2.0;           // through floor into screw-head recess
recess_w = 4.0;           // screw-head recesses on back, z_flange..z_back
recess_r = 2.0;

usb_notch_y  = [5.65, 14.65];   // through left wall, z_front..z_floor
usb_relief_y = [6.45, 13.85];   // relief above floor for USB-C body: z 0..0.8, x -0.8..2
usb_relief_h = 0.8;
usb_relief_x = 2.0;
usb_relief_r = 0.8;             // top corners (arc centres on z=0 at usb_relief_y)

sw_c_x        = 7.04 + 0.155;   // stem centre in the case: Waveshare 7.04 from USB edge, board centred in its 0.31 play
boot_notch_x  = [sw_c_x - 1.4, sw_c_x + 1.4];   // top wall (y = cav[1] side); v1 was [5.0, 7.8]
reset_notch_x = [sw_c_x - 1.4, sw_c_x + 1.4];   // bottom wall (y = 0 side); v1 was [5.5, 8.3]
notch_z_top   = -0.7;           // notches run z_front..notch_z_top

// ============ stand (cosmetic, replicated) ============
leg_x      = [4.6, 32.5];   // clear of the screw-head recesses (v1: [4, 32.6])
leg_len    = 15;      // along the leg
leg_t      = 1.0;     // measured along Y at the root
leg_ang    = 60;      // from back face
leg_r      = 4;       // inner root fillet
leg_root_y = cav[1];  // outer face starts at slab edge

// ============ board (Waveshare STEP, in shell frame) ============
board_dx   = 0.155;   // PCB USB edge from x=0 (0..0.31 play) — centred
pcb        = [36.39, 20.34, 0.8];
pcb_r      = 1.5;
z_pcb_back = -2.5;    // standoffs (2.5) seated on z=0
standoff_d = 3.5;
standoff_h = 2.5;
holes_usb  = [[2.41, 10.15 - 8.16], [2.41, 10.15 + 8.16]];      // from PCB USB edge
holes_far  = [[34.41, 10.15 - 6.64], [34.41, 10.15 + 6.64]];
// screw bosses on the board holes (board centred in its 0.31 X play). Order: USB-end lo/hi, far-end lo/hi.
boss_pts = [for (p = concat(holes_usb, holes_far)) [p[0] + board_dx, p[1]]];   // (2.565,1.99) (2.565,18.31) (34.565,3.51) (34.565,16.79)
// USB-end edge stays at the USB relief (x 2.0) so the receptacle (0.75 above the floor) has a continuous pocket
pocket_poly = [[min(usb_relief_x, boss_pts[0][0]), boss_pts[0][1]], boss_pts[0] + [2, 0], boss_pts[2] - [2, 0], boss_pts[2],
               boss_pts[3], boss_pts[3] - [2, 0], boss_pts[1] + [2, 0], [min(usb_relief_x, boss_pts[1][0]), boss_pts[1][1]]];
lcd        = [36.28, 19.39, 4.3];   // LCM; 4.3 = pcb front to glass face
usb_c      = [7.53, 9.58, 3.25];    // stadium cross-section in YZ
usb_c_proud = 1.21;                 // beyond PCB edge
tf         = [5.5, 11.4, 2.6];
tf_pos     = [7.84, 4.11];
sw_body    = [4.55, 2.5, 2.2];      // X, depth from edge, Z
sw_x       = 7.04;                  // stem centre from USB edge
sw_z       = -1.6;                  // stem centre
stem       = [1.8, 1.2, 0.8];       // X width, protrusion beyond PCB edge, Z height
stem_proud = 0.42;  // stem tip beyond outer wall face (STEP, board centred). TUNE on print: V1/V3 self-adjust, V2 is sensitive.
y_stem_tip = y_wall_top + stem_proud;

// ============ button mechanics (shared) ============
sw_travel  = 0.25;
travel_max = 0.7;     // hard stop: cap body on wall. > sw_travel; overtravel goes into switch.
float_up   = 0.3;     // free lift above rest before up-stop (V1/V3)
clr_slide  = 0.15;    // sliding clearance per side, PETG-CF 0.4
plunger    = [2.3, 3.0];   // X × Z, inside notch 2.8 × 3.5 with 0.25/side
plunger_c  = [(boot_notch_x[0] + boot_notch_x[1]) / 2, (z_front + notch_z_top) / 2];  // [6.4, -2.45]

// ============ saddle cap (V1 slide, V2 flex) ============
tower_t   = 1.6;             // rail tower thickness beyond outer end wall
tower_y0  = 16.0;            // tower bottom; USB plug overmold must be < 2*(16-10.15)=11.7 wide
// Vertical (Y) groove in each tower's outer face, open at the top; undercut at the bottom catches the
// hook on the cap's rib. Cap pushes on from above: hooks ride the groove (bar flexes ~0.25 mm), snap into
// the undercut. Hook under the step = lift stop; bar on the wall = press stop.
groove_d   = 0.8;            // depth into tower outer face
groove_w   = 2.5;            // Z width
groove_zc  = -1.2;           // Z centre (within tower z -4.2..3.1 and cap z -6..1.8)
y_step     = 18.6;           // undercut top = catch face
undercut_d = 1.4;            // depth at the bottom of the groove
undercut_y0 = 16.5;          // undercut bottom (0.5 floor above tower_y0)
leg_t_cap  = 1.2;
leg_clr    = clr_slide;      // leg inner face to tower outer face
rib_d      = groove_d - 0.1 + leg_clr;   // from leg inner face; 0.1 short of groove floor
rib_w      = groove_w - 2 * clr_slide;   // 2.2
hook_extra = 0.5;            // past the rib → 0.4 snap interference in groove, 0.2 clearance in undercut
hook_h     = 0.8;
bar_t      = 1.6;
cap_z      = [-6.0, 1.8];    // 1.8 front lip over LCD top edge (LCD top ≈ y 19.9, bar ≥ 21.1)
hook_top_A = y_step - float_up;        // 18.3: A can lift 0.3 before the hook catches
cap_leg_y0 = hook_top_A - hook_h;      // 17.5 leg bottom at rest (A)
hook_top_B = y_step - 0.05;            // B locked: hook under step, bar on wall
cap_r     = 1.0;
dimple_d  = 4.0;
dimple_h  = 0.3;
// V2 flexure tongue
tongue_t   = 0.8;
tongue_z   = [-4.0, -0.5];
tongue_x   = [4.0, 18.0];    // tip .. root
slot_w     = 0.5;
v2_gap     = 0.1;            // bar underside above wall
v2_rest_gap = 0.1;           // plunger tip above stem at rest (fixed bar can't self-adjust)
shoulder   = [3.8, 3.5];     // stop pad around plunger, lands on wall

// ============ meety-case: flexure integrated in the wall (one-piece) ============
// R = USB-C right when standing (flex on the y=20.3 wall), L = mirrored (flex on the y=0 wall).
// v1.1: leaf is part of a full-height band that eases back into the wall with a tangent S-curve.
wf_t      = tongue_t;                    // 0.8 leaf thickness (Y)
wf_gap    = 0.7;                         // slot behind the leaf = tip stop (nub sees ~0.55 max)
wf_z      = [z_front, z_flange];         // 6.0: full outer wall height, top flush with the flange
wf_tip_x  = 4.0;                         // free end
wf_tip_r  = 0.6;                         // outer tip corner
y_wf_in   = y_wall_top + wf_gap;         // 21.8 leaf inner face
y_wf_out  = y_wf_in + wf_t;              // 22.6 band outer face
wf_pad    = [1.6, 1.2] * 2 / 3;          // X × Z nub (v2.4: 1/3 smaller than v1-v2.3 1.6 x 1.2), inside the stem face
wf_pad_c  = [sw_c_x, sw_z];              // centred on the stem face (z -2.0..-1.2); 0.5 to notch top
wf_pad_x_flip = (reset_notch_x[0] + reset_notch_x[1]) / 2;   // = sw_c_x
wf_pad_gap = 0.2;                        // v2.4: nub face backed off the wall opening (free travel before the stem)
y_wf_pad  = y_wall_top + wf_pad_gap;     // 21.3
// same stiffness at the nub as cap B's tongue (h 3.5, load arm 11.6): k ∝ h t³ / a³
wf_root_x = wf_pad_c[0] + (tongue_x[1] - plunger_c[0]) * pow((wf_z[1] - wf_z[0]) / (tongue_z[1] - tongue_z[0]), 1 / 3);  // ≈20.4
wf_root_solid = 1.0;                     // full-thickness band past the slot end
wf_taper  = 7.0;                         // S-curve back into the wall
// press-me ribs (vertical in print: formed by the perimeter path, survive printing)
wf_rib    = [0.8, 0.4, 3.0];             // width X, proud Y, height Z
wf_rib_n  = 3;
wf_rib_pitch = 1.6;

// ============ meety-case v2: ambidextrous stand + in-wall flex button on both long walls ============
// Rests on a leg's OUTER face (foot): back at leg_ang to the table -> screen 30 deg off vertical. Flip the part to
// swap the USB-C side; whichever wall is up has a working button. Foot plane passes through the flange outer edge.
foot_d     = y_wall_top * sin(leg_ang) + z_flange * cos(leg_ang);   // n=(0,sin,cos).p = foot_d  (19.17)
y_leg_root = (foot_d - z_back * cos(leg_ang)) / sin(leg_ang);       // 20.35 leg outer face meets the back
leg_bridge_t = 1.0;                      // plate joining the two leg tips (bridges in print)
// in-wall tongue (above the PCB, below the floor), freed by two slits; hood carries the nub back over the notch
wb_slit    = 0.5;
wb_top_z   = [-0.55, -0.05];             // top slit; flange ring above overhangs 0.8 from the floor
wb_tongue_z = [-2.3, -0.55];             // clear of the PCB back face (-2.5)
wb_bot_z   = [-2.8, -2.3];               // bottom slit; skirt strip below still holds the PCB edge
wb_free_x  = [9.7, 10.2];                // free-end slit; switch body ends at x 9.47 (sw_c_x + 2.275)
wb_root_x  = 19.2;                       // tongue root (round slit ends)
wb_neck_x  = [10.2, 11.0];               // hood <-> tongue
wb_gap     = 0.6 + wf_pad_gap;           // hood inner face off the fixed wall = hard stop; grows with wf_pad_gap so over-travel past the stem is unchanged
wb_hood_t  = 0.7;
wb_hood_z  = [z_front, -0.9];            // from the bed; top kept inside the foot plane
wb_hood_ch = 0.5;                        // top outer edge chamfer
wb_hood_lead = 0.8;                      // hood starts this far before the notch
y_wb_hood  = y_wall_top + wb_gap;        // 21.9 hood inner face

// "meety" debossed on both leg outer faces, each reading upright when that leg is the back (upper) one
label_text  = "meety";
label_px    = 0.9;                       // pixel; 24 px × 8 rows → 21.6 × 7.2 mm on a 27.9 × 15 face
label_depth = 0.3;                       // leg is 1.0 thick

// ============ V3 pinned keycap ============
tower3     = [7.2, 4.6];     // X width, height above wall
tower3_z   = [z_front, z_back];   // flush with skirt edge → prints skirt-down with no support
tower3_r   = 1.2;
bore       = [3.2, 4.0];     // X × Z guide
bore_cz    = z_front + wall + bore[1] / 2;   // -1.4: 0.8 front wall
pin_d      = 1.75;           // 1.75 mm filament
pin_clr    = 0.2;
pin_slot_y = [y_wall_top + 0.9, y_wall_top + 0.9 + pin_d + pin_clr + travel_max + float_up];  // [22.0, 24.85]
key_plate  = [7.2, 1.5];     // X, thickness; Z spans tower3_z
stem_up    = [2.9, 3.7];     // in bore, 0.15/side, centred on bore_cz
stem_lo    = [2.4, 1.6];     // enters notch, centred on sw_z (notch top -0.7 → max 1.8)
stem_lo_len = travel_max - stem_proud;   // shoulder lands on wall exactly at travel_max
y_shoulder = y_stem_tip + stem_lo_len;    // 21.8 at rest
y_tower3_top = y_wall_top + tower3[1];    // 25.7
y_plate0   = y_tower3_top + travel_max + 0.1;   // plate underside at rest; shoulder stops first
y_pin      = pin_slot_y[1] - float_up - (pin_d + pin_clr) / 2;   // pin centre at rest

// sanity
assert(y_wf_in > y_wf_pad, "wall flexure: pad must protrude from leaf");
assert(wb_free_x[0] > sw_c_x + sw_body[0] / 2, "free-end slit over the switch body");
assert(wf_root_x + wf_root_solid + wf_taper < cav[0] - 2, "band taper runs into the corner");
assert(wf_rib[2] / 2 + abs(wf_pad_c[1]) <= -wf_z[0] - 0.3, "ribs past leaf bottom");
assert(wf_pad_c[0] - wf_pad[0] / 2 >= boot_notch_x[0] + 0.5 && wf_pad_c[0] + wf_pad[0] / 2 <= boot_notch_x[1] - 0.5, "nub too close to notch sides");
assert(wf_pad_c[1] + wf_pad[1] / 2 <= notch_z_top - 0.5, "nub too close to notch top");
assert(wf_pad_x_flip - wf_pad[0] / 2 >= reset_notch_x[0] + 0.5 && wf_pad_x_flip + wf_pad[0] / 2 <= reset_notch_x[1] - 0.5, "E nub too close to notch sides");
assert(cap_leg_y0 - travel_max > undercut_y0 + 0.2, "hook bottoms in undercut before bar stops");
assert(undercut_y0 - tower_y0 >= 0.4, "undercut floor too thin");
assert(rib_d + hook_extra - leg_clr < undercut_d, "hook deeper than undercut");
assert(groove_zc - groove_w / 2 > z_front && groove_zc + groove_w / 2 < cap_z[1], "groove outside tower/cap");
assert(cap_leg_y0 - travel_max > usb_notch_y[1] + 1.5, "leg too close to USB plug");
assert(sw_z + stem_lo[1] / 2 < notch_z_top, "lower stem hits notch top edge");
assert(bore_cz - bore[1] / 2 >= z_front + wall - eps, "bore breaks front wall");
assert(pin_slot_y[1] + 0.6 <= y_tower3_top, "pin slot too close to tower top");
