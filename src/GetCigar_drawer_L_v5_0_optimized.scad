// GetCigar L v5.0 optimized, 140 x 350 x 100 mm, open rear
// Print vertically: rotate +90 around X, then translate Y +100.
$fn=32;
W=140; D=350; H=100; wall=2; floor_t=2.4; front_t=2.4;
upper_band=7; lower_band=7; label_w=75; label_h=40;
notch_width=44; notch_depth=17; notch_r=6;
module diamond(w,h){polygon([[0,-h/2],[w/2,0],[0,h/2],[-w/2,0]]);}
module side_hole(x,y,z){translate([x,y,z])rotate([90,0,90])linear_extrude(height=wall+1.2)diamond(40,35);}
module front_hole(x,z,w,h){translate([x,front_t+0.5,z])rotate([90,0,0])linear_extrude(height=front_t+1)diamond(w,h);}
module notch(){
 x0=(W-notch_width)/2;y0=-.5;z0=H-notch_depth;r=notch_r;
 union(){
 translate([x0,y0,z0+r])cube([notch_width,front_t+1,notch_depth-r+1]);
 translate([x0+r,y0,z0])cube([notch_width-2*r,front_t+1,notch_depth+1]);
 for(x=[x0+r,x0+notch_width-r])translate([x,y0,z0+r])rotate([-90,0,0])cylinder(h=front_t+1,r=r,$fn=40);
 }}
module shell(){difference(){
 union(){
 cube([W,front_t,H]);cube([wall,D,H]);
 translate([W-wall,0,0])cube([wall,D,H]);
 cube([W,D,floor_t]);
 for(x=[wall,W-wall-2])translate([x,front_t,H-upper_band])cube([2,D-front_t,upper_band]);
 for(x=[W/3-2,W*2/3-2])translate([x,front_t,floor_t])cube([4,D-front_t,2.2]);
 for(x=[wall,W-wall-4])translate([x,front_t,0])cube([4,5,H]);
 }
 for(row=[0:1],n=[0:6]){
 z=27+row*43;y=31+n*48+(row%2)*22;
 if(y+21<D-10 && z+18<H-upper_band && z-18>lower_band){
 side_hole(-.5,y,z);side_hole(W-wall-.5,y,z);
 }}
 for(n=[0:25],ix=[0:8]){
 y=12+n*13;x=10+ix*15+(n%2)*7;
 if(x+5<W-9 && y+6<D-6 && abs(x-W/3)>7.5 && abs(x-W*2/3)>7.5)
 translate([x,y,-.5])linear_extrude(height=floor_t+1)diamond(10,11);
 }
 for(x=[17,123],z=[24,49,74])front_hole(x,z,14,15);
 for(x=[45,70,95])front_hole(x,14,14,11);
 notch();
}}
shell();
