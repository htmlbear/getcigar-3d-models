// GetCigar Box 80 v9 Light
// BASE: EXACT physical Box v8 STL. Subtractive modification only.
// Preserve all external bounds, wall mating interfaces, original honeycomb,
// basket opening and the upper/lower stacking geometry.
//
// Axes in print-on-end orientation: X=150 mm, Y=120 mm, Z=350 mm.
// OpenSCAD path is resolved relative to this source file.
//
// Additional hexagonal ventilation cutouts plus recessed inner sidewall skins:
// two near the Z=350 end (in the previously solid outer rows), and
// one near Z=0 (in the previously solid center row), PER SIDE.
// Leave at least 5 mm around the end faces and avoid Y<16.9/Y>103.1
// mating belts and original strengthened roof/floor transitions.
//
// NO external scaling and NO additive features.

source_stl = "../../stl/box80_v8_honeycomb_sidewalls_PRINT_ON_END_150x120x350.stl";

side_row_y = [29.442, 60, 90.558];

// Sizes of the *additional* truncated hexagonal through-holes.
// The existing 30 honeycomb openings from v8 are never touched.
cap_half_height = 12.545;
cap_half_length = 15.0;
cap_half_flat   = 8.3;

start_half_height = 12.545;
start_half_length = 14.5;
start_half_flat   = 8.2;

module cut_hex(x_start, width, y_center, z_center, hh, hl, hf) {
    translate([x_start, y_center, z_center])
        rotate([0, 90, 0])
            linear_extrude(height=width, convexity=10)
                polygon(points=[
                    [-hl, 0],
                    [-hf,-hh],
                    [ hf,-hh],
                    [ hl, 0],
                    [ hf, hh],
                    [-hf, hh]
                ]);
}

module extra_sidewall_cells(x_start) {
    // Solid area pointed out in reference screenshot, near the far end.
    // Upper/lower Y rows have last original opening at Z≈307.9.
    // New cuts occupy Z=315..345; 5 mm end frame stays untouched.
    cut_hex(x_start, 5.5, side_row_y[0], 330, cap_half_height, cap_half_length, cap_half_flat);
    cut_hex(x_start, 5.5, side_row_y[2], 330, cap_half_height, cap_half_length, cap_half_flat);

    // Center row at the near end: Z=9.5..38.5.
    // Original first center-row cell starts near Z≈42.8.
    cut_hex(x_start, 5.5, side_row_y[1], 24, start_half_height, start_half_length, start_half_flat);
}

// Both cutters are confined to the external X-shell walls (nominal 4 mm).
// They never reach X=5..145, preserving basket passage and reinforcement.
// Recess ONLY the INNER faces of the free perforated sidewall panels.
// The OUTER mating surface stays at X=0/150, with 2.1-mm PETG skin.
// The entire end frame (Z<12 and Z>338), top/bottom joining belts
// (Y<17 and Y>103) and all original X>5 / X<145 ribs stay at full depth.
// No added matter and no interference with the original v8 profile.
remaining_panel_wall = 2.1;
module inner_relief_pockets() {
    // Left outer face at X=0: keep X=0..2.1.
    translate([remaining_panel_wall, 17, 12])
        cube([5 - remaining_panel_wall, 86, 326], center=false);
    // Right outer face at X=150: keep X=147.9..150.
    translate([145, 17, 12])
        cube([5 - remaining_panel_wall, 86, 326], center=false);
}

difference() {
    import(source_stl, convexity=15);
    extra_sidewall_cells(-0.5);
    extra_sidewall_cells(145.0);
    inner_relief_pockets();
}
