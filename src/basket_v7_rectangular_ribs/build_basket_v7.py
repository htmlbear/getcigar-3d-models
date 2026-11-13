#!/usr/bin/env python3
"""Basket v7 Standard (140 x 350 x 98): replace ONLY inner sloping side gussets.

Exact source mesh: existing basket_140x350_v5_height98.stl.
The v2 construction used continuous triangular gussets on both long side
walls with XZ triangle (1.5,3.8) (11,3.8) (1.5,12.0) and its mirror.
The triangle meets the solid floor joining band at Z=4.5. This script
shaves away the *overhanging interior triangular portion* without
touching the floor band or the wall, then unions compact, upright
RECTANGULAR ribs, continuously supported from the floor band.

Everything outside two targeted internal side/bottom strips is left
exactly as it was: unscaled 140 x 350 x 98, curved finger rim, label,
hexagonal wall design, floor lattice, central rib, and rear end.
"""
from __future__ import annotations
from pathlib import Path
import argparse
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x350_v5_height98.stl"
OUTPUT = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x350_v7_rectangular_ribs.stl"

# Legacy gussets: triangle in XZ plane from original v2 source.
# Original LONG side wall nominal thickness ~=2.4 mm; retaining its
# interior-most face and the 11x4.5-mm floor joining band is mandatory.
SIDE_WALL_INNER = 2.4
BASE_RAIL_TOP = 4.5
RIB_X_INNER = 1.50  # overlap into original solid sidewall
RIB_X_OUTER = 5.75  # new square vertical inner rib face
RIB_TOP = 12.0


def prism_xz(triangle_xz: list[tuple[float,float]], y_min:float, y_max:float):
    """Closed triangular prism extruded along y; used as a Boolean cutter."""
    low = [[x,y_min,z] for x,z in triangle_xz]
    high = [[x,y_max,z] for x,z in triangle_xz]
    verts = np.asarray(low+high, dtype=float)
    faces = np.asarray([
        [0,2,1], [3,4,5],
        [0,1,4], [0,4,3],
        [1,2,5], [1,5,4],
        [2,0,3], [2,3,5],
    ])
    mesh = trimesh.Trimesh(vertices=verts, faces=faces, process=True)
    mesh.fix_normals()
    assert mesh.is_watertight and mesh.is_volume
    return mesh


def box_bounds(x0,x1,y0,y1,z0,z1):
    m=trimesh.creation.box(extents=[x1-x0,y1-y0,z1-z0])
    m.apply_translation([(x0+x1)/2,(y0+y1)/2,(z0+z1)/2])
    return m


def build(source:Path,output:Path):
    original=trimesh.load(source,force="mesh",process=True)
    assert original.is_watertight and original.is_volume
    assert np.allclose(original.bounds,[[0,0,0],[140,350,98]],atol=.035)

    # The original wedge upper line:
    # z=3.8+ (11-x)*(8.2/9.5).
    # We trim ONLY its part above floor rail (z>4.5), and beyond
    # sidewall proper (x>2.4). The 0.01mm offset prevents face-on-face
    # precision errors but leaves original exterior (x<2.4) intact.
    start_x=2.41
    start_z=4.501
    top_at_start=3.8+(11-start_x)*(8.2/9.5)
    end_at_floor=11-(start_z-3.8)*(9.5/8.2)
    triangle=[(start_x,start_z),(end_at_floor+0.02,start_z),
              (start_x,top_at_start+0.02)]

    # Add tiny overlap at rib base and wall to force a watertight union.
    left_cutter=prism_xz(triangle,-.10,350.10)
    right_cutter=prism_xz([(140-x,z) for x,z in triangle],-.10,350.10)

    after_cut=trimesh.boolean.difference(
        [original,left_cutter,right_cutter],
        engine="manifold",check_volume=True)
    assert isinstance(after_cut,trimesh.Trimesh), "Boolean cutting failed"

    # Square ribs are STRAIGHT-UP from the existing full-length floor
    # side rails: no diagonal or cantilevered upper surface.
    left_rib=box_bounds(RIB_X_INNER,RIB_X_OUTER,.0,350.0,3.7,RIB_TOP)
    right_rib=box_bounds(140-RIB_X_OUTER,140-RIB_X_INNER,.0,350.0,3.7,RIB_TOP)

    updated=trimesh.boolean.union(
        [after_cut,left_rib,right_rib],
        engine="manifold",check_volume=True)
    assert isinstance(updated,trimesh.Trimesh)
    updated.remove_unreferenced_vertices()
    assert updated.is_watertight and updated.is_volume and updated.is_winding_consistent
    assert len(updated.split(only_watertight=True)) == 1, "Disconnected rib"
    assert np.allclose(updated.bounds,original.bounds,atol=.035),updated.bounds

    output.parent.mkdir(parents=True,exist_ok=True)
    updated.export(output)
    print("BASKET V7 STANDARD RECTANGULAR RIBS CREATED")
    print("Bounds:",updated.bounds.tolist())
    print("CAD volume source:",round(original.volume,2))
    print("CAD volume updated:",round(updated.volume,2))
    print("CAD volume change:",round(updated.volume-original.volume,2))
    print("Only sidewall-to-floor inner gussets modified")
    return original,updated


if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--input",type=Path,default=SOURCE)
    p.add_argument("--output",type=Path,default=OUTPUT)
    args=p.parse_args()
    build(args.input,args.output)
