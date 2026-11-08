// Box 80 v6: reinforce the ORIGINAL Box 80 v5 mesh, do not redesign it.
// Only ONE printable STL will be exported, oriented 150 x 120 x 350 mm.
// Assembled dimensions X=150, Y=350, Z=120 mm.
// Basket is unchanged 140 x 350 x 100 mm.
// The add-on solids bridge all four weak longitudinal transitions:
// lower-left, lower-right, upper-left, upper-right.
// Preserve front opening, existing rear stop and external roof/floor mating relief.
// In the basket's travel envelope (x=4..146, z=10..110), do not add plastic.

module box_v6_assembled() {
  union() {
    import("../../stl/box80_v5_ASSEMBLED_150x350x120.stl", convexity=12);

    // Lower edges. Existing sidewalls are x=0..4 and x=146..150.
    // These rails occupy only the space BELOW the sliding basket (z<10).
    translate([2.9, 0, 2.0]) cube([5.1, 350, 7.6]);
    translate([142, 0, 2.0]) cube([5.1, 350, 7.6]);

    // Upper edges. These rails sit ABOVE the basket travel envelope (z>110).
    // Stop below the ORIGINAL external honeycomb mating relief.
    translate([2.9, 0, 110.4]) cube([5.1, 350, 5.3]);
    translate([142, 0, 110.4]) cube([5.1, 350, 5.3]);
  }
}

// Printing orientation: bottom face on bed (150 x 120), box stands 350 mm tall.
translate([0, 0, 350]) rotate([-90, 0, 0]) box_v6_assembled();
