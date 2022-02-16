first_layer_height = 0.4;
layer_height = 0.6;

bottom_width = first_layer_height + 2*layer_height;
top_width = 2*layer_height;
wall_width = 1.67;

function xy_dim_adj(x) = ceil(x/wall_width)*wall_width;
function  z_dim_adj(z) = ceil(z/layer_height)*layer_height;

box_l = 71;
box_w = 51;
box_h = 16;
box_bt_h = 6;
cap_h = 4;

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
    
    translate([xy_dim_adj(17)+wall_width, box_w_adj, bottom_width+box_bt_h_adj])
      cube([xy_dim_adj(26), 3*wall_width, box_h_adj+bottom_width]);
    translate([xy_dim_adj(27)+wall_width, -wall_width, bottom_width+box_bt_h_adj])
      cube([xy_dim_adj(26), 3*wall_width, box_h_adj+bottom_width]);
      
    translate([-wall_width, xy_dim_adj(21)+wall_width,, bottom_width+box_bt_h_adj])
      cube([3*wall_width, xy_dim_adj(10), box_h_adj+bottom_width]);
    
    for(xy = screws_xy) {
      translate([xy[0], xy[1], screws_hd_offset])
        cylinder(h=bottom_width, d=screws_hd_adj, $fn=50, center=false);
      translate([xy[0], xy[1], 0])
        cylinder(h=3*bottom_width, d=screws_d_adj, $fn=50, center=true);
    }
  }
}

// cap
*translate([-box_l_adj-4*wall_width, 0, 0])
difference() {
  translate([-wall_width, -wall_width, 0])
    cube([box_l_adj+4*wall_width, box_w_adj+4*wall_width, cap_h_adj+bottom_width]);
  translate([0, 0, bottom_width])
    cube([box_l_adj+2*wall_width, box_w_adj+2*wall_width, cap_h_adj+2*bottom_width]);
}
