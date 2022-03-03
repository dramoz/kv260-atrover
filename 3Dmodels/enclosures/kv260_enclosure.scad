// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
use<../modules/enclosure_box.scad>
// ----------------------------------------------------------------------------------
// DIMENSIONS
kv260_enclosure_l = 140+1.5;
kv260_enclosure_w = 120+2;
  
// z plane
kv260_enclosure_h = z_dim_adj(36);
kv260_enclosure_bt_h = z_dim_adj(6);
kv260_enclosure_lid_h = z_dim_adj(12);

kv260_enclosure_wall_width = ptr_wall_width;
kv260_enclosure_bottom_wall_width = z_dim_adj(2);

_kv260_encl_screws_x_wall_offset_cnt = 20;
_kv260_encl_screws_y_wall_offset_cnt = 10;
kv260_enclosure_screws_xy = [
  [                _kv260_encl_screws_x_wall_offset_cnt*kv260_enclosure_wall_width,               _kv260_encl_screws_y_wall_offset_cnt*kv260_enclosure_wall_width],
  [kv260_enclosure_l - (_kv260_encl_screws_x_wall_offset_cnt/2)*kv260_enclosure_wall_width,               _kv260_encl_screws_y_wall_offset_cnt*kv260_enclosure_wall_width],
  [                _kv260_encl_screws_x_wall_offset_cnt*kv260_enclosure_wall_width, kv260_enclosure_w-(_kv260_encl_screws_y_wall_offset_cnt/2)*kv260_enclosure_wall_width],
  [kv260_enclosure_l - (_kv260_encl_screws_x_wall_offset_cnt/2)*kv260_enclosure_wall_width, kv260_enclosure_w-(_kv260_encl_screws_y_wall_offset_cnt/2)*kv260_enclosure_wall_width]
];

module KV260_enclosure(
  fitted_lid=true,
  draw_lid=false,
  draw_container=false,
  draw_as_close_box=false
)
{
  echo("----------------------------------------------------------------------------------------------------------------------------------------------------");
  echo("KV260 Enclosure");
  if(draw_container || draw_as_close_box ) {
    difference() {
      enclosure_box(
        length=kv260_enclosure_l, width=kv260_enclosure_w, height=kv260_enclosure_h, lid_height=kv260_enclosure_lid_h,
        xy_wall_width=kv260_enclosure_wall_width, z_wall_width=kv260_enclosure_bottom_wall_width,
        fitted_lid=fitted_lid, draw_container=true,
        xy_screws=[xy_screw_3mm_d, kv260_enclosure_screws_xy],
        tolerance=ptr_tolerance
      );
      union() {
        // Front ports (Ethernet/USB/HDMI/DisplayPort/PWR)
        translate([12+kv260_enclosure_wall_width, -kv260_enclosure_wall_width, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([118, 3*kv260_enclosure_wall_width, kv260_enclosure_h+kv260_enclosure_bottom_wall_width]);
        
        // microSD  
        translate([24+kv260_enclosure_wall_width, kv260_enclosure_w, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([14, 3*kv260_enclosure_wall_width, z_dim_adj(2+2)]);
        // Micro-USB
        translate([80+kv260_enclosure_wall_width, kv260_enclosure_w, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([11, 3*kv260_enclosure_wall_width, z_dim_adj(3+2)]);
        // P-mod
        translate([99+kv260_enclosure_wall_width, kv260_enclosure_w, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([18, 3*kv260_enclosure_wall_width, z_dim_adj(5+2)]);
      }
    }
  }
  if(draw_lid || draw_as_close_box) {
    // CAM screws
    cam_screws_hh = 2.38;
    cam_screws_d = 3;
    cam_screws_xy = [
      [ 25, 13],
      [ 60, 13],
    ];
    
    // cap
    cap_fan_d = 48;
    cap_fan_x_offset = 47.5;
    cap_fan_y_offset = 61;
    
    //rotate(enclosure_close_box_lid_rotate_ang(draw_as_close_box))
    //  translate(enclosure_close_box_lid_translate_xyz(draw_as_close_box=draw_as_close_box, length=kv260_enclosure_l, width=kv260_enclosure_w, height=kv260_enclosure_h, xy_wall_width=kv260_enclosure_wall_width, z_wall_width=kv260_enclosure_bottom_wall_width))
    difference() {
      enclosure_box(
        length=kv260_enclosure_l, width=kv260_enclosure_w, height=kv260_enclosure_h, lid_height=kv260_enclosure_lid_h,
        xy_wall_width=kv260_enclosure_wall_width, z_wall_width=kv260_enclosure_bottom_wall_width,
        fitted_lid=fitted_lid, draw_lid=true,
        xy_screws=[xy_screw_3mm_d, kv260_enclosure_screws_xy],
        tolerance=ptr_tolerance
      );
      
      translate([cap_fan_x_offset, cap_fan_y_offset, -kv260_enclosure_bottom_wall_width])
        cylinder(d=cap_fan_d, h=kv260_enclosure_h+2*kv260_enclosure_bottom_wall_width);
      
      // CAM screws
      translate([125, 20, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[1]-3, xy[0], 0])
              cylinder(h=4*kv260_enclosure_bottom_wall_width, d=xy_screw_3mm_d, $fn=50, center=true);
        }
      }
    }
  }
}

*difference() {
  //KV260_enclosure(draw_as_close_box=true);
  KV260_enclosure(draw_lid=true, draw_container=false);
  //KV260_enclosure(draw_lid=false, draw_container=true);
  *translate([kv260_enclosure_l/2, -10, -10])
    cube(500);
}
