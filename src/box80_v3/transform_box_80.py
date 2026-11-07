"""Reorient actual box_80 for width=160, length=350, height=116+4mm stack tongues.
Original files are kept intact. New axes: original Y -> X, X -> Y, Z -> Z.
Preserve original honeycomb side walls and top/bottom (Z-axis) stacking features.
"""
from pathlib import Path
import trimesh
import numpy as np
base=Path(__file__).resolve().parent
source=base/'box_80.stl'
m=trimesh.load(str(source),force='mesh',process=True)
lo=m.bounds[0]; extent=m.extents
v=m.vertices
x=(v[:,1]-lo[1])*160/extent[1]
y=(v[:,0]-lo[0])*350/extent[0]
z=(v[:,2]-lo[2])*116/extent[2]
# Thinner honeycomb wall edges while retaining the outside contour and matching
# all original joints at both ends: the user requires 143+ mm internal width.
x=np.interp(x,[0,12,80,148,160],[0,7,80,153,160])
new=trimesh.Trimesh(vertices=np.column_stack([x,y,z]),faces=m.faces[:,[0,2,1]],process=True)
assert new.is_watertight and len(new.split())==1
new.export(base/'box_80_original_transform_for_v3.stl')
print('transformed extents:',new.extents,'volume:',new.volume,'watertight:',new.is_watertight)