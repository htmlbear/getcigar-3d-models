// GetCigar Humidor Full Drawer v1.0  | Units: mm
// Support-free geometry in intended print orientation. Prototype: fit/load not certified.
// Choose part: drawer, runner, guide, divider, runner_test, guide_test, stop, preview.
part="drawer";
IW=120; ID=320; IH=100;
SW=2.4; BW=3.2; FW=3.2; BD=3.0;
W=IW+2*SW; D=ID+SW+FW; H=IH+BD;
RW=9; RH=6; RL=315;
CL=10.0; GW=2.4; GB=2.4; GH=8; GL=310;
GP=CL+2*GW;
mount_y=[24,159,294];
$fn=24;
module d_hole(side=0) {
    if(side==0) for (yy=[16:22:D-13]) for(zz=[19:21:85])
        translate([-0.6,yy,zz]) rotate([0,90,0])
          linear_extrude(height=SW+1.2) polygon(points=[[0,-8],[-8,0],[0,8],[8,0]]);
    else for (xx=[15:21:W-13]) for(zz=[19:21:85])
        translate([xx,-0.6,zz]) rotate([90,0,0])
          linear_extrude(height=FW+1.2) polygon(points=[[0,-8],[-8,0],[0,8],[8,0]]);
}
module drawer(){
 difference(){
  union(){
    cube([SW,D,H]); translate([W-SW,0,0])cube([SW,D,H]);
    cube([W,FW,H]); translate([0,D-SW,0])cube([W,SW,H]);
    cube([W,SW,BD]); translate([0,D-SW,0])cube([W,SW,BD]);
    cube([SW,D,BD]); translate([W-SW,0,0])cube([SW,D,BD]);
    for(y=[14:18:D-10]) translate([SW,y,0])cube([IW,2.6,BD]);
    for(x=[SW+13:16:W-SW-10])translate([x,FW,0])cube([2.6,D-FW-SW,BD]);
    for(x=[2.4,W-12.4])for(y=mount_y)translate([x,y-11,0])cube([10,22,7]);
  }
  d_hole(0);
  translate([W-SW,0,0])d_hole(0);
  for (xx=[14:21:W-13]) for(zz=[19:21:85])
   translate([xx,D+0.6,zz]) rotate([90,0,0]) linear_extrude(height=SW+1.2)
    polygon(points=[[0,-8],[-8,0],[0,8],[8,0]]);
  translate([0,0,0]) polyhedron(
    points=[[W/2-17,-1,H+1],[W/2+17,-1,H+1],[W/2+17,FW+1,H+1],[W/2-17,FW+1,H+1],
            [W/2-10,-1,H-11],[W/2+10,-1,H-11],[W/2+10,FW+1,H-11],[W/2-10,FW+1,H-11]],
    faces=[[0,1,2,3],[4,7,6,5],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]);
  for(x=[7.4,W-7.4])for(y=mount_y)translate([x,y,-0.5])cylinder(d=3.3,h=8.5);
 }
}
module runner(len=RL){
 difference(){
  cube([RW,len,RH]);
  for(y=mount_y) if(y < len-7)
   translate([RW/2,y,1.1])cylinder(d=2.55,h=RH);
 }
}
module guide(len=GL){
 difference(){
  union(){cube([GP,len,GB]); cube([GW,len,GH]);translate([GP-GW,0,0])cube([GW,len,GH]);}
  for(y=[20:135:len-8]){
   translate([GP/2,y,-0.1])cylinder(d=3.4,h=1.2);
   translate([GP/2,y,1])cylinder(d1=3.4,d2=6.1,h=1.5);
  }
 }
}
module divider(){
 difference(){cube([IW-0.8,2.4,IH-9]);
 for (xx=[13:18:IW-13])for(zz=[15:19:IH-18])
  translate([xx,-0.5,zz])rotate([90,0,0])linear_extrude(height=3.4)
   polygon(points=[[0,-5],[-5,0],[0,5],[5,0]]);
 }
}
module stop(){
 difference(){cube([GP,12,10]);translate([GP/2,6,-1])cylinder(d=3.3,h=13);}
}
if(part=="drawer")drawer();
else if(part=="runner")runner();
else if(part=="guide")guide();
else if(part=="divider")divider();
else if(part=="runner_test")runner(58);
else if(part=="guide_test")guide(64);
else if(part=="stop")stop();
else if(part=="preview"){
 drawer();translate([W+12,0,0])runner();translate([W+27,0,0])guide();translate([W+48,0,0])divider();
}