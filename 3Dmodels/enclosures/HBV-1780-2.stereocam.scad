// ----------------------------------------------------------------------------------
// Print settings:
// - Infill: 15% (or less if bridges OK)
// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
use<../modules/enclosure_box.scad>
// ----------------------------------------------------------------------------------
// DIMENSIONS
stereocam_bottom_width = z_dim_adj(0.8);
stereocam_wall_width = ptr_2lines;

stereocam_riser = true;
stereocam_riser_h = z_dim_adj(30);

stereocam_l = 80.5;
stereocam_w = 22.5;
stereocam_h = z_dim_adj(12);
stereocam_board_bt_clearance = z_dim_adj(2.60);
stereocam_lid_h = z_dim_adj(6);

// -> Enable for a high-res printing ONLY
// !!! untested after latest adjustments
stereo_cam_print_posts = false;
_post_height = z_dim_adj(stereocam_board_bt_clearance+2);
_post_diameter = xy_dim_adj(2);
_post_wall_offset = stereocam_wall_width+_post_diameter/2+1;
_post_xy = [
  [                             _post_wall_offset,                              _post_wall_offset],
  [stereocam_l+2*stereocam_wall_width - _post_wall_offset,                              _post_wall_offset],
  [                             _post_wall_offset, stereocam_w+2*stereocam_wall_width - _post_wall_offset],
  [stereocam_l+2*stereocam_wall_width - _post_wall_offset, stereocam_w+2*stereocam_wall_width - _post_wall_offset]
];

// ------------------------------------------
_riser_col_width = 10;
_t_riser_cols = 6;
_x_offset = stereocam_l/_t_riser_cols;
_micro_usb_slot = 9;

// ------------------------------------------
// Screws
_stereocam_screws_offset = 3*stereocam_l/(2*_t_riser_cols);
stereocam_screws_z_offset = z_dim_adj(stereocam_h/2);
stereocam_screws_z = [
    [ stereocam_wall_width+_stereocam_screws_offset, 13],
    [ stereocam_l+stereocam_wall_width-_stereocam_screws_offset, 13],
];

module hbv_1780_2_stereocam_enclosure(
  fitted_lid=true,
  draw_lid=false,
  draw_container=false,
  draw_as_close_box=false
)
{
  echo("----------------------------------------------------------------------------------------------------------------------------------------------------");
  echo("HBV-1780-2 Stereo camera Enclosure");
  if(draw_container || draw_as_close_box ) {
    difference() {
      union() {
        difference() {
          enclosure_box(
            length=stereocam_l, width=stereocam_w, height=stereocam_h, lid_height=stereocam_lid_h,
            xy_wall_width=stereocam_wall_width, z_wall_width=stereocam_bottom_width,
            fitted_lid=fitted_lid, draw_container=true,
            tolerance=ptr_tolerance
          );
          union() {
            // usb hole
            translate([stereocam_l/2-_micro_usb_slot/2+stereocam_wall_width, -stereocam_wall_width, stereocam_bottom_width+stereocam_board_bt_clearance])
              cube([_micro_usb_slot, 3*stereocam_wall_width, stereocam_h+stereocam_bottom_width]);
            
            // lateral screws holes
            if(!stereocam_riser) {
              for(xy = stereocam_screws_z) {
                rotate([90, 0, 0])
                  translate([xy[0], xy[1], -stereocam_w-stereocam_wall_width])
                    cylinder(h=4*stereocam_bottom_width, d=z_screw_3mm_d, $fn=50, center=true);
              }
            }
          }
        }
        // board posts
        if(stereo_cam_print_posts) {
          for(xy = _post_xy) {
            translate([xy[0], xy[1], stereocam_bottom_width])
              cylinder(h=_post_height, d=_post_diameter, $fn=50, center=false);
          }
        }
        // support
        if(stereocam_riser) {
          translate([0, -(stereocam_riser_h+1*stereocam_wall_width), 0])
            difference() {
              cube([stereocam_l+2*stereocam_wall_width, stereocam_riser_h+2*stereocam_wall_width, stereocam_h+stereocam_bottom_width]);
              union() {
                for(x=[0:(_t_riser_cols-1)]) {
                  translate([x*_x_offset+_riser_col_width/_t_riser_cols+stereocam_wall_width, stereocam_wall_width, -stereocam_bottom_width])
                    cube([_riser_col_width, stereocam_riser_h, stereocam_h+3*stereocam_bottom_width]);
                }
                translate([stereocam_l/2-_micro_usb_slot+stereocam_wall_width, stereocam_wall_width, -stereocam_bottom_width])
                  cube([2*_micro_usb_slot, stereocam_riser_h, stereocam_h+3*stereocam_bottom_width]);
                  
                // usb hole
                translate([stereocam_l/2-_micro_usb_slot/2+stereocam_wall_width, stereocam_riser_h, stereocam_bottom_width+stereocam_board_bt_clearance])
                  cube([_micro_usb_slot, 3*stereocam_wall_width, stereocam_h+stereocam_bottom_width]);
                  
                // lateral screws holes
                for(xy = stereocam_screws_z) {
                  rotate([90, 0, 0])
                    translate([xy[0], xy[1]-stereocam_screws_z_offset, 0])
                      cylinder(h=4*stereocam_bottom_width, d=z_screw_3mm_d, $fn=50, center=true);
                }
              }
            }
        }
      }
    }
  }
  if(draw_lid || draw_as_close_box) {
    // Lenses
    lens_d = 15;
    lens_offset_from_wall = 4.5;
    cap_w = (stereocam_riser) ? (stereocam_w+stereocam_riser_h)+stereocam_wall_width : (stereocam_w);
    riser_trans = (stereocam_riser && !draw_as_close_box) ? (stereocam_riser_h) : (0);
    rotate(enclosure_close_box_lid_rotate_ang(draw_as_close_box))
      translate(enclosure_close_box_lid_translate_xyz(draw_as_close_box=draw_as_close_box, length=stereocam_l, width=stereocam_w, height=stereocam_h, xy_wall_width=stereocam_wall_width, z_wall_width=stereocam_bottom_width))
      translate([0, -riser_trans, 1])
        difference() {
          enclosure_box(
              length=stereocam_l, width=stereocam_w, height=stereocam_h, lid_height=stereocam_lid_h,
              xy_wall_width=stereocam_wall_width, z_wall_width=stereocam_bottom_width,
              fitted_lid=fitted_lid, draw_lid=true,
              tolerance=ptr_tolerance
            );
          
          if(stereocam_riser && !fitted_lid) {
            translate([0, 0, stereocam_bottom_width])
              cube([stereocam_l+2*stereocam_wall_width, cap_w+2*stereocam_wall_width, stereocam_lid_h+2*stereocam_bottom_width]);
          }
          
          // Lens holes
          translate([lens_offset_from_wall+lens_d/2, (stereocam_w+2*stereocam_wall_width)/2, -stereocam_bottom_width])
            cylinder(h=4*stereocam_wall_width, d=lens_d);
          translate([stereocam_l+2*stereocam_wall_width-lens_d/2-lens_offset_from_wall, (stereocam_w+2*stereocam_wall_width)/2, -stereocam_bottom_width])
            cylinder(h=4*stereocam_wall_width, d=lens_d);
        }
  }
}

*hbv_1780_2_stereocam_enclosure(
  fitted_lid=true,
  draw_lid=true,
  draw_container=true,
  draw_as_close_box=false
);
