/* GetCigar L drawer v0.1 FIT-CHECK. Units mm. PETG, 0.4mm nozzle.
   EXPERIMENTAL: open-top channels are NOT captive and have no load rating.
   Printed rails must not support a fully extended loaded drawer. */
part = "drawer"; // drawer, bottom, runner, guide, runner_test, guide_test, spacer, all_preview
inside_w=120; inside_d=320; inside_h=100;
wall=1.6; floor_t=1.2;
body_w=inside_w+2*wall; body_d=inside_d+2*wall;
runner_w=9; runner_h=3; runner_len=315;
guide_w=13; guide_h=6; guide_len=310; guide_base=1.8; guide_wall=1.5;
mount_y=[24,161,299];
$fn=24;
module box(x,y,z){cube([x,y,z]);}
module drawer(){
  difference(){
    union(){
      cube([body_w,body_d,5]);
      // vertical comb on the sides: each rib rises from the base without bridging
      for (y=[0:32:body_d-8]) {
        translate([0,y,5]) box(wall,7,inside_h-5);
        translate([body_w-wall,y,5]) box(wall,7,inside_h-5);
      }
      for(x=[0,body_w-wall]) for(y=[0,body_d-wall])
        translate([x,y,0])box(wall,wall,inside_h);
      // front/back ribs: no horizontal overhead lip
      for(x=[0:24:body_w-6]) {
        translate([x,0,5])box(6,wall,18);
        translate([x,body_d-wall,5])box(6,wall,18);
      }
      // pads for M3 fixing: correct external mounting footprint
      for (x=[4,body_w-12]) for(y=mount_y)
         translate([x,y-8,0])box(8,16,6);
    }
    translate([wall,wall,-0.5]) box(inside_w,inside_d,7);
    for (x=[8,body_w-8]) for(y=mount_y)
      translate([x,y,-1]) cylinder(d=3.3,h=9);
  }
  // shallow internal ledges for the separate printed base plate
  translate([wall,wall,0])box(3,inside_d,1.4);
  translate([body_w-wall-3,wall,0])box(3,inside_d,1.4);
  translate([wall,wall,0])box(inside_w,3,1.4);
  translate([wall,body_d-wall-3,0])box(inside_w,3,1.4);
}
module bottom(){
  w=inside_w-0.8; d=inside_d-0.8;
  union(){
    box(w,2.4,floor_t);
    translate([0,d-2.4,0])box(w,2.4,floor_t);
    box(2.4,d,floor_t);
    translate([w-2.4,0,0])box(2.4,d,floor_t);
    for(y=[20:32:d-10])translate([0,y,0])box(w,2,floor_t);
    for(x=[21:24:w-10])translate([x,0,0])box(2,d,floor_t);
  }
}
module runner(l=runner_len){
  difference(){
    box(runner_w,l,runner_h);
    for(y=mount_y) if(y<l-5){
      translate([runner_w/2,y,-1])cylinder(d=3.3,h=runner_h+2);
      translate([runner_w/2,y,-0.01])cylinder(d1=6.4,d2=3.3,h=1.9);
    }
  }
}
module guide(l=guide_len){
  union(){
    box(guide_w,l,guide_base);
    box(guide_wall,l,guide_h);
    translate([guide_w-guide_wall,0,0])box(guide_wall,l,guide_h);
  }
}
module spacer(){box(9,38,3);}
if(part=="drawer")drawer();
else if(part=="bottom")bottom();
else if(part=="runner")runner();
else if(part=="guide")guide();
else if(part=="runner_test")runner(55);
else if(part=="guide_test")guide(65);
else if(part=="spacer")spacer();
else if(part=="all_preview"){
 drawer();
 translate([body_w+18,0,0])bottom();
 translate([body_w+160,0,0])runner();
 translate([body_w+180,0,0])guide();
}