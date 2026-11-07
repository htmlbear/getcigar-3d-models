// Requires source-faithful final STL and existing revised basket STL
color([0.14,0.40,0.69],0.55) import("../stl/box_80_resized_for_basket_160x350x120.stl");
drawer_in_out=-65;
color([0.89,0.53,0.21]) translate([10,drawer_in_out,8.6]) import("../stl/L_gridfinity_30mm_center_rib/basket_140x350_v2_reinforced_label_75x40.stl");
