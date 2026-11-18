// Waveshare ESP32-C6-LCD-1.47 mock-up in shell frame (fit checks only, never printed)
include <BOSL2/std.scad>
include <dimensions.scad>

module board() {
    x0 = board_dx;
    yc = cav[1] / 2;
    z_pcb_front = z_pcb_back - pcb[2];
    color("darkgreen") translate([x0, yc - pcb[1] / 2, z_pcb_front])
        cuboid(pcb, rounding = pcb_r, edges = "Z", anchor = BOTTOM + LEFT + FRONT);
    // LCM, glass face toward -z
    color("black") translate([x0 + (pcb[0] - lcd[0]) / 2, yc - lcd[1] / 2, z_pcb_front - lcd[2]])
        cuboid(lcd, rounding = 1.0, edges = "Z", anchor = BOTTOM + LEFT + FRONT);
    color("gray") translate([x0 + (pcb[0] - lcd[0]) / 2 + 1, yc - 8.7, z_pcb_front - lcd[2] - eps]) cube([32.35, 17.39, 0.05]);
    // USB-C on back: stadium section, mouth beyond USB edge
    color("silver") translate([x0 - usb_c_proud, yc, z_pcb_back + usb_c[2] / 2])
        rotate([0, 90, 0]) linear_extrude(usb_c[0])
            hull() for (s = [-1, 1]) translate([0, s * (usb_c[1] - usb_c[2]) / 2]) circle(d = usb_c[2]);
    // standoffs seated on z=0
    color("gold") for (p = concat(holes_usb, holes_far))
        translate([x0 + p[0], p[1], z_pcb_back]) cyl(d = standoff_d, h = standoff_h, anchor = BOTTOM, $fn = 6);
    // TF slot
    color("silver") translate([x0 + tf_pos[0], tf_pos[1], z_pcb_back]) cube(tf);
    // side switches: body inboard, stem out through wall
    for (s = [0, 1]) {
        ye = s == 0 ? yc - pcb[1] / 2 : yc + pcb[1] / 2;    // PCB edge
        dir = s == 0 ? -1 : 1;
        color("dimgray") translate([x0 + sw_x, ye - dir * sw_body[1] / 2, sw_z])
            cube([sw_body[0], sw_body[1], sw_body[2]], center = true);
        color("white") translate([x0 + sw_x, ye + dir * stem[1] / 2, sw_z])
            cube([stem[0], stem[1] + eps, stem[2]], center = true);
    }
}

board();
