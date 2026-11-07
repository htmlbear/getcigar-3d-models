// GetCigar Box 80 v3, directly modified from user's ORIGINAL box_80.stl.
// 160 x 350 x 120 mm INCLUDING the 4 mm vertical interlocking pins.
// 350 mm limit includes ALL parts; do not add a solid back wall, the basket
// and its 5 mm front handle together already occupy 350 mm.
// Original hexagonal LONG side walls and top/bottom mating profiles preserved.
// Only stack vertically, no inter-box lateral connectors.
// Print upright on the short (160 x 120 mm) end, with depth 350 vertical.
$fn=32;
outer_width=160;
outer_length=350;
body_height=116;
stack_pin_height=4;
clear_aperture_width=144; // x 8 .. 152; basket 140 wide
clear_aperture_height=104; // z 6 .. 110; basket 100 high
bottom_slab_z=2;
bottom_slab_thickness=4;
top_slab_z=110;
top_slab_thickness=4;
front_back_cut_depth=9;
peg_diameter=8;
peg_clearance_diameter=8.6;
peg_socket_depth=4.3;

module existing_side_wall_mesh() {
    import("box_80_original_transform_for_v3.stl",convexity=10);
}
module modified_original_with_open_ends() {
    difference(){
        existing_side_wall_mesh();
        // Existing solid short face at y=0 opens to receive the existing basket.
        translate([8,-1,6]) cube([144,front_back_cut_depth+1,104]);
        // Rear exit keeps the original structural outer perimeter frame.
        // Necessary: 350mm basket cannot fit behind a 4mm solid back wall
        // when the cabinet depth limit is itself exactly 350mm.
        translate([8,outer_length-front_back_cut_depth,6])
            cube([144,front_back_cut_depth+1,104]);
    }
}
module male_stack_pins(){
    // These are the only ADDED connectors: matching top studs and bottom seats.
    for(x=[22,outer_width-22], y=[22,outer_length-22])
        translate([x,y,top_slab_z+top_slab_thickness-0.5])
            cylinder(d=peg_diameter,h=body_height+stack_pin_height-(top_slab_z+top_slab_thickness-0.5));
}
module bottom_pin_sockets(){
    for(x=[22,outer_width-22], y=[22,outer_length-22])
        translate([x,y,-0.1])
            cylinder(d=peg_clearance_diameter,h=peg_socket_depth+0.1);
}

difference(){
    union(){
        modified_original_with_open_ends();
        // Solid load-bearing roof and floor missing in prior version.
        // They become VERTICAL panels in printing orientation (no wide roofs).
        translate([0,0,bottom_slab_z])
            cube([outer_width,outer_length,bottom_slab_thickness]);
        translate([0,0,top_slab_z])
            cube([outer_width,outer_length,top_slab_thickness]);
        male_stack_pins();
    }
    bottom_pin_sockets();
}