"""Correctly orient user's Box 80 with hexagonal face as TOP and BOTTOM,
plain solid faces on left/right. Preserve original triangulation as much as possible.
"""
import numpy as np, trimesh
from pathlib import Path
P=Path(__file__).resolve().parent
source_file = next((q for q in (P/'box_80.stl', P.parent/'box_80.stl') if q.exists()), None)
if source_file is None: raise FileNotFoundError('box_80.stl not found next to script or in its parent folder')
src=trimesh.load(source_file,force='mesh',process=True)
v=src.vertices
b=src.bounds
# Original X is width, original Z becomes depth (reverse so wide opening is front),
# original Y becomes finished height, for honeycomb roof and floor.
x_raw=(v[:,0]-b[0,0])*160/src.extents[0]
y=(b[1,2]-v[:,2])*350/src.extents[2]
z=(v[:,1]-b[0,1])*120/src.extents[1]
# Compress original frame sidewall inwards from 11.7 mm to 8 mm,
# retaining unaltered exterior and patterned faces and sufficient 144mm internal width.
# This is a dimensional adjustment, not a newly designed case.
x_edge=(74+86.68)*160/(2*86.68)
x_min_inner=160-x_edge
x=np.interp(x_raw,[0,x_min_inner,160-x_min_inner,160],[0,8,152,160])
vnew=np.column_stack((x,y,z))
m=trimesh.Trimesh(vertices=vnew,faces=src.faces,process=True)
print('orig',src.extents,src.is_watertight,src.volume)
print('new ',m.extents,m.is_watertight,m.volume,m.bounds, len(m.split()))
m.export(P/'box80_v4_correct_axes_scaled.stl')