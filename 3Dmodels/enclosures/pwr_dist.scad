// ----------------------------------------------------------------------------------
// Print settings:
// - Infill: 15% (or less if bridges OK)
// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
use<../modules/enclosure_box.scad>
// ----------------------------------------------------------------------------------
// DIMENSIONS
// ------------------------------------------
pwrdst_bottom_width = z_dim_adj(0.8);
pwrdst_wall_width = ptr_2lines;

// ------------------------------------------
pwrdst_l = 62;
pwrdst_w = 42;
pwrdst_h = z_dim_adj(16);
pwrdst_board_bt_clearence = z_dim_adj(4);
pwrdst_lid_h = z_dim_adj(4);

// ------------------------------------------
pwrdst_screws_xy = [
  [            3*pwrdst_wall_width, 3*pwrdst_wall_width],
  [pwrdst_l - 1*pwrdst_wall_width, 3*pwrdst_wall_width],
  [            3*pwrdst_wall_width, pwrdst_w-1*pwrdst_wall_width],
  [pwrdst_l - 1*pwrdst_wall_width, pwrdst_w-1*pwrdst_wall_width]
];

// ------------------------------------------
module pwrdst_enclosure(
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
      enclosure_box(
        length=pwrdst_l, width=pwrdst_w, height=pwrdst_h, lid_height=pwrdst_lid_h,
        xy_wall_width=pwrdst_wall_width, z_wall_width=pwrdst_bottom_width,
        fitted_lid=fitted_lid, draw_container=true,
        xy_screws=[xy_screw_3mm_d, pwrdst_screws_xy],
        tolerance=ptr_tolerance
      );
      union() {
        // PWR Output
        translate([xy_dim_adj(4)+pwrdst_wall_width, pwrdst_w, pwrdst_bottom_width+pwrdst_board_bt_clearence])
          cube([xy_dim_adj(28), 3*pwrdst_wall_width, pwrdst_h+pwrdst_bottom_width]);
          
        // PWR input
        translate([xy_dim_adj(34)+pwrdst_wall_width, -pwrdst_wall_width, pwrdst_bottom_width+pwrdst_board_bt_clearence])
          cube([xy_dim_adj(21), 3*pwrdst_wall_width, pwrdst_h+pwrdst_bottom_width]);
      }
    }
  }
  
  if(draw_lid || draw_as_close_box) {
    rotate(enclosure_close_box_lid_rotate_ang(draw_as_close_box))
      translate(enclosure_close_box_lid_translate_xyz(draw_as_close_box=draw_as_close_box, length=pwrdst_l, width=pwrdst_w, height=pwrdst_h, xy_wall_width=pwrdst_wall_width, z_wall_width=pwrdst_bottom_width))
        difference() {
          enclosure_box(
              length=pwrdst_l, width=pwrdst_w, height=pwrdst_h, lid_height=pwrdst_lid_h,
              xy_wall_width=pwrdst_wall_width, z_wall_width=pwrdst_bottom_width,
              fitted_lid=fitted_lid, draw_lid=true,
              tolerance=ptr_tolerance
            );
        }
  }
}

*difference() {
  *pwrdst_enclosure(draw_as_close_box=true);
  pwrdst_enclosure(draw_lid=true, draw_container=true);
  *pwrdst_enclosure(draw_lid=false, draw_container=true);
  *translate([pwrdst_l/2, -10, -10])
    cube(500);
}
