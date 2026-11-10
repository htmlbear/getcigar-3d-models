// Box 80 v8. Based on the actual v7 STL; no global resizing or remodeling.
// CUT ONLY TWO LONG SIDE WALLS: add through hexagons that use the same
// approximate cell scale as the existing upper/lower honeycomb.
// Original roof, floor, 132 mm top mating width, 134 mm female seat,
// basket passage, end frames and v6 longitudinal reinforcement remain intact.
//
// Print orientation of imported source: X=150 (width), Y=120 (height),
// Z=350 (length), i.e. STL is upright on its end for printing.
//
// Measured original roof/floor cellular dimensions:
//   lateral pitch: ~30.558 mm, longitudinal pitch: ~60.176 mm
//   lateral clear cell width: ~25.09 mm
//   longitudinal straight segment: ~32.94 mm
// Retain these dimensions in side honeycomb as closely as practical.

source_stl = "../../stl/box80_v7_PRINT_ON_END_150x120x350.stl";

cell_half_height = 12.545;   // opening: 25.09 mm vertically on the long wall
cell_half_length = 27.2;     // opening: 54.4 mm along the box length
cell_half_flat = 16.47;      // straight part: 32.94 mm, tips truncated
row_pitch = 30.558;
length_pitch = 60.176;

// Three heightwise rows, centered safely between upper and lower
// structural/mating belts (below Y≈10 and above Y≈110).
row_centers = [60 - row_pitch, 60, 60 + row_pitch];

// Alternate row offsets create a regular staggered honeycomb.
// No holes reach the original front/rear end frames.
module hexagonal_sidewall_cut(xstart, dx, cy, cz) {
    translate([xstart, cy, cz])
        rotate([0, 90, 0])
            linear_extrude(height=dx, convexity=10)
                polygon(points=[
                    [-cell_half_length, 0],
                    [-cell_half_flat, -cell_half_height],
                    [ cell_half_flat, -cell_half_height],
                    [ cell_half_length, 0],
                    [ cell_half_flat,  cell_half_height],
                    [-cell_half_flat,  cell_half_height]
                ]);
}

module sidewall_holes(xstart, dx) {
    for (row=[0:2]) {
        for (column=[0:4]) {
            cy = row_centers[row];
            cz = (row==1 ? 70 : 40) + column * length_pitch;
            hexagonal_sidewall_cut(xstart, dx, cy, cz);
        }
    }
}

// Restrict cutters to the actual 4-mm walls: do NOT tunnel across
// the interior space, ribs, roof/floor or opposite side.
difference() {
    import(source_stl, convexity=15);
    sidewall_holes(-0.5, 5.5);  // X=-0.5..5, left wall X=0..4
    sidewall_holes(145.0, 5.5); // X=145..150.5, right wall X=146..150
}
