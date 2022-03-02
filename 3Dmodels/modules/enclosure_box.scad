include<printer_limits.scad>

function xy_dim_adj(x) = ceil(x/ptr_wall_width)*ptr_wall_width;
function enclosure_close_box_lid_rotate_ang(draw_as_close_box=false) =
  (draw_as_close_box) ?
    ([0, 180, 0])
  : ([0, 0, 0]);
                                                                                   
function enclosure_close_box_lid_translate_xyz(draw_as_close_box=false, length=50, width=40, height=15, xy_wall_width=ptr_wall_width, z_wall_width=ptr_bottom_wall_width, tolerance=ptr_tolerance) =
  (draw_as_close_box) ?
    ([-length-2*xy_wall_width, 0, -2*z_wall_width-height-tolerance])
  : ([0, -width-4*xy_wall_width, 0]);

module enclosure_box(
  length=50,
  width=40,
  height=15,
  lid_height=5,
  xy_wall_width=ptr_wall_width,
  z_wall_width=ptr_bottom_wall_width,
  fitted_lid=true,
  draw_lid=false,
  draw_container=false,
  xy_screws=false,
  tolerance=0.0
)
{
  echo("+Enclosure box");
  
  // Bottom
  if(draw_container) {
    difference() {
      cube([length+2*xy_wall_width, width+2*xy_wall_width, height+z_wall_width]);
      union() {
        translate([xy_wall_width, xy_wall_width, z_wall_width])
          cube([length, width, height+z_wall_width]);
          
        for(xy = xy_screws[1]) {
          translate([xy[0], xy[1], 0])
            cylinder(h=3*xy_wall_width, d=xy_screws[0], $fn=50, center=true);
        }
      }
    }
  }
  
  // Lid
  if(draw_lid) {
    difference() {
      if(fitted_lid) {
        cube([length+2*xy_wall_width, width+2*xy_wall_width, lid_height+z_wall_width]);
      }
      else {
        translate([-xy_wall_width, -xy_wall_width, 0])
          cube([length+4*xy_wall_width, width+4*xy_wall_width, lid_height+z_wall_width]);
      }
      
      if(fitted_lid) {
        difference() {
          translate([-xy_wall_width, -xy_wall_width, z_wall_width])
            cube([length+4*xy_wall_width, width+4*xy_wall_width, lid_height+2*z_wall_width]);
          translate([xy_wall_width, xy_wall_width, z_wall_width])
            cube([length, width, height+z_wall_width]);
      }
      translate([2*xy_wall_width, 2*xy_wall_width, z_wall_width])
        cube([length-2*xy_wall_width, width-2*xy_wall_width, height+z_wall_width]);
      }
      else {
        translate([0, 0, z_wall_width])
          cube([length+2*xy_wall_width, width+2*xy_wall_width, lid_height+2*z_wall_width]);
      }
    }
  }
}

if(true) {
  enclosure_box(draw_container=true);
  rotate(enclosure_close_box_lid_rotate_ang(false))
    translate(enclosure_close_box_lid_translate_xyz(false))
      enclosure_box(draw_lid=true, fitted_lid=true);
}
