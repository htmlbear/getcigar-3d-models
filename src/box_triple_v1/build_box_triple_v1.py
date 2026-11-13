#!/usr/bin/env python3
"""Build exact three-bay Box v10 union, preserving every original basket passage.
Source mesh is kept unchanged; overlaps only occur in the shared wall zones.
Run at repository root: python src/box_triple_v1/build_box_triple_v1.py
Requires: numpy, trimesh, manifold3d.
"""
from __future__ import annotations

import json
import math
from pathlib import Path

import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "stl/box80_v10_light_PRINT_ON_END_150x120x350.stl"
OUTPUT = ROOT / "stl/box_triple_v1_PRINT_45DEG_400p22x400p22x350.stl"
METRICS = ROOT / "docs/box_triple_v1_metrics.json"

BAYS = 3
SINGLE_WIDTH = 150.0
PITCH = 148.0
SINGLE_HEIGHT = 120.0
DEPTH = 350.0
BED_SIDE = 420.0
BED_CENTRE = BED_SIDE / 2
ANGLE_DEGREES = 45.0
BASKET_PASSAGE_X = (4.0, 146.0)
BASKET_PASSAGE_Y = (10.0, 110.0)
DENSITY_PETG_G_CM3 = 1.27


def assert_solid(mesh: trimesh.Trimesh, name: str) -> None:
    assert mesh.is_watertight, f"{name}: non-watertight mesh"
    assert mesh.is_winding_consistent, f"{name}: inconsistent face winding"
    assert mesh.is_volume and mesh.volume > 0, f"{name}: invalid volume"
    assert len(mesh.split(only_watertight=True)) == 1, f"{name}: multiple separate bodies"


def main() -> None:
    source = trimesh.load_mesh(SOURCE, process=True)
    assert isinstance(source, trimesh.Trimesh)
    assert_solid(source, "source v10")
    assert np.allclose(source.bounds[0], (0, 0, 0), atol=0.08), source.bounds
    assert np.allclose(source.extents, (150, 120, 350), atol=0.08), source.extents

    # This construction NEVER rescales, cuts or reconstructs existing geometry.
    # In each original passage x=4..146, its neighbours lie entirely outside.
    origins = [n * PITCH for n in range(BAYS)]
    for bay, x0 in enumerate(origins):
        corridor_x0 = x0 + BASKET_PASSAGE_X[0]
        corridor_x1 = x0 + BASKET_PASSAGE_X[1]
        for other, other_x0 in enumerate(origins):
            if other == bay:
                continue
            other_x1 = other_x0 + SINGLE_WIDTH
            assert other_x1 <= corridor_x0 or other_x0 >= corridor_x1, (
                "Adjacent box intrudes into original basket passage", bay, other
            )

    copies = []
    for x0 in origins:
        part = source.copy()
        part.apply_translation((x0, 0, 0))
        copies.append(part)

    # True mesh BOOLEAN union, not merely a multi-solid STL concatenate.
    combined = trimesh.boolean.union(copies, engine="manifold")
    combined.remove_unreferenced_vertices()
    assert_solid(combined, "monolithic triple")
    target_width = SINGLE_WIDTH + (BAYS - 1) * PITCH
    assert np.allclose(combined.extents, (target_width, 120, 350), atol=0.08), combined.extents

    source_3_volume = BAYS * source.volume
    saved_volume = source_3_volume - combined.volume
    assert saved_volume > 0, "Union did not remove redundant wall material"
    assert saved_volume < 0.25 * source_3_volume, "Unexpected large geometry subtraction"

    # Keep original Z=350 mm as the vertical print axis. Rotate ONLY around Z
    # and centre the 446 x 120 footprint on the actual 420 x 420 bed.
    angle = math.radians(ANGLE_DEGREES)
    c, s = math.cos(angle), math.sin(angle)
    original_xy = combined.vertices[:, :2].copy()
    original_xy -= (target_width / 2, SINGLE_HEIGHT / 2)
    combined.vertices[:, 0] = BED_CENTRE + c * original_xy[:, 0] - s * original_xy[:, 1]
    combined.vertices[:, 1] = BED_CENTRE + s * original_xy[:, 0] + c * original_xy[:, 1]
    assert_solid(combined, "rotated printable triple")
    bounds = combined.bounds
    assert bounds[0, 0] >= 0 and bounds[0, 1] >= 0, bounds
    assert bounds[1, 0] <= BED_SIDE and bounds[1, 1] <= BED_SIDE, bounds
    assert np.allclose((bounds[0, 2], bounds[1, 2]), (0, DEPTH), atol=0.08)
    footprint = (target_width + SINGLE_HEIGHT) / math.sqrt(2)
    assert np.allclose(combined.extents[:2], (footprint, footprint), atol=0.08)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    combined.export(OUTPUT, file_type="stl")
    exported = trimesh.load_mesh(OUTPUT, process=True)
    assert_solid(exported, "exported STL")
    assert np.allclose(exported.bounds, combined.bounds, atol=0.08)
    assert np.isclose(exported.volume, combined.volume, rtol=1e-5)

    report = {
        "status": "CAD-validated, unprinted",
        "source": str(SOURCE.relative_to(ROOT)),
        "stl": str(OUTPUT.relative_to(ROOT)),
        "basket_fit": "Original Box v10 passages 142 x 100 mm, untouched in each bay",
        "bays": BAYS,
        "single_base_mm": [150, 120, 350],
        "lateral_pitch_mm": PITCH,
        "triple_unrotated_mm": [target_width, 120, 350],
        "rotation_about_vertical_degrees": ANGLE_DEGREES,
        "xy_print_footprint_mm": [round(float(x), 3) for x in exported.extents[:2]],
        "z_print_height_mm": round(float(exported.extents[2]), 3),
        "xy_min_mm": [round(float(x), 3) for x in exported.bounds[0, :2]],
        "xy_max_mm": [round(float(x), 3) for x in exported.bounds[1, :2]],
        "single_v10_cad_volume_mm3": round(float(source.volume), 3),
        "three_separate_v10_cad_volume_mm3": round(float(source_3_volume), 3),
        "triple_cad_volume_mm3": round(float(exported.volume), 3),
        "cad_volume_saved_mm3": round(float(saved_volume), 3),
        "cad_volume_saved_percent": round(100 * float(saved_volume / source_3_volume), 3),
        "petg_solid_equivalent_saving_g_not_slicer": round(float(saved_volume / 1000 * DENSITY_PETG_G_CM3), 3),
        "mesh_watertight": bool(exported.is_watertight),
        "mesh_single_connected_body": bool(len(exported.split(only_watertight=True)) == 1),
        "physical_basket_compatibility_verified": False,
        "actual_slicer_consumption_verified": False,
        "no_supports_verified_in_slicer": False,
        "safe_six_high_load_verified": False
    }
    METRICS.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    print("PASS: exact original three channels, one closed mesh, 45-degree footprint inside 420x420.")


if __name__ == "__main__":
    main()
