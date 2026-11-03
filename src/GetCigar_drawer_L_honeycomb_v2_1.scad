// GetCigar L Honeycomb Drawer v2.1 - original, parametric OpenSCAD geometry.
// Reference: staggered hexagonal side walls and a grid bottom, not a copy of the uploaded STL.
// All dimensions in mm. F5=preview, F6=render, F7=export STL.
// Design target: 120 x 350 x 100 mm free internal space.
// CAUTION: an internal depth of 350 mm needs >350 mm cabinet depth when adding walls.
// Still a prototype: no runner, guide, mounting hardware or anti-tip stops included.

$fn = 24;

// [Main parameters]
drawer_size = "L";
inside_w = 120;
inside_d = 350;
inside_h = 100;
wall_thickness = 2.4;
bottom_thickness = 3.0;

// [Staggered sidewall hexagons]
hex_width = 17;           // width of an opening along the wall
hex_height = 26;          // height of opening
hex_pitch = 20.0;         // center-to-center spacing within a row
hex_row_pitch = 20.5;     // vertical center-to-center spacing
hex_stagger = hex_pitch/2; // alternate rows shift half a step
hex_roof_fraction = 0.35; // upper/lower sloped corners; >0.30 for PETG self-support
hex_first_z = 20.5;
hex_rows = 4;
hex_end_margin = 13;    // keep front and back walls connected

// [Denser square grid bottom]
floor_pitch = 17.2;
floor_opening = 14.2;
floor_min_margin_x = 11;  // solid strips for later runner mounting
floor_min_margin_y = 9;

// [Flat face and top finger recess]
label_width = 120;
label_height = 75;
// The label fits on a continuous 120 x 75 mm area below the finger recess.
// The finger recess is centered and open from the top edge of the front.
finger_notch_width = 44;
finger_notch_depth = 17;
finger_notch_radius = 6; // rounded inside bottom corners
label_bottom_z = 5;     // label occupies z=5..80; notch begins at z=86

W = inside_w + 2*wall_thickness;
D = inside_d + 2*wall_thickness;
H = inside_h + bottom_thickness;

floor_nx = floor((W - 2*floor_min_margin_x - floor_opening)/floor_pitch) + 1;
floor_ny = floor((D - 2*floor_min_margin_y - floor_opening)/floor_pitch) + 1;
floor_margin_x = (W - ((floor_nx-1)*floor_pitch + floor_opening))/2;
floor_margin_y = (D - ((floor_ny-1)*floor_pitch + floor_opening))/2;

// Vertical-pointed honeycomb openings: neighboring rows are STAGGERED.
// Upper slopes are at >45 degrees with default parameters for support-free printing.
module hex_hole_2d(w, h) {
    s=hex_roof_fraction;
    polygon([
        [0,-h/2],
        [w/2,-h/2+s*h],
        [w/2,h/2-s*h],
        [0,h/2],
        [-w/2,h/2-s*h],
        [-w/2,-h/2+s*h]
    ]);
}

module cut_side(xpos, y, z) {
    // Rotate polygon plane so its x axis follows drawer depth and y axis is vertical.
    translate([xpos,y,z]) rotate([90,0,90])
        linear_extrude(height=wall_thickness+1.2)
            hex_hole_2d(hex_width,hex_height);
}

module cut_back(x,z) {
    translate([x,D+0.6,z]) rotate([90,0,0])
        linear_extrude(height=wall_thickness+1.2)
            hex_hole_2d(hex_width,hex_height);
}

// Cut a centered U-shaped finger recess through the front wall.
// Open top and rounded bottom corners; no unsupported horizontal ceiling.
module front_finger_recess() {
    x0 = (W-finger_notch_width)/2;
    r = finger_notch_radius;
    y0 = -0.6;
    cut_y = wall_thickness+1.2;
    bottom_z = H-finger_notch_depth;
    union() {
        // Top open region
        translate([x0,y0,bottom_z+r])
            cube([finger_notch_width,cut_y,finger_notch_depth-r+1]);
        // Straight bottom between the rounded corners
        translate([x0+r,y0,bottom_z])
            cube([finger_notch_width-2*r,cut_y,finger_notch_depth+1]);
        // Rounded left and right bottom corners
        for (x=[x0+r,x0+finger_notch_width-r])
            translate([x,y0,bottom_z+r])
                rotate([-90,0,0]) cylinder(h=cut_y,r=r,$fn=40);
    }
}

module drawer_L() {
    difference() {
        // Solid shell first; no separate, easily broken corner posts.
        difference() {
            cube([W,D,H]);
            translate([wall_thickness,wall_thickness,bottom_thickness])
                cube([inside_w,inside_d,inside_h+0.5]);
        }

        // Smaller and more numerous open squares: floor is a continuous printed lattice.
        for (ix=[0:floor_nx-1], iy=[0:floor_ny-1])
            translate([floor_margin_x+ix*floor_pitch,
                       floor_margin_y+iy*floor_pitch,-0.5])
                cube([floor_opening,floor_opening,bottom_thickness+1]);

        // Two long walls. Each row staggered by half a pitch.
        for (row=[0:hex_rows-1])
            for (n=[0:ceil(D/hex_pitch)]) {
                zz=hex_first_z+row*hex_row_pitch;
                yy=hex_end_margin+hex_width/2+n*hex_pitch
                    + (row%2)*hex_stagger;
                if (yy+hex_width/2 <= D-hex_end_margin &&
                    zz+hex_height/2 <= H-6 && zz-hex_height/2 >= 6) {
                    cut_side(-0.6, yy, zz);
                    cut_side(W-wall_thickness-0.6, yy, zz);
                }
            }

        // Finger access: only the top 17 mm of the center front wall.
        // A 120 x 75 mm flat label zone remains intact underneath.
        front_finger_recess();

        // Rear wall ventilated with the same offset hexagon lattice.
        // Front remains solid below the notch for the label.
        for (row=[0:hex_rows-1])
            for (n=[0:ceil(W/hex_pitch)]) {
                zz=hex_first_z+row*hex_row_pitch;
                xx=10+hex_width/2+n*hex_pitch
                   +(row%2)*hex_stagger;
                if (xx+hex_width/2 < W-9 &&
                    zz+hex_height/2 <= H-6 && zz-hex_height/2 >= 6)
                    cut_back(xx,zz);
            }
    }
}

// Parts may be extended later; do not add supports at the floor by default.
drawer_L();
