// GetCigar basket 140 x 350 x 100 mm - revision v2
// Changes: structurally join sparse 30-mm floor grid to both long side walls,
// add an integrated 75 x 40 mm flat label panel on the FRONT short end.
// Original hexagonal walls, 30 mm floor grid, 6 x 8 center rib retained.
// All reinforcement is inside original outer envelope (0..140, 0..350, 0..100).
// Front is the short side at Y=0, with existing top-center finger notch.

width = 140;
length = 350;
height = 100;
rail_w = 11;        // floor-side joining band, spans 4-mm floor-to-wall gaps
rail_h = 4.5;       // continuous solid contact with build plate
end_rail_w = 8;     // transverse perimeter rails
label_w = 75;
label_h = 40;
label_z0 = 30;     // vertical center at 50 mm
label_depth = 3.6;  // inward from outer front face; no exterior protrusion

module side_gusset() {
    // 45-degree-ish triangular inner fillet, runs the entire long side.
    // Continuous bond between the solid bottom rail and side-wall base.
    translate([0, length, 0])
        rotate([90, 0, 0])
            linear_extrude(height=length)
                polygon(points=[[1.5, 3.8], [11, 3.8], [1.5, 12.0]]);
}

union() {
    import("../stl/L_gridfinity_30mm_center_rib/basket_140x350_grid_30mm_center_rib_6x8.stl", convexity=10);

    // Full-length side rails bridging floor-grid crossbar ends to side walls.
    cube([rail_w, length, rail_h]);
    translate([width-rail_w, 0, 0]) cube([rail_w, length, rail_h]);

    // Close the floor's peripheral frame at both short ends.
    cube([width, end_rail_w, rail_h]);
    translate([0, length-end_rail_w, 0]) cube([width, end_rail_w, rail_h]);

    // Triangular reinforcement for the inside wall-to-floor joint.
    side_gusset();
    translate([width, 0, 0]) mirror([1, 0, 0]) side_gusset();

    // Flat face for a 75 mm wide x 40 mm high adhesive label.
    // At y=0 outer surface remains flush with the original front wall.
    translate([(width-label_w)/2, 0, label_z0])
        cube([label_w, label_depth, label_h]);
}