// GetCigar modular box assembly preview: press F5 in OpenSCAD
// view_mode: 0 = basket fitted, 1 = basket pulled out by 100mm,
//            2 = 2 columns x 2 rows (module interlock preview)
view_mode = 1;
show_basket = true;
if (view_mode == 2) {
    for (col=[0:1],tier=[0:1]) {
        color([0.23,0.45+0.06*tier,0.70])
          translate([col*158,0,tier*115.5])
             import("modular_box_160x350x120.stl");
    }
} else {
    color([0.22,0.46,0.73]) import("modular_box_160x350x120.stl");
    if (show_basket)
        color([0.94,0.62,0.20])
            translate([9,view_mode==1 ? -100 : 0,7.5])
                import("basket_140x350_v2_reinforced_label_75x40.stl");
}