from pathlib import Path
import trimesh
import numpy as np

base=Path(__file__).resolve().parent
src=base / "box_80.stl"
m=trimesh.load(str(src), force="mesh", process=True)
mn=m.bounds[0]; e=m.extents; v=m.vertices
x=(v[:,1]-mn[1])*160/e[1]
y=(v[:,0]-mn[0])*350/e[0]
z=(v[:,2]-mn[2])*120/e[2]
x=np.interp(x, [0,14,146,160],[0,9,151,160])
mesh=trimesh.Trimesh(vertices=np.column_stack((x,y,z)),faces=m.faces[:,[0,2,1]],process=True)
mesh.export(str(base / "box_80_transformed_source.stl"))
