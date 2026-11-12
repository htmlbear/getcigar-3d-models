#!/usr/bin/env python3
"""Basket v5: remove ONLY topmost 2 mm of basket v4 without scaling.

All v4 material from Z=0 through Z<98 mm is unchanged, including the
front scoop's curved rim, label panel, honeycomb, ribs and side geometry.
Only material above the horizontal Z=98 plane is removed. Previous
versions remain untouched. The cutting operation creates a solid cap at
Z=98 where material intersects the plane.
"""
from pathlib import Path
import argparse
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[2]
V4 = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x350_v4_curved_rim.stl"
V5 = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x350_v5_height98.stl"
TARGET_HEIGHT = 98.0


def build(source: Path, destination: Path):
    mesh = trimesh.load(source, force="mesh", process=True)
    assert mesh.is_watertight and mesh.is_volume
    assert np.allclose(mesh.bounds, [[0, 0, 0], [140, 350, 100]], atol=0.035), mesh.bounds

    # Subtract from Z=98 up. The oversized tool covers X/Y fully, but
    # NO part of the model below Z=98 is transformed, modified or rescaled.
    cutter = trimesh.creation.box(extents=[160.0, 370.0, 12.0])
    cutter.apply_translation([70.0, 175.0, 104.0])  # Z=98..110

    result = trimesh.boolean.difference(
        [mesh, cutter], engine="manifold", check_volume=True
    )
    if not isinstance(result, trimesh.Trimesh):
        raise RuntimeError("Boolean trimming did not produce one STL mesh.")
    result.remove_unreferenced_vertices()

    assert result.is_watertight and result.is_volume, "Result is not watertight"
    assert result.is_winding_consistent, "Invalid face winding"
    assert len(result.split(only_watertight=True)) == 1, "Disconnected component"
    assert np.allclose(result.bounds, [[0, 0, 0], [140, 350, TARGET_HEIGHT]], atol=0.025), result.bounds
    assert result.volume < mesh.volume

    destination.parent.mkdir(parents=True, exist_ok=True)
    result.export(destination)
    print("Basket v5 STL:", destination)
    print("Final bounds:", result.bounds.tolist())
    print("Original volume mm3:", round(mesh.volume, 2))
    print("Trimmed volume mm3:", round(result.volume, 2))
    print("Removed mm3:", round(mesh.volume - result.volume, 2))
    print("Only Z>=98 removed; no global scaling")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=V4)
    parser.add_argument("--output", type=Path, default=V5)
    args = parser.parse_args()
    build(args.input, args.output)
