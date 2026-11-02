// GetCigar v1.1 | printed FLAT panels, support-free in specified orientation
part="side"; // side front back bottom post runner guide runner_test guide_test divider
$fn=24;
IW=120; ID=320; IH=100; wall=1.6; floorT=1.6;
P=8.6; slot=2; slotDepth=4; H=IH+2*floorT;
W=IW+P+wall; D=ID+P+wall;
panelW=W-2*(P-slotDepth); panelD=D-2*(P-slotDepth);
module lattice2d(w,h,spacing=20,bar=2){
  square([w,3]); translate([0,h-3])square([w,3]);
  square([3,h]); translate([w-3,0])square([3,h]);
  for(x=[spacing:spacing:w-6])translate([x,0])square([bar,h]);
  for(y=[spacing:spacing:h-6])translate([0,y])square([w,bar]);
}
module side(){
  linear_extrude(wall)lattice2d(panelD,H,21,2);
  translate([8,0,wall])cube([panelD-16,floorT,3.5]);
}
module front(){
  linear_extrude(wall){
    square([panelW,76]);
    translate([0,76])lattice2d(panelW,H-76,20,2);
  }
}
module back(){linear_extrude(wall)lattice2d(panelW,H,19,2);}
module bottom(){
  w=IW-0.8; d=ID-0.8;
  linear_extrude(floorT)lattice2d(w,d,17,2);
  for(x=[1.0,w-10])translate([x,0,0])cube([9,d,2.4]);
}
module post(){
  difference(){
    cube([P,P,H]);
    translate([P/2-slot/2,P-slotDepth,-0.1])
      cube([slot,slotDepth+0.1,H+0.2]);
    translate([P-slotDepth,P/2-slot/2,-0.1])
      cube([slotDepth+0.1,slot,H+0.2]);
  }
}
runnerW=9; runnerH=3.5; runnerLen=315;
guideSlotW=9.8; guideWall=2; guideBase=2.2; guideH=6; guideLen=309;
module runner(len=runnerLen){
  difference(){
    cube([runnerW,len,runnerH]);
    for(y=[22,154,286])if(y<len-4)
      translate([runnerW/2,y,-0.1])cylinder(d=3.3,h=runnerH+0.2);
  }
}
module guide(len=guideLen){
  cube([guideSlotW+2*guideWall,len,guideBase]);
  cube([guideWall,len,guideH]);
  translate([guideSlotW+guideWall,0,0])cube([guideWall,len,guideH]);
}
module divider(){linear_extrude(1.6)lattice2d(IW-1,IH-8,18,2);}
if(part=="side")side();
else if(part=="front")front();
else if(part=="back")back();
else if(part=="bottom")bottom();
else if(part=="post")post();
else if(part=="runner")runner();
else if(part=="guide")guide();
else if(part=="runner_test")runner(55);
else if(part=="guide_test")guide(65);
else if(part=="divider")divider();