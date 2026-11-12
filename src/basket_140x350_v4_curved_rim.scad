// GetCigar Basket v4: CLOSED, CONTINUOUS CURVED FRONT FINGER RIM.
// Fixes v3: an open U-notch cut left exposed ends of honeycomb strands.
// The new 5.4-mm tall, 9.2-mm deep curved belt JOINS the cell ends,
// becoming a solid, smooth protective upper edge.
// Exact base: original v3 STL; do not replace, rescale, or remodel.
//
// Coordinates: basket X=0..140, Y=0..350, Z=0..100 (millimeters).
// Front short wall: Y=0.  Label region X=32.5..107.5, Z=30..70.
// Smooth U notch from X=10..130, deepest Z=78, unchanged nominally.
// Band remains ABOVE Z=72.6, clear of label at Z<=70.
// All additions stay strictly WITHIN the ORIGINAL external envelope.
//
// Test in Elegoo Slicer for visible connected rim, no stranded honeycomb
// ends; then test-printed PETG strength before handling loaded baskets.

base_stl = "../stl/L_gridfinity_30mm_center_rib/basket_140x350_v3_finger_scoop.stl";
basket_w = 140;
basket_h = 100;
notch_left = 10;
notch_right = 130;
notch_flat_l = 55;
notch_flat_r = 85;
notch_low_z = 78;

// Nominal depth of existing cut: Y = -1..9 mm.
// This positive belt reaches the existing cut and enough of the solid web
// below the notch to create a real manifold union (NOT face contact).
rim_depth_y = 9.2;
rim_height_z = 5.4;
rim_top_overlap = 0.3;
curve_segments = 140;

function smoothstep(t) = t*t*(3-2*t);

function notch_z(x) =
    (x <= notch_left || x >= notch_right) ? basket_h :
    x < notch_flat_l ? basket_h - (basket_h-notch_low_z)*smoothstep((x-notch_left)/(notch_flat_l-notch_left)) :
    x <= notch_flat_r ? notch_low_z :
      notch_low_z + (basket_h-notch_low_z)*smoothstep((x-notch_flat_r)/(notch_right-notch_flat_r));

function rim_lower_z(x) = notch_z(x) - rim_height_z;
function rim_upper_z(x) = min(basket_h, notch_z(x) + rim_top_overlap);

// This creates a solid ribbon following the notch, including short horizontal
// extensions to both corner rails (X=0..10, X=130..140). That guarantees
// load transfer into the original outer corners, not just the honeycomb tips.
// We keep the ends and bottom strictly inside original outer bounds.
module curved_front_rim() {
    translate([0, rim_depth_y, 0])
        rotate([90,0,0])
            linear_extrude(height=rim_depth_y, convexity=20)
                polygon(points=concat(
                    [for (i=[0:curve_segments])
                        let(x=basket_w*i/curve_segments)
                        [x, rim_lower_z(x)]],
                    [for (i=[curve_segments:-1:0])
                        let(x=basket_w*i/curve_segments)
                        [x, rim_upper_z(x)]]
                ));
}

// OpenSCAD's CSG union fuses the rim into the original v3 body, so that
// honeycomb strut tips terminate within the solid continuous rim.
union() {
    import(base_stl, convexity=15);
    curved_front_rim();
}
