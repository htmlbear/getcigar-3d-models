// Box 80 v10 Light — v9-compatible reduced inner shell.
// Input STL: unchanged v9 as printed and sliced by the user (334 g).
// This is a subtractive-only change; existing Box v8/v9 mating features,
// stop, basket passage, dimensions and exterior contour are untouched.
// Orientation: X 150 mm (width) / Y 120 mm (height) / Z 350 mm (length).
//
// WARNING: this experimental thin-wall shell must be checked in Elegoo
// Slicer and physically test-printed before being used under stacked loads.
source_stl="../../stl/box80_v9_light_PRINT_ON_END_150x120x350.stl";

// v9 inner skins = 2.1 mm; v10 target = 1.65 mm in the central
// honeycomb wall fields ONLY. All end frames and mating belts unchanged.
// With a 0.8 mm nozzle verify actual path generation / bridging first.
v9_remaining_skin=2.1;
v10_remaining_skin=1.65;

// Keep 12 mm of solid terminal frame at both Z ends, and intact
// structural belts at Y<17 and Y>103.
panel_y_min=17;
panel_y_max=103;
panel_z_min=12;
panel_z_max=338;

module left_inner_relief() {
    translate([v10_remaining_skin,panel_y_min,panel_z_min])
        cube([v9_remaining_skin-v10_remaining_skin+0.01,
              panel_y_max-panel_y_min,panel_z_max-panel_z_min]);
}
module right_inner_relief() {
    translate([150-v9_remaining_skin-0.01,panel_y_min,panel_z_min])
        cube([v9_remaining_skin-v10_remaining_skin+0.02,
              panel_y_max-panel_y_min,panel_z_max-panel_z_min]);
}

difference() {
    import(source_stl, convexity=15);
    left_inner_relief();
    right_inner_relief();
}
