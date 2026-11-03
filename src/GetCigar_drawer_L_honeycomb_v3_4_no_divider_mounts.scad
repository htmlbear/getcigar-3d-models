// GetCigar L v3.4 vertical-print EXPERIMENTAL — 140 x 350 x 100 mm OUTSIDE, honeycomb basket. Vertical orientation requires support/bridge testing.
// No integrated divider guides; future separate glued triangular-foot divider. No attached runners.
$fn=24;
outer_w=140; outer_d=350; outer_h=100;
wall=2.4; floor_t=3;
W=outer_w; D=outer_d; H=outer_h;
hex_width=22; hex_height=20; hex_pitch=26; hex_row_pitch=22;
hex_first_z=17; hex_rows=4; hex_end_margin=13;
floor_pitch=12.5; floor_opening=9; floor_min_margin_x=9; floor_min_margin_y=9;
notch_width=44; notch_depth=17; notch_r=6;
// Side stiffness: continuous inward-facing upper rail (no external runners)
top_rail_inset=2.4; top_rail_height=7;
// Divider mounts removed; separate glued divider will be designed later.
fnx=floor((W-2*floor_min_margin_x-floor_opening)/floor_pitch)+1;
fny=floor((D-2*floor_min_margin_y-floor_opening)/floor_pitch)+1;
fmx=(W-((fnx-1)*floor_pitch+floor_opening))/2;
fmy=(D-((fny-1)*floor_pitch+floor_opening))/2;
module hex2d(w,h){s=.35;polygon([[0,-h/2],[w/2,-h/2+s*h],[w/2,h/2-s*h],[0,h/2],[-w/2,h/2-s*h],[-w/2,-h/2+s*h]]);}
module side_cut(x,y,z){translate([x,y,z])rotate([90,0,90])linear_extrude(height=wall+1.2)hex2d(hex_width,hex_height);}
module back_cut(x,z){translate([x,D+.6,z])rotate([90,0,0])linear_extrude(height=wall+1.2)hex2d(hex_width,hex_height);}
module notch(){x0=(W-notch_width)/2; y0=-.6; z0=H-notch_depth;r=notch_r;dy=wall+1.2;
union(){translate([x0,y0,z0+r])cube([notch_width,dy,notch_depth-r+1]);translate([x0+r,y0,z0])cube([notch_width-2*r,dy,notch_depth+1]);for(x=[x0+r,x0+notch_width-r])translate([x,y0,z0+r])rotate([-90,0,0])cylinder(h=dy,r=r,$fn=40);}}
module honeycomb_shell(){difference(){
 difference(){cube([W,D,H]);translate([wall,wall,floor_t])cube([W-2*wall,D-2*wall,H-floor_t+.5]);}
 for(ix=[0:fnx-1],iy=[0:fny-1]) {
   xx=fmx+ix*floor_pitch+(iy%2)*floor_pitch/2;
   yy=fmy+iy*floor_pitch;
   if(xx+floor_opening/2<=W-floor_min_margin_x)
     translate([xx,yy,-.5])linear_extrude(height=floor_t+1)hex2d(floor_opening,floor_opening);
 }
 for(row=[0:hex_rows-1],n=[0:ceil(D/hex_pitch)]){zz=hex_first_z+row*hex_row_pitch; yy=hex_end_margin+hex_width/2+n*hex_pitch+(row%2)*hex_pitch/2;
 if(yy+hex_width/2<=D-hex_end_margin && zz+hex_height/2<=H-7 && zz-hex_height/2>=6){side_cut(-.6,yy,zz);side_cut(W-wall-.6,yy,zz);}}
 for(row=[0:hex_rows-1],n=[0:ceil(W/hex_pitch)]){zz=hex_first_z+row*hex_row_pitch;xx=10+hex_width/2+n*hex_pitch+(row%2)*hex_pitch/2;
 if(xx+hex_width/2<W-9 && zz+hex_height/2<=H-7 && zz-hex_height/2>=6)back_cut(xx,zz);}
 notch();}}
union(){honeycomb_shell();
 // Top rails are inside the walls, keeping outer width exactly 140 mm.
 for(x=[wall,W-wall-top_rail_inset])translate([x,wall,H-top_rail_height])cube([top_rail_inset,D-2*wall,top_rail_height]);
}
