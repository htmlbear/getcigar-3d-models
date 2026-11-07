// Original Box 80 geometry, reoriented to put the ORIGINAL honeycomb panels
// on the functional TOP and BOTTOM and the original PLAIN panels at left/right.
// Width 160, Depth 350, total height 120 mm.
// No redesigned connectors and no side latches.
// Only relief needed: the original back aperture is too small for the
// 140 x 100 mm basket, so extend its clear opening to 144 x 102 mm.
// Honeycomb mating profiles on the horizontal roof and floor are unchanged.
difference(){
  import("box80_v4_correct_axes_scaled.stl", convexity=10);
  translate([8,345.5,9]) cube([144,4.6,102]);
}