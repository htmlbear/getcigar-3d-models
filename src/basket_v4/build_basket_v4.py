#!/usr/bin/env python3
"""Build Basket v4 by merging its continuous lip with the original v3 STL.

Do NOT regenerate v3 or apply scaling.  CGAL's Nef conversion sometimes fails
on overlapping imported legacy tessellated surfaces; manifold3d is used
specifically to avoid a 'rim-only STL' masquerading as the finished basket.
"""
from pathlib import Path
import argparse
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_BASE = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x350_v3_finger_scoop.stl"
DEFAULT_RIM = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_v4_rim_only_tmp.stl"
DEFAULT_OUT = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x350_v4_curved_rim.stl"


def build(base_path: Path, rim_path: Path, out_path: Path):
    base = trimesh.load(base_path, force="mesh", process=True)
    lip = trimesh.load(rim_path, force="mesh", process=True)

    for name, mesh in [("basket v3", base), ("curved lip", lip)]:
        if not mesh.is_volume or not mesh.is_watertight:
            raise ValueError(f"{name} is not a valid closed solid.")

    # Compute a genuine volumetric union; mesh concatenation would create
    # intersecting shells and an invalid 3D-printable model.
    combined = trimesh.boolean.union([base, lip], engine="manifold", check_volume=True)
    if not isinstance(combined, trimesh.Trimesh):
        raise TypeError("Manifold union did not return a single mesh.")

    combined.remove_unreferenced_vertices()
    combined.fix_normals()

    expected_bounds = np.array([[0., 0., 0.], [140., 350., 100.]])
    assert np.allclose(combined.bounds, expected_bounds, atol=0.035), combined.bounds
    assert combined.is_watertight and combined.is_volume, "Combined basket is not manifold"
    assert len(combined.split(only_watertight=True)) == 1, "Detached part after Boolean union"

    out_path.parent.mkdir(parents=True, exist_ok=True)
    combined.export(out_path)
    print("Basket v4 combined STL:", out_path)
    print("Base volume:", round(base.volume, 2))
    print("Rim volume:", round(lip.volume, 2))
    print("Combined volume:", round(combined.volume, 2))
    print("Single connected solid: YES")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", type=Path, default=DEFAULT_BASE)
    ap.add_argument("--rim", type=Path, default=DEFAULT_RIM)
    ap.add_argument("--output", type=Path, default=DEFAULT_OUT)
    args = ap.parse_args()
    build(args.base, args.rim, args.output)
