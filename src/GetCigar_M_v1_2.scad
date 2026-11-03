// GetCigar M | one-piece basket + separate under-mounted sliders
// Prototype v1.2; PETG 0.4 mm. Dimensions in millimeters.
// Choose part and press F6 then F7 to export STL.
// No supports by design, but verify layer preview in Elegoo Slicer.
// UNTESTED: do not load or fully extend until frame and stops exist.

part = "drawer"; // drawer, runner, guide, runner_test, guide_test, divider, view
drawer_variant = "M";
inside_w = 100;
inside_d = 320;
inside_h = 100;
wall_thickness = 2.4;
bottom_thickness = 3.2;
rib_width = 4;
rib_pitch = 28;
label_w = 95;   // 120-mm label from L cannot fit M front
label_h = 75;

runner_width = 9;
runner_height = 7;      // v1.1 was 3.5: basket rubbed on guide
runner_length = 315;
guide_slot_width = 9.8; // 0.4 mm clearance on each side
guide_base_height = 2.2;
guide_total_height = 6;
guide_side_wall = 2;
guide_length = 310;
rail_clearance = (guide_slot_width-runner_width)/2;

W = inside_w+2*wall_thickness;
D = inside_d+2*wall_thickness;
H = inside_h+bottom_thickness;
runner_left_x = 1.5;
runner_right_x = W-1.5-runner_width;
mount_y = [26,162,298];
$fn=32;

// 2D arch with a peaked roof: no long horizontal printing bridge
module arch2d(span,shaft,roof) {
 polygon([[0,0],[span,0],[span,shaft],
          [span/2,shaft+roof],[0,shaft]]);
}

module drawer() {
 difference() {
   // single connected shell: no fragile corner posts or snap tabs
   difference() {
     cube([W,D,H]);
     translate([wall_thickness,wall_thickness,bottom_thickness])
       cube([inside_w,inside_d,inside_h+0.1]);
   }

   // Ventilate the floor with open vertical holes, no bridges.
   // Solid strips along edges support rail mounting.
   for(x=[16:18:W-22],y=[12:23:D-20])
     translate([x,y,-0.5])
       cube([11,15,bottom_thickness+1]);

   // Side wall vents. Local sketch axes become (Y,Z).
   // Each roof has 45deg slopes (span 12, roof 6).
   for(y=[15:rib_pitch:D-27], xpos=[-1,W-wall_thickness-1])
     translate([xpos,y,19])
       rotate([0,0,90]) rotate([90,0,0])
       linear_extrude(wall_thickness+2)
         arch2d(12,49,6);

   // Rear wall vents: the sketch lies in XZ; extrusion goes toward -Y.
   for(x=[13:23:W-24])
     translate([x,D+1,19])
       rotate([90,0,0])
       linear_extrude(wall_thickness+2)
         arch2d(11,49,5.5);

   // Finger notch open from the top; no horizontal ceiling
   translate([W/2-15,-1,H-15])
     cube([30,wall_thickness+2,16]);

   // Through holes in strong solid floor perimeter. M3, not for
   // loose countersunk screws on sliding surface.
   for(x=[runner_left_x+runner_width/2,
          runner_right_x+runner_width/2], y=mount_y)
     translate([x,y,-0.5])
       cylinder(d=3.4,h=bottom_thickness+1);
 }
}

module runner(len=runner_length) {
 difference(){
   cube([runner_width,len,runner_height]);
   for(y=mount_y) if(y<len-6) {
     translate([runner_width/2,y,-0.1])
       cylinder(d=3.4,h=runner_height+0.2);
     // bottom counterbore recess for a low-profile screw head
     translate([runner_width/2,y,-0.1])
       cylinder(d=6.5,h=2.2);
   }
 }
}
module guide(len=guide_length) {
  // open U-section, prints base down and requires no supports
  cube([guide_slot_width+2*guide_side_wall,len,guide_base_height]);
  cube([guide_side_wall,len,guide_total_height]);
  translate([guide_slot_width+guide_side_wall,0,0])
    cube([guide_side_wall,len,guide_total_height]);
}
module divider() {
 difference(){
   cube([inside_w-1,inside_h-12,2.4]); // print flat
   for(x=[8:18:inside_w-15], y=[8:18:inside_h-25])
     translate([x,y,-0.5])cube([11,11,3.4]);
 }
}

if(part=="drawer") drawer();
else if(part=="runner") runner();
else if(part=="guide") guide();
else if(part=="runner_test") runner(60);
else if(part=="guide_test") guide(65);
else if(part=="divider") divider();
else if(part=="view"){
 drawer();
 translate([W+20,0,0])runner();
 translate([W+43,0,0])guide();
 translate([W+65,0,0])divider();
}
