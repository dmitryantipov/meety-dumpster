# meety-dumpster

A 3D-printed 8-bit dumpster fire for the **Waveshare ESP32-C6-LCD-1.47** dev board. The screen sits flush in the
dumpster's front wall, and the pixel flame on top is the board's button. The flame is lit from inside by the board's
own RGB LED (LED1).

- Body 45 × 20 × 30 mm on a 2.5 mm voxel grid.
- Snap-hinged lids that hold any angle.
- Pixel wheels and pixel trash bags.
- Everything is a press fit. The only glue is a drop of CA for each wheel.

Written in OpenSCAD with BOSL2. Ready-to-print STLs for v1 are in [`stl/`](stl/).

## Two builds

The board has a side switch on each long edge, and the build decides which one the flame presses.
`side` in `dumpster.scad` picks the build:

- **R:** USB-C out of the right wall. The flame presses **BOOT**.
- **L:** USB-C out of the left wall. The board is turned 180° in the screen plane, so the flame presses the **other**
  switch, which should be RESET. See [L and the RESET switch](#l-and-the-reset-switch).

L mirrors the body, deck, cartridge and flame. The lids and wheels are shared.

## Files

| file | what |
|---|---|
| `dumpster.scad` | the design: body, lids, deck, flame, wheels, assembled view and print layout (`side=`, `part=`, `print=`) |
| `core.scad` | the internals any enclosure for this board can reuse: cartridge, bezel window, frame stop, spring fingers, deck flexure, light pipe |
| `common.scad` | board placement, the measured glass outline, flame and trash helpers |
| `meety-case/` | board dimensions and the cartridge shell, from the board's one-piece case project |
| `print.sh [tag]` | exports every part in print orientation to `stl/` |
| `stl/` | v1 print-ready STLs |

Frame: X across the front (viewer's right is +), Y depth (front face at y = 0), Z up from the table.

## Building

You need OpenSCAD (tested with 2021.01) and [BOSL2](https://github.com/BelfrySCAD/BOSL2) in your OpenSCAD library
folder (tested with v2.0.779).

```bash
bash print.sh            # all parts → stl/
bash print.sh mytag      # also writes _mytag copies
```

Single part:

```bash
openscad -o body.stl -D print=true -D 'side="L"' -D 'part="body"' dumpster.scad
```

Opening `dumpster.scad` in the GUI shows the assembled dumpster.

## Parts

| STL | qty | material | layer | notes |
|---|---|---|---|---|
| `R-body` or `L-body` | 1 | PETG, your colour | 0.15 | Upright, no supports. 3 perimeters, 20 % gyroid. If the window's top edge strands, add a support enforcer under that edge only. |
| `lid` | 2 | black / gray PETG | 0.15 | Flat as exported. The pocket on the bed bridges once. |
| `wheel` | 4 | black / gray PETG | 0.15 | Outer face down. |
| `R-deck` or `L-deck` | 1 | black / gray PETG | 0.15 | Flat, bags up, standing on the plunger tip as exported. Use snug supports from the build plate under the whole plate. Peel the support mat off from the plate side, not by bending the leaf springs. |
| `R-cartridge` or `L-cartridge` | 1 | PETG-CF (or black PETG) | 0.10 | Skirt edge down. Supports from the build plate only (cavity and the stem notch). 3 perimeters, 40 % gyroid. |
| `R-flame` or `L-flame` | 1 | white PETG-GF (hardened nozzle) or clear PETG | 0.15 | Front face down as exported. Organic supports from the build plate only (under the stem and block front), no brim. The model is solid, so the look comes from your slicer settings. Two perimeters with 0 % infill prints a glowing shell; add infill for a denser look. |

On a Prusa Core One with a 0.4 nozzle, the body takes about 2.5 h. The lid, deck and flame take 12–17 min each.

**PLA fit test:** the same settings work in PLA.

**Hardware:** the board's 4 screws into the cartridge, and CA glue for the wheel pegs.

## Assembly

Everything goes in through the open top.

1. **Board:** screw the board into the cartridge.
2. **Cartridge:** press it **straight down** into the body, screen forward and USB-C toward the port.
   - It slides between the USB-side wall and a spring finger in the far wall, in front of three spring fingers at the
     back. The back fingers push it forward onto the frame under the glass, and the glass ends up 0.45 mm behind the
     bezel.
   - To remove it: take the deck off, push up through the two holes in the floor with a pen or hex key, and pull it out.
3. **Button, on the bench:** push the flame's stem down into the ribbed U in the deck until the block round it sits on
   the deck. No glue; the crush ribs hold it.
4. **Button in:** tilt it, hook the beveled anchor edge under the lip on the side wall (behind the cartridge), then
   lower the other side.
   - The stem drops into the cartridge's light notch, and the plunger tip lands 0.4 mm above the switch.
   - The front of the anchor bar sits on the pad on the cartridge top.
5. **Wheels:** put a drop of CA in each wheel pocket and press the wheel's square peg in.
6. **Lids:** hold a lid upright and press its barrel straight down between its two hinge fins. The fins spread and the
   cone bumps click into the dimples.
   - The lid then holds any angle: resting on the flame at 20° (the flame's key goes into the lid's pocket), upright,
     or flipped back to about 215°.
   - To remove a lid: spread one fin outward with a fingernail and lift.

## How the button works

The deck is a rigid plate on two 0.6 mm leaf springs that hang from an anchor bar. The flame and the deck, with the
plunger under it, move together as one button.

Pressing the flame tilts the deck, and the plunger presses the switch. After 0.6 mm at the switch, the plunger head
lands on the cartridge wall, which is a hard stop. Nothing else touches through the stroke.

## Light

LED1 sits under the LCD at the board centre and lights the board's acrylic light-guide frame. The flame's stem ends
0.6 mm above the frame's top edge, so the light runs up the stem into the flame. White PETG-GF diffuses it.

It's the onboard LED, so expect a glow you'll notice in a dim room, not in daylight.

**Brighter option:** the board has two rows of 2.54 mm header pads. A small RGB LED (e.g. WS2812B-2020) wired to 5V,
GND and a free GPIO could light the flame from inside. The cartridge top wall has a 3 mm hole next to the header row
for the wires, but the deck and flame would need a tweak.

## L and the RESET switch

In the L build the flame presses the switch on the other edge, which should be RESET. Options:

1. **Firmware:** treat every reset as a press. Keep state in RTC memory or NVS and advance the animation on each boot.
   A ~0.5 s reboot per press suits "restart the fire".
2. **Use R instead,** with a right-angle USB-C cable.

If your board's switches turn out to be the other way round, swap which build you call R.

## Tuning knobs

Edit these at the top of the `.scad` files.

| area | knobs |
|---|---|
| Cartridge fit (`core.scad`) | `fit_x`: cartridge to side walls (0.05). Loose → 0, tight → 0.1. |
| Back spring fingers | `rail_pre`: bump preload (0.3). `rail_t`: thickness (1.8; stiffness ∝ t³). `rail_rf` / `rail_rb`: root fillets. `rail_stop` / `rail_side`: cage clearance = max flex. |
| Side spring finger | `side_t`, `side_stop`, `side_y` |
| Window | `win_m`: window edge outside the active pixels (0.5). `view_a`: bevel angle (45°). `lip_t`: straight land before the bevel (0.4). `scr_gap`: glass pocket. `y_face`: bezel depth. |
| Other cutouts | `usb_head`: USB-C plug head opening (≈10.6 × 5.1). `push_d`: push-out holes. `flex_rel` / `flex_rz`: display flex relief. |
| Button | `pl_rest` / `pl_travel`: plunger tip over the wall at rest (0.4) / travel to the stop (0.6). `leaf`: leaf-spring stiffness. `pipe_gap`: stem to light guide (0.6). |
| Press fits | `pf` / `pf_clr`: crush-rib interference / clearance (0.15 / 0.1). Tight → 0.1, loose → 0.2. |
| Flame | `lid_rest`: lid angle on the flame (20°). `fl_bm`: the pixel bitmap. `fl_gap`: height over the rim. `fl_lc` / `fl_lx`: tip clearance to the lid edges and handles. `fl_bx`: block half-width. `fire = false` builds a button with no flame so the lids close. |
| Hinge | `bump_ov`: barrel ends pressed into the fins = holding friction (0.25). ±0.05 if too stiff or too loose; keep it under the 0.8 slot room. `lb_r` / `lb_h`: lid bumps. `kn_ch`: barrel chamfer. `fin_root`: fin free length. |
| Lid ↔ flame key | `cp_w` / `cp_h`: key width / height. `cp_u`: key position along the lid. `cp_cx` / `cp_cu` / `cp_cz`: pocket clearance. |

Everything that mates with the board comes from `meety-case/dimensions.scad`.

## History

v1 (2026-11) is the first frozen release, after 21 test iterations. Some of what those tests taught:

- **Back rails:** rigid back rails made seating the cartridge a fight. They became spring fingers, which snapped across
  their layer lines, so each finger now stands in a cage that limits how far it can bend.
- **Hinge:** filament-pin hinges cracked their knuckles. They became snap fins with cone bumps.
- **Window:** a knife-edge window bevel strands on supports, so the edge now has a 0.4 mm flat land.
- **Plunger:** a separate press-fit plunger was folded into the deck.
- **Flame:** the hollow flame with modelled one-line walls became a solid model, so the slicer sets the look.

## License

[CC BY-NC-SA 4.0](LICENSE): you may share and remix this design with credit, non-commercially, under the same license.
