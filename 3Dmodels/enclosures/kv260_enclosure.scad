// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
use<../modules/enclosure_box.scad>
include<HBV-1780-2.stereocam.scad>
include<ZK-5AD(Dual-DC-motor_ctrl).scad>
// ----------------------------------------------------------------------------------
// DIMENSIONS
kv260_enclosure_l = 140+1.5;
kv260_enclosure_w = 120+2;
  
// z plane
kv260_enclosure_h = z_dim_adj(36);
kv260_enclosure_board_bt_clearance = z_dim_adj(7);
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
  draw_as_close_box=false,
  draw_other_enclosures=false
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
        translate([12+kv260_enclosure_wall_width, kv260_enclosure_w, kv260_enclosure_bottom_wall_width+kv260_enclosure_board_bt_clearance])
          cube([118, 3*kv260_enclosure_wall_width, kv260_enclosure_h+kv260_enclosure_bottom_wall_width]);
        
        // microSD
        translate([103+kv260_enclosure_wall_width, -kv260_enclosure_wall_width, kv260_enclosure_bottom_wall_width+kv260_enclosure_board_bt_clearance])
          cube([118-103, 3*kv260_enclosure_wall_width, z_dim_adj(3+2)]);
        // Micro-USB
        translate([49+kv260_enclosure_wall_width, -kv260_enclosure_wall_width, kv260_enclosure_bottom_wall_width+kv260_enclosure_board_bt_clearance])
          cube([59-49, 3*kv260_enclosure_wall_width, z_dim_adj(3+2)]);
        // P-mod
        translate([23+kv260_enclosure_wall_width, -kv260_enclosure_wall_width, kv260_enclosure_bottom_wall_width+kv260_enclosure_board_bt_clearance])
          cube([41-23, 3*kv260_enclosure_wall_width, z_dim_adj(6+2)]);
      }
    }
  }
  if(draw_lid || draw_as_close_box) {
    // Fan
    cap_fan_d = 48;
    cap_fan_x_offset = 46;
    cap_fan_y_offset = 60.5;
    
    rotate(enclosure_close_box_lid_rotate_ang(draw_as_close_box))
      translate(enclosure_close_box_lid_translate_xyz(draw_as_close_box=draw_as_close_box, length=kv260_enclosure_l, width=kv260_enclosure_w, height=kv260_enclosure_h, xy_wall_width=kv260_enclosure_wall_width, z_wall_width=kv260_enclosure_bottom_wall_width))
        difference() {
          enclosure_box(
            length=kv260_enclosure_l, width=kv260_enclosure_w, height=kv260_enclosure_h, lid_height=kv260_enclosure_lid_h,
            xy_wall_width=kv260_enclosure_wall_width, z_wall_width=kv260_enclosure_bottom_wall_width,
            fitted_lid=fitted_lid, draw_lid=true,
            xy_screws=[xy_screw_3mm_d, kv260_enclosure_screws_xy],
            tolerance=ptr_tolerance
          );
      
      // Fan socket
      translate([cap_fan_x_offset, cap_fan_y_offset, -kv260_enclosure_bottom_wall_width])
        cylinder(d=cap_fan_d, h=kv260_enclosure_h+2*kv260_enclosure_bottom_wall_width);
      
      // CAM screws
      if(draw_other_enclosures) {
        %translate([kv260_enclosure_l-stereocam_w/2, stereocam_l/2+kv260_enclosure_w/2+2*kv260_enclosure_wall_width, -stereocam_riser_h-kv260_enclosure_bottom_wall_width/2])
          rotate([-90, 0, -90])
            hbv_1780_2_stereocam_enclosure(draw_as_close_box=true);
      }
      translate([kv260_enclosure_l-stereocam_w/2-2*kv260_enclosure_wall_width-stereocam_wall_width+0.5, stereocam_l/_t_riser_cols+_riser_col_width-1.1, 0])
        for(xy = stereocam_screws_z) {
            translate([xy[1], xy[0], 0])
              cylinder(h=4*kv260_enclosure_bottom_wall_width, d=xy_screw_3mm_d, $fn=50, center=true);
        }
      
      // Motors Driver screws
      if(draw_other_enclosures) {
        %translate([kv260_enclosure_l-stereocam_l+19.1, stereocam_w+15.9, kv260_enclosure_bottom_wall_width/2])
          rotate([180, 0, 0])
            zk5ad_enclosure(draw_as_close_box=true);
      }
      translate([kv260_enclosure_l-stereocam_w+5, 5, 0])
        rotate([0, 0, 90])
          for(xy = zk5ad_screws_xy) {
            translate([xy[1], xy[0], 0])
              cylinder(h=4*kv260_enclosure_bottom_wall_width, d=xy_screw_3mm_d, $fn=50, center=true);
          }
          
      // Cable holders
      xy_cable_holders = [
        4.5,
        [
          [97, 80],
          [107, 80],
          [50, 110],
          [50, 100],
        ]
      ];
      for(xy = xy_cable_holders[1]) {
        translate([xy[0], xy[1], 0])
          cylinder(h=3*kv260_enclosure_wall_width, d=xy_cable_holders[0], $fn=50, center=true);
      }
    }
  }
}

*difference() {
  *KV260_enclosure(draw_as_close_box=true, draw_other_enclosures=true);
  *KV260_enclosure(draw_lid=true, draw_container=false);
  *KV260_enclosure(draw_lid=true, draw_container=true);
  KV260_enclosure(draw_lid=false, draw_container=true);
  *translate([kv260_enclosure_l/2, -10, -10])
    cube(500);
}
