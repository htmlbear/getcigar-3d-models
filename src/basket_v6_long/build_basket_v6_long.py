#!/usr/bin/env python3
"""GetCigar Basket v6 LONG (140 x 376 x 98 mm).

Extend the exact, previous printable Basket v5 by inserting a 26 mm
UNSCALED lattice segment in its middle. Front and back remain unwarped.
At the insertion splice, an internal U-shaped thin reinforcement joins
the original sidewall and floor ribs; no solid obstruction spans the
basket interior. Add a flush, recessed "L" identification to a small
front panel to the right of the untouched 75 x 40 mm label field.

This is a new, independent STL. NEVER replace or stretch Basket v5.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x350_v5_height98.stl"
OUTPUT = ROOT / "stl/L_gridfinity_30mm_center_rib/basket_140x376_v6_LONG_L.stl"
LENGTH = 376.0
ADD = 26.0
SPLICE_Y = 190.0  # repeated intact original lattice interval 190..216 mm
SEAM_Y = SPLICE_Y + ADD


def box_between(x0,x1,y0,y1,z0,z1):
    b=trimesh.creation.box(extents=[x1-x0,y1-y0,z1-z0])
    b.apply_translation([(x0+x1)/2,(y0+y1)/2,(z0+z1)/2])
    return b


def join(*meshes):
    merged = trimesh.boolean.union(list(meshes),engine="manifold",check_volume=True)
    if not isinstance(merged,trimesh.Trimesh):
        raise RuntimeError("Union returned no valid mesh")
    return merged


def build(source:Path,dest:Path):
    old=trimesh.load(source,force="mesh",process=True)
    assert old.is_volume and old.is_watertight
    assert np.allclose(old.bounds,[[0,0,0],[140,350,98]],atol=.03),old.bounds

    # Front segment contains original mesh through Y=216 unchanged.
    # Back segment resumes the ORIGINAL shape at Y=190, shifted +26 mm.
    # Therefore the complete existing sidewall/floor unit cell geometry is
    # retained; one existing 26-mm section is repeated instead of scaling.
    front=trimesh.boolean.intersection(
        [old,box_between(-10,150,-10,SEAM_Y,-10,110)],
        engine="manifold",check_volume=True)
    back=trimesh.boolean.intersection(
        [old,box_between(-10,150,SPLICE_Y,360,-10,110)],
        engine="manifold",check_volume=True)
    back.apply_translation([0,ADD,0])

    # 7-mm-long U-shaped splice bracket. Thin full-height side
    # reinforcement at ORIGINAL 2.4mm wall thickness; bottom linking rib.
    # Crucially this is NOT a front/back wall or a transverse partition.
    bridge_y0=SEAM_Y-3.5
    bridge_y1=SEAM_Y+3.5
    splice_parts=[
        box_between(0,2.4,bridge_y0,bridge_y1,3.0,98.0),
        box_between(137.6,140,bridge_y0,bridge_y1,3.0,98.0),
        box_between(0,140,bridge_y0,bridge_y1,0,4.5),
    ]
    # Manifold union creates ONE solid, removing coincident shells.
    basket=join(front,back,*splice_parts)

    # Flush plaque for version marking on the FRONT, Y=0. The original
    # adhesive label occupies X=32.5..107.5, Z=30..70.
    # Mark "L" on its RIGHT, never covering the original label.
    # The plaque is entirely inside the original basket envelope, not
    # outside the front wall, so it does NOT add to overall depth.
    plaque=box_between(109.0,139.5,0.0,3.5,37.0,69.0)
    basket=join(basket,plaque)

    # Deep enough to read as an engraved letter, never pierced through.
    # Two rectangular strokes: upright and base, thickness 4 mm.
    letters=[
        box_between(115,119,-1,0.9,43,63),
        box_between(115,132,-1,0.9,43,47),
    ]
    result=trimesh.boolean.difference(
        [basket,*letters],engine="manifold",check_volume=True)
    if not isinstance(result,trimesh.Trimesh):
        raise RuntimeError("Engraving failed")

    result.remove_unreferenced_vertices()
    assert result.is_volume and result.is_watertight and result.is_winding_consistent
    assert len(result.split(only_watertight=True))==1, "Disconnected basket/letter"
    expected=np.array([[0.,0.,0.],[140.,LENGTH,98.]])
    assert np.allclose(result.bounds,expected,atol=.035),result.bounds

    dest.parent.mkdir(parents=True,exist_ok=True)
    result.export(dest)
    print("BASKET LONG v6 ready:",dest)
    print("Dimensions:",result.extents.tolist())
    print("Base v5 volume mm3:",round(old.volume,3))
    print("LONG volume mm3:",round(result.volume,3))
    print("Added volume mm3:",round(result.volume-old.volume,3))
    print("Depth increased by 26 mm without scaling existing lattice.")
    print("A recessed L is placed to the right of the 75x40mm label.")
    return result


if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--input",type=Path,default=BASE)
    p.add_argument("--output",type=Path,default=OUTPUT)
    a=p.parse_args()
    build(a.input,a.output)
