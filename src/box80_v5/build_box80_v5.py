#!/usr/bin/env python3
"""Box 80 v5: preserve v4 mesh/honeycomb, narrow to 150 mm, reinforce side walls.

IMPORTANT: No invented replacement design. This is a monotone piecewise
X-axis remap of the actual validated v4 STL, preserving all original faces,
front frame, rear bottom stop, horizontal honeycomb and stacking surfaces.
Original basket STL and all v4 files remain untouched.

Run from repository checkout after: pip install trimesh numpy
    python src/box80_v5/build_box80_v5.py
"""
from pathlib import Path
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "stl/box80_v4_ASSEMBLED_160x350x120.stl"
OUT = ROOT / "stl"
# Existing long-wall cross section: x = 0 .. about 1.06 mm.
# Map it to ~3.95 mm, with the small moulding crest at 1.1862 -> 4 mm.
# Thus the unobstructed central inner corridor is >=142 mm (x=4..146).
# Keep the original rear aperture x=8..142: its rim is the existing stop.
X_OLD = np.array([0, 1.06, 1.1862, 8, 80, 152,
                  158.8138, 158.94, 160], dtype=float)
X_NEW = np.array([0, 3.95, 4, 8, 75, 142,
                  146, 146.05, 150], dtype=float)


def validated(mesh, dimensions, components=1):
    assert mesh.is_watertight, "STL is not watertight"
    assert mesh.is_winding_consistent, "Incorrect triangle winding"
    assert len(mesh.split(only_watertight=False)) == components
    got = mesh.extents
    assert np.allclose(got, dimensions, atol=0.02), (got, dimensions)


def on_end(mesh):
    # v4's existing orientation: (x, y, z) -> (x, z, 350-y)
    v = mesh.vertices.copy()
    new = np.column_stack([v[:, 0], v[:, 2], 350 - v[:, 1]])
    return trimesh.Trimesh(vertices=new, faces=mesh.faces.copy(), process=False)


def layout(mesh, positions):
    copies = []
    for x, y in positions:
        inst = mesh.copy()
        inst.apply_translation([x, y, 0])
        copies.append(inst)
    return trimesh.util.concatenate(copies)


def main():
    old = trimesh.load(INPUT, force="mesh", process=True)
    validated(old, [160, 350, 120])
    vertices = old.vertices.copy()
    vertices[:, 0] = np.interp(vertices[:, 0], X_OLD, X_NEW)
    new = trimesh.Trimesh(vertices=vertices, faces=old.faces.copy(), process=False)
    validated(new, [150, 350, 120])
    new.export(OUT / "box80_v5_ASSEMBLED_150x350x120.stl")

    standing = on_end(new)
    validated(standing, [150, 120, 350])
    standing.export(OUT / "box80_v5_PRINT_ON_END_150x120x350.stl")

    two = layout(standing, [(40, 150), (220, 150)])
    validated(two, [330, 120, 350], 2)
    two.export(OUT / "box80_v5_2_ON_PLATE_420x420.stl")

    six = layout(standing, [(x, y) for y in (10, 150, 290)
                           for x in (20, 220)])
    validated(six, [350, 400, 350], 6)
    six.export(OUT / "box80_v5_6_ON_PLATE_420x420.stl")

    print("Box 80 v5: 150x350x120 mm assembled, 142 mm nominal passage")
    print("No additional rear stop. Original geometry preserved.")
    print("Use a 10 mm cut of the final on-end STL for the fit test.")
    print("Physical fit, PETG creep and printability STILL REQUIRE TESTS.")


if __name__ == "__main__":
    main()
