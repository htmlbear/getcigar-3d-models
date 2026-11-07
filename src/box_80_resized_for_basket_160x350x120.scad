// Source-faithful adaptation of supplied box_80 STL for GetCigar L basket.
// Requires src/box_80_transformed_source.stl as imported mesh.
// External envelope 160 x 350 x 120 mm.
W=160; D=350; H=120;
channel_x0=9; channel_w=142;
channel_z0=8; channel_h=104;
support_top=8.6;
module imported_original(){ import("box_80_transformed_source.stl",convexity=10); }
module adapted_shell(){
  difference(){
    imported_original();
    translate([channel_x0,-0.25,channel_z0]) cube([channel_w,D+0.5,channel_h]);
  }
}
module runner_supports(){
  translate([7.5,0,0]) cube([9,D,support_top]);
  translate([W-16.5,0,0]) cube([9,D,support_top]);
}
union(){ adapted_shell(); runner_supports(); }
