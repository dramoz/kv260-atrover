first_layer_height = 0.2;
layer_height = 0.2;

bottom_width = z_dim_adj(2-first_layer_height);
top_width = z_dim_adj(2);
wall_width = 0.4;

function xy_dim_adj(x) = ceil(x/wall_width)*wall_width;
function  z_dim_adj(z) = ceil(z/layer_height)*layer_height;

box_l = 80.5;
box_w = 22.5;
box_h = 24-4;
box_bt_h = 1.55+1.05;
cap_h = 4;
box_wall_width = xy_dim_adj(2);

extra_support = true;
support_h = z_dim_adj(30);

box_l_adj = xy_dim_adj(box_l);
box_w_adj = xy_dim_adj(box_w);
box_h_adj = z_dim_adj(box_h);
box_bt_h_adj = z_dim_adj(box_bt_h);
cap_h_adj = z_dim_adj(cap_h);

screws_hh = 2.38;
screws_d = 3;
screws_xy = [
  [ 25, 13],
  [ 60, 13],
];

screws_d_adj = xy_dim_adj(screws_d);

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
        
      // usb hole
      translate([xy_dim_adj(box_l_adj/2-4)+box_wall_width, -box_wall_width, bottom_width+box_bt_h_adj])
        cube([xy_dim_adj(8), 3*box_wall_width, box_h_adj+bottom_width]);
        
      // lateral screws holes
      for(xy = screws_xy) {
        rotate([90, 0, 0])
          translate([xy[0], xy[1], -box_w_adj-6*wall_width])
            cylinder(h=4*bottom_width, d=screws_d_adj, $fn=50, center=true);
      }
    }
  }
  // board posts
  for(xy = post_xy) {
    translate([xy[0], xy[1], bottom_width])
      cylinder(h=post_height, d=post_diameter, $fn=50, center=false);
  }
  
  // support
  if(extra_support) {
    translate([0, -(support_h+1*box_wall_width), 0])
      difference() {
        cube([box_l_adj+2*box_wall_width, support_h+2*box_wall_width, box_h_adj+bottom_width]);
        union() {
          translate([box_wall_width+15, box_wall_width, -bottom_width])
            cube([50, support_h, box_h_adj+3*bottom_width]);
          // usb hole
          translate([xy_dim_adj(box_l_adj/2-4)+box_wall_width, support_h, bottom_width+box_bt_h_adj])
            cube([xy_dim_adj(8), 3*box_wall_width, box_h_adj+bottom_width]);
            
          // lateral screws holes
          for(xy = screws_xy) {
            rotate([90, 0, 0])
              translate([xy[0], xy[1]-3, 0])
                cylinder(h=4*bottom_width, d=screws_d_adj, $fn=50, center=true);
          }
        }
      }
  }
}

// cap
lens_d = 15;
lens_offset_from_wall = 5;
cap_w = (extra_support) ? (box_w_adj+support_h)+box_wall_width : (box_w_adj);
translate([0, +box_w_adj+4*box_wall_width, 0])
difference() {
  translate([-box_wall_width, -box_wall_width, 0])
    cube([box_l_adj+4*box_wall_width, cap_w+4*box_wall_width, cap_h_adj+bottom_width]);
  
  if(extra_support) {
    translate([0, 0, bottom_width])
      cube([box_l_adj+2*box_wall_width, cap_w+2*box_wall_width, cap_h_adj+2*bottom_width]);
  }
  
  // Lens holes
  translate([lens_offset_from_wall+lens_d/2, (box_w_adj+2*box_wall_width)/2, -bottom_width])
    cylinder(h=4*box_wall_width, d=lens_d);
  translate([box_l_adj+2*box_wall_width-lens_d/2-lens_offset_from_wall, (box_w_adj+2*box_wall_width)/2, -bottom_width])
    cylinder(h=4*box_wall_width, d=lens_d);
}
