// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
// ----------------------------------------------------------------------------------
// DIMENSIONS
kv260_enclosure_l = 140+1.5;
kv260_enclosure_w = 120+2;
  
// z plane
kv260_enclosure_h = z_dim_adj(36);
kv260_enclosure_bt_h = z_dim_adj(6);
kv260_enclosure_lid_h = z_dim_adj(12);

kv260_enclosure_wall_width = ptr_wall_width;
kv260_enclosure_bottom_wall_width = ptr_bottom_wall_width;

_kv260_encl_screws_x_wall_offset_cnt = 20;
_kv260_encl_screws_y_wall_offset_cnt = 10;
kv260_enclosure_screws_xy = [
  [                _kv260_encl_screws_x_wall_offset_cnt*kv260_enclosure_wall_width,               _kv260_encl_screws_y_wall_offset_cnt*kv260_enclosure_wall_width],
  [kv260_enclosure_l - (_kv260_encl_screws_x_wall_offset_cnt/2)*kv260_enclosure_wall_width,               _kv260_encl_screws_y_wall_offset_cnt*kv260_enclosure_wall_width],
  [                _kv260_encl_screws_x_wall_offset_cnt*kv260_enclosure_wall_width, kv260_enclosure_w-(_kv260_encl_screws_y_wall_offset_cnt/2)*kv260_enclosure_wall_width],
  [kv260_enclosure_l - (_kv260_encl_screws_x_wall_offset_cnt/2)*kv260_enclosure_wall_width, kv260_enclosure_w-(_kv260_encl_screws_y_wall_offset_cnt/2)*kv260_enclosure_wall_width]
];

module KV260_enclosure(
  draw_top=false,
  draw_bottom=false,
  draw_as_close_box=false
)
{
  echo("----------------------------------------------------------------------------------------------------------------------------------------------------");
  echo("KV260 Enclosure");
  
  screws_hd = 5.55;
  screws_hh = 2.38;
  screws_hd_offset = first_layer_height+1*layer_height;
  screws_d = 3;
  
  screws_hd_adj = xy_dim_adj(screws_hd);
  screws_d_adj = xy_dim_adj(screws_d);
  
  if(draw_bottom || draw_as_close_box ) {
    difference() {
      cube([kv260_enclosure_l+2*kv260_enclosure_wall_width, kv260_enclosure_w+2*kv260_enclosure_wall_width, kv260_enclosure_h+kv260_enclosure_bottom_wall_width]);
      union() {
        translate([kv260_enclosure_wall_width, kv260_enclosure_wall_width, kv260_enclosure_bottom_wall_width])
          cube([kv260_enclosure_l, kv260_enclosure_w, kv260_enclosure_h+kv260_enclosure_bottom_wall_width]);
        
        translate([xy_dim_adj(12)+kv260_enclosure_wall_width, -kv260_enclosure_wall_width, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([xy_dim_adj(118), 3*kv260_enclosure_wall_width, kv260_enclosure_h+kv260_enclosure_bottom_wall_width]);
          
        translate([xy_dim_adj(22)+kv260_enclosure_wall_width, kv260_enclosure_w, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([xy_dim_adj(14), 3*kv260_enclosure_wall_width, z_dim_adj(2+2)]);
        translate([xy_dim_adj(80)+kv260_enclosure_wall_width, kv260_enclosure_w, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([xy_dim_adj(10), 3*kv260_enclosure_wall_width, z_dim_adj(3+2)]);
        translate([xy_dim_adj(98)+kv260_enclosure_wall_width, kv260_enclosure_w, kv260_enclosure_bottom_wall_width+kv260_enclosure_bt_h])
          cube([xy_dim_adj(18), 3*kv260_enclosure_wall_width, z_dim_adj(5+2)]);
        
        for(xy = kv260_enclosure_screws_xy) {
          translate([xy[0], xy[1], screws_hd_offset])
            cylinder(h=kv260_enclosure_bottom_wall_width, d=screws_hd_adj, $fn=50, center=false);
          translate([xy[0], xy[1], 0])
            cylinder(h=3*kv260_enclosure_bottom_wall_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
    }
  }
  if(draw_top || draw_as_close_box) {
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
    
    rotate_ang = (draw_as_close_box) ? ([0, 180, 0]) : ([0, 0, 0]);
    translate_xzy = (draw_as_close_box) ? ([-kv260_enclosure_l-2*kv260_enclosure_wall_width, 0, -2*kv260_enclosure_bottom_wall_width-kv260_enclosure_h-ptr_tolerance]) : ([0, -kv260_enclosure_w-4*kv260_enclosure_wall_width, 0]);
    rotate(rotate_ang)
    translate(translate_xzy)
    difference() {
      translate([-kv260_enclosure_wall_width, -kv260_enclosure_wall_width, 0])
        cube([kv260_enclosure_l+4*kv260_enclosure_wall_width, kv260_enclosure_w+4*kv260_enclosure_wall_width, kv260_enclosure_lid_h+kv260_enclosure_bottom_wall_width]);
      translate([0, 0, kv260_enclosure_bottom_wall_width])
        cube([kv260_enclosure_l+2*kv260_enclosure_wall_width, kv260_enclosure_w+2*kv260_enclosure_wall_width, kv260_enclosure_lid_h+2*kv260_enclosure_bottom_wall_width]);
      translate([cap_fan_x_offset, cap_fan_y_offset, -kv260_enclosure_bottom_wall_width])
        cylinder(d=cap_fan_d, h=kv260_enclosure_h+2*kv260_enclosure_bottom_wall_width);
      
      // CAM screws
      translate([125, 20, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[1]-3, xy[0], 0])
              cylinder(h=4*kv260_enclosure_bottom_wall_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
      
      // CAM screws
      *translate([32, 5, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[0], xy[1]-3, 0])
              cylinder(h=4*kv260_enclosure_bottom_wall_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
      *translate([32, 100, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[0], xy[1]-3, 0])
              cylinder(h=4*kv260_enclosure_bottom_wall_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
      *translate([0, 20, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[1]-3, xy[0], 0])
              cylinder(h=4*kv260_enclosure_bottom_wall_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
    }
  }
}

difference() {
  //KV260_enclosure(draw_as_close_box=true);
  KV260_enclosure(draw_top=true, draw_bottom=false);
  *translate([kv260_enclosure_l/2, -10, -10])
    cube(500);
}
