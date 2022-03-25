// ----------------------------------------------------------------------------------
// Print settings:
// - Infill: 15% (or less if bridges OK)
// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
use<../modules/enclosure_box.scad>
// ----------------------------------------------------------------------------------
// DIMENSIONS
ttgo_wall_width = ptr_wall_width;
ttgo_bottom_wall_width = z_dim_adj(2+xy_screw_3mm_hd_h);

ttgo_l = 46.2;
ttgo_w = 34.5;
ttgo_h = z_dim_adj(10) ;
ttgo_board_bt_clearence = z_dim_adj(1);

// ------------------------------------------
// Screws
ttgo_screws_xy = [
  [            3*ttgo_wall_width, 3*ttgo_wall_width],
  [ttgo_l - 1*ttgo_wall_width, 3*ttgo_wall_width],
  [            3*ttgo_wall_width, ttgo_w-1*ttgo_wall_width],
  [ttgo_l - 1*ttgo_wall_width, ttgo_w-1*ttgo_wall_width]
];

module ttgo_enclosure(
  fitted_lid=true,
  draw_lid=false,
  draw_container=false,
  draw_as_close_box=false
)
{
  echo("----------------------------------------------------------------------------------------------------------------------------------------------------");
  echo("ZK-5AD Dual DC-motor H-Bridge Enclosure");
  if(draw_container || draw_as_close_box ) {
    difference() {
      enclosure_box(
        length=ttgo_l, width=ttgo_w, height=ttgo_h, lid_height=0,
        xy_wall_width=ttgo_wall_width, z_wall_width=ttgo_bottom_wall_width,
        fitted_lid=fitted_lid, draw_container=true,
        xy_screws=[xy_screw_3mm_d, ttgo_screws_xy],
        xy_screws_hide=[xy_screw_3mm_hd_d, xy_screw_3mm_hd_h],
        tolerance=ptr_tolerance
      );
      //translate([1+ttgo_wall_width, -ttgo_wall_width, ttgo_bottom_wall_width+ttgo_board_bt_clearence])
      //  cube([36, 3*ttgo_wall_width, ttgo_h+ttgo_bottom_wall_width]);
    }
  }
}

difference() {
  *ttgo_enclosure(draw_as_close_box=true);
  *ttgo_enclosure(draw_lid=true, draw_container=true);
  ttgo_enclosure(draw_container=true);
  *translate([ttgo_enclosure_l/2, -10, -10])
    cube(500);
}
