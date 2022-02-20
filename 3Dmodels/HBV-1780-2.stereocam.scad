first_layer_height = 0.2;
layer_height = 0.2;

bottom_width = z_dim_adj(2-first_layer_height);
top_width = z_dim_adj(2);
wall_width = 0.4;

function xy_dim_adj(x) = ceil(x/wall_width)*wall_width;
function  z_dim_adj(z) = ceil(z/layer_height)*layer_height;

box_l = 80;
box_w = 22;
box_h = 24-4;
box_bt_h = 1.55+1.05;
cap_h = 4;
box_wall_width = xy_dim_adj(2);

box_l_adj = xy_dim_adj(box_l);
box_w_adj = xy_dim_adj(box_w);
box_h_adj = z_dim_adj(box_h);
box_bt_h_adj = z_dim_adj(box_bt_h);
cap_h_adj = z_dim_adj(cap_h);

post_height = z_dim_adj(box_bt_h+2);
post_diameter = xy_dim_adj(2);
post_wall_offset = box_wall_width+post_diameter/2+1;
post_xy = [
  [                             post_wall_offset,                              post_wall_offset],
  [box_l_adj+2*box_wall_width - post_wall_offset,                              post_wall_offset],
  [                             post_wall_offset, box_w_adj+2*box_wall_width - post_wall_offset],
  [box_l_adj+2*box_wall_width - post_wall_offset, box_w_adj+2*box_wall_width - post_wall_offset]
];

union() {
  difference() {
    cube([box_l_adj+2*box_wall_width, box_w_adj+2*box_wall_width, box_h_adj+bottom_width]);
    union() {
      translate([box_wall_width, box_wall_width, bottom_width])
        cube([box_l_adj, box_w_adj, box_h_adj+bottom_width]);
        
      translate([xy_dim_adj(box_l_adj/2-4)+box_wall_width, -box_wall_width, bottom_width+box_bt_h_adj])
        cube([xy_dim_adj(8), 3*box_wall_width, z_dim_adj(3)+bottom_width]);
      
    }
  }
  for(xy = post_xy) {
    translate([xy[0], xy[1], bottom_width])
      cylinder(h=post_height, d=post_diameter, $fn=50, center=false);
  }
}

// cap
translate([0, -box_w_adj-4*box_wall_width, 0])
difference() {
  translate([-box_wall_width, -box_wall_width, 0])
    cube([box_l_adj+4*box_wall_width, box_w_adj+4*box_wall_width, cap_h_adj+bottom_width]);
  translate([0, 0, bottom_width])
    cube([box_l_adj+2*box_wall_width, box_w_adj+2*box_wall_width, cap_h_adj+2*bottom_width]);
}
