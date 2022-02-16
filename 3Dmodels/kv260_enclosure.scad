first_layer_height = 0.4;
layer_height = 0.6;

bottom_width = first_layer_height + 2*layer_height;
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

box_l = 139;
box_w = 119;
box_h = 36;
box_bt_h = 6;
cap_h = 8;

box_l_adj = xy_dim_adj(box_l);
box_w_adj = xy_dim_adj(box_w);
box_h_adj = z_dim_adj(box_h);
box_bt_h_adj = z_dim_adj(box_bt_h);
cap_h_adj = z_dim_adj(cap_h);

screws_hd = 5.55;
screws_hh = 2.38;
screws_hd_offset = first_layer_height;
screws_d = 3;
screws_xy = [
  [            3*wall_width, 3*wall_width],
  [box_l_adj - 1*wall_width, 3*wall_width],
  [            3*wall_width, box_w_adj-1*wall_width],
  [box_l_adj - 1*wall_width, box_w_adj-1*wall_width]
];

screws_hd_adj = xy_dim_adj(screws_hd);
screws_d_adj = xy_dim_adj(screws_d);

difference() {
  cube([box_l_adj+2*wall_width, box_w_adj+2*wall_width, box_h_adj+bottom_width]);
  union() {
    translate([wall_width, wall_width, bottom_width])
      cube([box_l_adj, box_w_adj, box_h_adj+bottom_width]);
    
    translate([xy_dim_adj(12)+wall_width, -wall_width, bottom_width+box_bt_h_adj])
      cube([xy_dim_adj(114.5), 3*wall_width, box_h_adj+bottom_width]);
      
    translate([xy_dim_adj(21)+wall_width, box_w_adj, bottom_width+box_bt_h_adj])
      cube([xy_dim_adj(14), 3*wall_width, z_dim_adj(2+2)]);
    translate([xy_dim_adj(80)+wall_width, box_w_adj, bottom_width+box_bt_h_adj])
      cube([xy_dim_adj(8), 3*wall_width, z_dim_adj(3+2)]);
    translate([xy_dim_adj(97)+wall_width, box_w_adj, bottom_width+box_bt_h_adj])
      cube([xy_dim_adj(15), 3*wall_width, z_dim_adj(5+2)]);
    
    
    for(xy = screws_xy) {
      translate([xy[0], xy[1], screws_hd_offset])
        cylinder(h=bottom_width, d=screws_hd_adj, $fn=50, center=false);
      translate([xy[0], xy[1], 0])
        cylinder(h=3*bottom_width, d=screws_d_adj, $fn=50, center=true);
    }
  }
}

// cap
translate([0, -box_w_adj-4*wall_width, 0])
difference() {
  translate([-wall_width, -wall_width, 0])
    cube([box_l_adj+4*wall_width, box_w_adj+4*wall_width, cap_h_adj+bottom_width]);
  translate([0, 0, bottom_width])
    cube([box_l_adj+2*wall_width, box_w_adj+2*wall_width, cap_h_adj+2*bottom_width]);
}
