// GetCigar Basket 140x350 v3 — smooth finger scoop on the front upper rim.
// Base is the exact finalized v2 STL; ONLY material removal.
// Print-ready result is obtained through the OpenSCAD difference below.
//
// Reference:
// Original STL v2: stl/L_gridfinity_30mm_center_rib/
//                  basket_140x350_v2_reinforced_label_75x40.stl
// Frame outside envelope unchanged: X 0..140, Y 0..350, Z 0..100 mm.
// FRONT = Y 0 short wall, label is X 32.5..107.5, Z 30..70.
// KEEP the flat 75x40 mm label area completely unchanged.
//
// Shape of a generous, smooth U-scoop on the front top edge.
// Endpoints at X=10/130, Z=100. Deepest section X=55..85, Z=78.
// The scoop leaves 8 mm between its bottom and the label's top edge.
// 4 mm clearance to the original front sidewall fillets maintained by
// applying the subtraction only to Y -1..9 mm and X 10..130.
// This is a pilot version for physical slicing and load tests.

source_stl = "../../stl/L_gridfinity_30mm_center_rib/basket_140x350_v2_reinforced_label_75x40.stl";

basket_width = 140;
basket_length = 350;
basket_height = 100;
label_top = 70;

notch_left = 10;
notch_right = 130;
notch_bottom = 78;
notch_flat_left = 55;
notch_flat_right = 85;
cut_front_depth = 10;  // Y -1 through +9, only across short front panel
curve_steps = 32;      // smooth contours (faceted at ~1.4-mm spacing)

// Cubic smoothstep (zero derivative at each end), to avoid sharp inner corners.
function smoothstep(t) = t*t*(3-2*t);

function notch_z(x) =
    x <= notch_flat_left ?
      basket_height - (basket_height-notch_bottom)*
      smoothstep((x-notch_left)/(notch_flat_left-notch_left))
    : x < notch_flat_right ? notch_bottom
    : notch_bottom + (basket_height-notch_bottom)*
      smoothstep((x-notch_flat_right)/(notch_right-notch_flat_right));

module front_finger_notch() {
    // At Y=9, rotate the XY sketch into XZ. Extrusion heads toward -Y,
    // cutting the front web but never reaching the deeper basket interior.
    translate([0,9,0])
        rotate([90,0,0])
            linear_extrude(height=cut_front_depth, convexity=10)
                polygon(points=concat(
                    [[notch_left,basket_height+2]],
                    [for (k=[0:curve_steps])
                        let(x=notch_left+(notch_flat_left-notch_left)*k/curve_steps)
                        [x,notch_z(x)]],
                    [for (k=[1:curve_steps])
                        let(x=notch_flat_left+(notch_flat_right-notch_flat_left)*k/curve_steps)
                        [x,notch_z(x)]],
                    [for (k=[1:curve_steps])
                        let(x=notch_flat_right+(notch_right-notch_flat_right)*k/curve_steps)
                        [x,notch_z(x)]],
                    [[notch_right,basket_height+2]]
                ));
}

difference() {
    import(source_stl, convexity=15);
    front_finger_notch();
}
