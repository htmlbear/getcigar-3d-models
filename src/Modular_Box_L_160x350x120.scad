// GetCigar humidor | Modular 18-box housing for reinforced L basket
// Based on the functional concept of supplied box_80.stl: stackable male/female joints
// and air-permeable side shell; dimensional redesign (NOT global STL stretching).
// mm, external bounding box including connectors: X 0..160, Y 0..350, Z 0..120
// Basket original outer size 140 x 350 x 100; its ~345 body + ~5 grip needs
// BOTH ends of the housing open (no solid rear wall).
// PRINT: x-y footprint on build plate, z vertical. No support intent, verify slicer.
// CAUTION: load-bearing stack = prototype, physical fit/load test before 18 prints.

$fn = 24;
outer_w = 160;
body_w = 158;        // 2mm reserved for right-side male lateral locator bosses
outer_d = 350;
outer_h = 120;
body_top = 115.5;   // upper peg tips reach exactly 120
basket_w = 140;
basket_d = 350;
basket_h = 100;
basket_x = 9;       // 1.5mm clearance at side runner datum x=7.5,150.5
basket_z = 7.5;     // floor-support height; basket top = 107.5
side_wall = 4;
side_datum_l = 7.5;
side_datum_r = 150.5;
post_w = 8;
bottom_rail_h = 7.5;
top_rail_z = 112;
vent_r = 18.0;       // side diamond half-diagonal

module box_side_wall() {
    difference() {
        // Both 4mm side webs (continuous along 350mm)
        union() {
            cube([side_wall, outer_d, body_top]);
            translate([body_w-side_wall,0,0]) cube([side_wall,outer_d,body_top]);
        }
        // Diamond-shaped self-supporting air vents, original perforated idea.
        for (yc = [42:54:312], zc = [40,85]) {
            translate([-0.3,yc,zc]) rotate([0,90,0])
                linear_extrude(height=side_wall+0.6)
                    polygon([[-vent_r,0],[0,vent_r],[vent_r,0],[0,-vent_r]]);
            translate([body_w-side_wall-0.3,yc,zc]) rotate([0,90,0])
                linear_extrude(height=side_wall+0.6)
                    polygon([[-vent_r,0],[0,vent_r],[vent_r,0],[0,-vent_r]]);
        }
    }
}

module inner_guide(z,h) {
    // Profile in XZ, extruded along the full Y depth.
    translate([0,outer_d,0]) rotate([90,0,0])
        linear_extrude(height=outer_d)
            polygon([[4,z],[7.5,z+3.5],[7.5,z+h-3.5],[4,z+h]]);
}

module structural_frame() {
    // Bottom sliding rails: support continuous contact lines under basket's
    // two long floor edges and the central reinforcement rib.
    cube([18,outer_d,bottom_rail_h]);
    translate([body_w-18,0,0]) cube([18,outer_d,bottom_rail_h]);
    translate([74,0,0]) cube([10,outer_d,bottom_rail_h]);

    // Bottom square-up cross rails are BELOW the floor-support level.
    for (y=[0,171.5,341]) translate([0,y,0]) cube([body_w,9,5]);

    // Top horizontal load frame: remains above the basket top z=107.5.
    translate([0,0,top_rail_z]) cube([10,outer_d,body_top-top_rail_z]);
    translate([body_w-10,0,top_rail_z]) cube([10,outer_d,body_top-top_rail_z]);
    // NO transverse bars at the TOP: bridging 140mm would require supports.
    // Top frame stays as two long load-bearing side beams.

    // Four corners + five intermediate 8mm-wide stiffeners along length.
    for (y=[0,65,125,185,245,305,342]) {
        translate([0,y,0]) cube([post_w,8,body_top]);
        translate([body_w-post_w,y,0]) cube([post_w,8,body_top]);
    }

    // 143mm guide datum at x=7.5/150.5, only in low wall height bands.
    // Narrow strips avoid rubbing the entire 100mm tall basket side.
    // Tapered 45-degree ramps avoid >3mm horizontal unsupported shelves.
    for (z=[15,91]) {
        inner_guide(z,10);
        translate([body_w,0,0]) mirror([1,0,0]) inner_guide(z,10);
    }

    // Thickened blocks around lateral locators so vent cuts cannot weaken them.
    for (yc=[82,176,270],zc=[36,92]) {
        translate([0,yc-8,zc-10]) cube([8,16,20]);
        translate([body_w-8,yc-8,zc-10]) cube([8,16,20]);
    }
}

module top_peg(x,y) {
    // Self-supporting tapered plug: 6.0 base -> 4.8 tip, h 4.5mm
    hull() {
        translate([x-3,y-3,body_top-0.05]) cube([6,6,0.15]);
        translate([x-2.4,y-2.4,outer_h-0.15]) cube([4.8,4.8,0.15]);
    }
}

module lateral_peg(y,z) {
    // Right side: projects to x=160, with matching blind socket on x=0.
    // Two trapezoidal segments reduce sharp unsupported horizontal ledges.
    hull() {
        translate([body_w-0.6,y-4,z-6]) cube([0.6,8,12]);
        translate([body_w+1.6,y-3.4,z-3.5]) cube([0.4,6.8,7]);
    }
}

module main_body() {
    union() {
        box_side_wall();
        structural_frame();
        // Male pegs on upper rim, female sockets in underside, four locations.
        for(x=[6,body_w-6],y=[7,outer_d-7]) top_peg(x,y);
        // Side-by-side locating features, male right / female left.
        for(y=[82,176,270],z=[36,92]) lateral_peg(y,z);
    }
}

difference() {
    main_body();
    // 0.55mm XY clearance per side around nominal 6mm peg; 4.9mm depth.
    for(x=[6,body_w-6],y=[7,outer_d-7])
        translate([x-3.55,y-3.55,-0.05]) cube([7.1,7.1,5.05]);
    // Matching sockets for horizontal male locators.
    // Adjacent boxes mate at pitch 158mm, assembled row width 476mm.
    for(y=[82,176,270],z=[36,92])
        translate([-0.1,y-4.5,z-6.7]) cube([2.9,9,13.4]);
}