// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
// ----------------------------------------------------------------------------------
function KV260_enclosure_dims() = [
  140, // box_l
  120, // box_w
   36, // box_h
    6, // box_bt_h
   12, // cap_h
];

module KV260_enclosure(
  draw_top=true,
  draw_bottom=true,
  wall_width=ptr_wall_width
)
{
  dims = KV260_enclosure_dims();
  box_l = dims[0];
  box_w = dims[1];
  box_h = dims[2];
  box_bt_h = dims[3];
  cap_h = dims[4];
  
  box_l_adj = xy_dim_adj(box_l);
  box_w_adj = xy_dim_adj(box_w);
  box_h_adj = z_dim_adj(box_h);
  box_bt_h_adj = z_dim_adj(box_bt_h);
  cap_h_adj = z_dim_adj(cap_h);

  screws_hd = 5.55;
  screws_hh = 2.38;
  screws_hd_offset = first_layer_height+1*layer_height;
  screws_d = 3;
  screws_x_wall_offset_cnt = 20;
  screws_y_wall_offset_cnt = 10;
  screws_xy = [
    [                screws_x_wall_offset_cnt*wall_width,               screws_y_wall_offset_cnt*wall_width],
    [box_l_adj - (screws_x_wall_offset_cnt/2)*wall_width,               screws_y_wall_offset_cnt*wall_width],
    [                screws_x_wall_offset_cnt*wall_width, box_w_adj-(screws_y_wall_offset_cnt/2)*wall_width],
    [box_l_adj - (screws_x_wall_offset_cnt/2)*wall_width, box_w_adj-(screws_y_wall_offset_cnt/2)*wall_width]
  ];
  echo(screws_xy=screws_xy);
  
  screws_hd_adj = xy_dim_adj(screws_hd);
  screws_d_adj = xy_dim_adj(screws_d);
  
  if(draw_bottom) {
    difference() {
      cube([box_l_adj+2*wall_width, box_w_adj+2*wall_width, box_h_adj+bottom_width]);
      union() {
        translate([wall_width, wall_width, bottom_width])
          cube([box_l_adj, box_w_adj, box_h_adj+bottom_width]);
        
        translate([xy_dim_adj(12)+wall_width, -wall_width, bottom_width+box_bt_h_adj])
          cube([xy_dim_adj(118), 3*wall_width, box_h_adj+bottom_width]);
          
        translate([xy_dim_adj(22)+wall_width, box_w_adj, bottom_width+box_bt_h_adj])
          cube([xy_dim_adj(14), 3*wall_width, z_dim_adj(2+2)]);
        translate([xy_dim_adj(80)+wall_width, box_w_adj, bottom_width+box_bt_h_adj])
          cube([xy_dim_adj(10), 3*wall_width, z_dim_adj(3+2)]);
        translate([xy_dim_adj(98)+wall_width, box_w_adj, bottom_width+box_bt_h_adj])
          cube([xy_dim_adj(18), 3*wall_width, z_dim_adj(5+2)]);
        
        for(xy = screws_xy) {
          translate([xy[0], xy[1], screws_hd_offset])
            cylinder(h=bottom_width, d=screws_hd_adj, $fn=50, center=false);
          translate([xy[0], xy[1], 0])
            cylinder(h=3*bottom_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
    }
  }
  if(draw_top) {
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
    translate([0, -box_w_adj-4*wall_width, 0])
    difference() {
      translate([-wall_width, -wall_width, 0])
        cube([box_l_adj+4*wall_width, box_w_adj+4*wall_width, cap_h_adj+bottom_width]);
      translate([0, 0, bottom_width])
        cube([box_l_adj+2*wall_width, box_w_adj+2*wall_width, cap_h_adj+2*bottom_width]);
      translate([cap_fan_x_offset, cap_fan_y_offset, -bottom_width])
        cylinder(d=cap_fan_d, h=box_h_adj+2*bottom_width);
        
      // CAM screws
      translate([32, 5, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[0], xy[1]-3, 0])
              cylinder(h=4*bottom_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
      translate([32, 100, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[0], xy[1]-3, 0])
              cylinder(h=4*bottom_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
      // DOF screws
      translate([125, 20, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[1]-3, xy[0], 0])
              cylinder(h=4*bottom_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
      translate([0, 20, 0]) {
        for(xy = cam_screws_xy) {
            translate([xy[1]-3, xy[0], 0])
              cylinder(h=4*bottom_width, d=screws_d_adj, $fn=50, center=true);
        }
      }
    }
  }
}

KV260_enclosure(draw_top=true, draw_bottom=true);
