#!/usr/bin/env python3
"""Box 80 v7: local fit fix ONLY for the upper stacking relief of v6.

Input is the actual validated v6 single-piece printable STL, on its end:
  X = 0..150 (width), Y = 0..120 (assembled height), Z = 0..350 (depth).
Lower mating surface, basket corridor, walls, ribs and all other vertices
remain exactly as in v6. No global scaling.

User's physical test of v6: female lower narrowest 134 mm, upper
insertion ~135.111 mm. Desired approximate final clearance: 2 mm total.
Source v6 mesh has a few end vertices of upper mating relief reaching
X=6.88887..143.111, which must also be accounted for.

Export target: ONE 150x120x350 STL with maximal upper insertion span
X=9..141 (=132 mm), nominally leaving 1 mm clearance per side
in the 134-mm female opening.

Requires: pip install trimesh numpy
Usage: python src/box80_v7/build_box80_v7.py
"""
from pathlib import Path

import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "stl/box80_v6_PRINT_ON_END_150x120x350.stl"
OUTPUT = ROOT / "stl/box80_v7_PRINT_ON_END_150x120x350.stl"

TOP_BAND_MIN_Y = 116.8
TOP_LEFT_ANCHOR_X = 11.1521
TOP_RIGHT_ANCHOR_X = 138.8479
NEW_TOP_MIN_X = 9.0
NEW_TOP_MAX_X = 141.0


def validate(mesh, label):
    assert mesh.is_watertight, f"{label}: mesh must be watertight"
    assert mesh.is_winding_consistent, f"{label}: inconsistent winding"
    assert mesh.is_volume and mesh.volume > 0, f"{label}: invalid volume"
    assert len(mesh.split(only_watertight=True)) == 1, f"{label}: not one solid"
    assert np.allclose(mesh.extents, [150, 120, 350], atol=0.03), (
        label, mesh.extents
    )


def build():
    old = trimesh.load(SOURCE, force="mesh", process=True)
    validate(old, "Source v6")
    initial = old.vertices.copy()
    updated = initial.copy()

    # Keep every vertex outside the upper mating geometry unchanged.
    upper = initial[:, 1] >= TOP_BAND_MIN_Y
    assert np.count_nonzero(upper) > 50, "No upper relief vertices found"
    xmin, xmax = np.min(initial[upper, 0]), np.max(initial[upper, 0])
    assert np.isclose(xmin, 6.88887, atol=0.03), xmin
    assert np.isclose(xmax, 143.111, atol=0.03), xmax

    # Monotonic piecewise X remapping, only at upper relief.
    # Most of the honeycomb pattern, x=11.1521..138.8479, is not touched.
    x_knots = [xmin, TOP_LEFT_ANCHOR_X, TOP_RIGHT_ANCHOR_X, xmax]
    x_targets = [NEW_TOP_MIN_X, TOP_LEFT_ANCHOR_X,
                 TOP_RIGHT_ANCHOR_X, NEW_TOP_MAX_X]
    updated[upper, 0] = np.interp(initial[upper, 0], x_knots, x_targets)

    assert np.array_equal(initial[~upper], updated[~upper]), (
        "Non-joining geometry was changed"
    )
    assert np.isclose(np.min(updated[upper, 0]), 9.0, atol=1e-5)
    assert np.isclose(np.max(updated[upper, 0]), 141.0, atol=1e-5)

    new = trimesh.Trimesh(vertices=updated, faces=old.faces.copy(),
                          process=False)
    new.fix_normals()
    validate(new, "Output v7")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    new.export(OUTPUT)

    loaded = trimesh.load(OUTPUT, force="mesh", process=True)
    validate(loaded, "Reopened output v7")
    print("Generated:", OUTPUT)
    print("Upper mating maximum width: 132.000 mm, X=9..141.")
    print("Lower mating profile/other geometry unchanged.")
    print("Single-manifold mesh validated; physical PETG fit still must be tested.")


if __name__ == "__main__":
    build()
