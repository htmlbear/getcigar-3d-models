// GetCigar Drawer L - flat-front ventilated prototype, v1.0
// Units: mm. Internal usable dimensions: 120 x 350 x 100.
// This is an untested prototype; no runner or guide is included.
$fn=48;
inside_w=120;
inside_d=350;
inside_h=100;
wall=2.4;
bottom_t=3.2;
label_zone_w=118; // full 120x75mm label will not fit on 124.8mm face with margins
label_zone_h=78;
finger_notch_w=34;
finger_notch_h=18;
runner_land_w=12;
side_open_w=16;
side_open_h=20;
side_pitch_y=24;
side_pitch_z=22;
back_open_w=14;
back_open_h=18;
back_pitch_x=22;
back_pitch_z=22;
W=inside_w+2*wall;
D=inside_d+2*wall;
H=inside_h+bottom_t;
module pointed_hex_2d(w,h){
 polygon(points=[[w/2,0],[w,h*0.22],[w,h*0.78],[w/2,h],[0,h*0.78],[0,h*0.22]]);
}
module side_cut(y,z){
 translate([-0.5,y,z]) rotate([90,0,90])
 linear_extrude(height=wall+1) pointed_hex_2d(side_open_w,side_open_h);
}
module right_side_cut(y,z){
 translate([W-wall-0.5,y,z]) rotate([90,0,90])
 linear_extrude(height=wall+1) pointed_hex_2d(side_open_w,side_open_h);
}
module back_cut(x,z){
 translate([x,D-wall-0.5,z]) rotate([90,0,0])
 linear_extrude(height=wall+1) pointed_hex_2d(back_open_w,back_open_h);
}
module drawer_body(){
 difference(){
 union(){
 difference(){
 cube([W,D,H]);
 translate([wall,wall,bottom_t])cube([inside_w,inside_d,inside_h+1]);
 }
 translate([wall,wall,bottom_t])cube([runner_land_w,inside_d,3.6]);
 translate([W-wall-runner_land_w,wall,bottom_t])cube([runner_land_w,inside_d,3.6]);
 }
 for(x=[18:16:W-22],y=[14:22:D-18])
 if(!(x < wall+runner_land_w+3 || x > W-wall-runner_land_w-14))
 translate([x,y,-0.2])cube([10,14,bottom_t+0.5]);
 for(y=[18:side_pitch_y:D-28],z=[18:side_pitch_z:H-28]){
 side_cut(y,z);
 right_side_cut(y,z);
 }
 for(x=[14:back_pitch_x:W-20],z=[18:back_pitch_z:H-26])
 back_cut(x,z);
 translate([W/2-finger_notch_w/2,-0.5,H-finger_notch_h])
 cube([finger_notch_w,wall+1,finger_notch_h+1]);
 }
}
drawer_body();
