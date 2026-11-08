# Box 80 v5: narrower, stronger side walls

Based directly on the *actual* approved [Box 80 v4 STL](../../stl/box80_v4_ASSEMBLED_160x350x120.stl), not a redesigned box.

- **Outside in assembled orientation:** 150 mm wide × 350 mm deep × 120 mm high.
- **Basket (unchanged):** 140 mm wide × 350 mm overall length × 100 mm high.
- **Side clearance:** 1 mm each side, nominal clear inner corridor 142 mm.
- **Two long plain side walls:** ~4 mm (previously ~1.06 mm at the mid-height cross section).
- **Horizontal honeycomb mating surfaces:** original faces/triangulation carried through with width adjustment.
- **Rear stop:** original lower rear frame is preserved; NO added square stops.
- **Back opening:** remains intentionally narrower, so the basket should not travel through it.
- **Height/depth:** unchanged; 350 mm includes original basket handle in basket specification.
- **Stacking:** visually preserved, but MUST be physically tested with 6 loaded boxes (1.2 kg each).

Files in \`stl/\`:
- \`box80_v5_ASSEMBLED_150x350x120.stl\` — correct assembly orientation.
- \`box80_v5_PRINT_ON_END_150x120x350.stl\` — single box for printing upright.
- \`box80_v5_2_ON_PLATE_420x420.stl\` — two boxes positioned on 420×420.
- \`box80_v5_6_ON_PLATE_420x420.stl\` — six boxes, **UNTESTED** high-risk long print.

Regenerate with \`python src/box80_v5/build_box80_v5.py\` and Python packages \`numpy\`, \`trimesh\`.

**Test fit:** In Elegoo Slicer, cut the FINAL \`PRINT_ON_END\` model at Z=170 and 180 mm and keep only the 10 mm thick middle ring. This is a true section of the final binary STL. Measure real printed inner width with calipers. Also verify front opening and preserved rear bottom stop separately.

**Not yet established:** physical fit/tolerance under PETG expansion, six-high load path, wall deflection/creep, support-free slicing, first-layer stability, 350 mm upright print or fit when the basket is fully extended. Do not start mass production until physical tests.
