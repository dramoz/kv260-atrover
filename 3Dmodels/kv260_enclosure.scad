first_layer_height = 0.4;
layer_height = 0.6;

bottom_width = first_layer_height + 3*layer_height;
top_width = 2*layer_height;
// lines: width (mm)
// 2: 1.67
// 3: 2.44
// 4: 3.21
// 5: 3.98
// 6: 4.76
wall_width = 2.44;

function xy_dim_adj(x) = ceil(x/wall_width)*wall_width;
function  z_dim_adj(z) = ceil(z/layer_height)*layer_height;

box_l = 140;
box_w = 120;
box_h = 36;
box_bt_h = 6;
cap_h = 12;

box_l_adj = xy_dim_adj(box_l);
box_w_adj = xy_dim_adj(box_w);
box_h_adj = z_dim_adj(box_h);
box_bt_h_adj = z_dim_adj(box_bt_h);
cap_h_adj = z_dim_adj(cap_h);

screws_hd = 5.55;
screws_hh = 2.38;
screws_hd_offset = first_layer_height+1*layer_height;
screws_d = 3;
screws_wall_offset_cnt = 10;
screws_xy = [
  [                screws_wall_offset_cnt*wall_width,               screws_wall_offset_cnt*wall_width],
  [box_l_adj - (screws_wall_offset_cnt/2)*wall_width,               screws_wall_offset_cnt*wall_width],
  [                screws_wall_offset_cnt*wall_width, box_w_adj-(screws_wall_offset_cnt/2)*wall_width],
  [box_l_adj - (screws_wall_offset_cnt/2)*wall_width, box_w_adj-(screws_wall_offset_cnt/2)*wall_width]
];

screws_hd_adj = xy_dim_adj(screws_hd);
screws_d_adj = xy_dim_adj(screws_d);

*difference() {
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
