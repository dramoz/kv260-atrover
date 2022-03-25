// ----------------------------------------------------------------------------------
// Print settings:
// - Infill: 15% (or less if bridges OK)
// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
use<../modules/enclosure_box.scad>
// ----------------------------------------------------------------------------------
// DIMENSIONS
zk5ad_wall_width = ptr_wall_width;
zk5ad_bottom_wall_width = z_dim_adj(2);

zk5ad_screws_hide_offset = z_dim_adj(xy_screw_3mm_hd_h + 3);

zk5ad_l = 39;
zk5ad_w = 28.5;
zk5ad_h = z_dim_adj(22 + zk5ad_screws_hide_offset) ;
zk5ad_board_bt_clearence = z_dim_adj(4 + zk5ad_screws_hide_offset);
zk5ad_lid_h = z_dim_adj(6);

// ------------------------------------------
// Screws
zk5ad_screws_xy = [
  [            3*zk5ad_wall_width, 3*zk5ad_wall_width],
  [zk5ad_l - 1*zk5ad_wall_width, 3*zk5ad_wall_width],
  [            3*zk5ad_wall_width, zk5ad_w-1*zk5ad_wall_width],
  [zk5ad_l - 1*zk5ad_wall_width, zk5ad_w-1*zk5ad_wall_width]
];

module zk5ad_enclosure(
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
        length=zk5ad_l, width=zk5ad_w, height=zk5ad_h, lid_height=zk5ad_lid_h,
        xy_wall_width=zk5ad_wall_width, z_wall_width=zk5ad_bottom_wall_width,
        fitted_lid=fitted_lid, draw_container=true,
        xy_screws=[xy_screw_3mm_d, zk5ad_screws_xy],
        xy_screws_hide=[xy_screw_3mm_hd_d, zk5ad_screws_hide_offset],
        tolerance=ptr_tolerance
      );
      translate([1+zk5ad_wall_width, -zk5ad_wall_width, zk5ad_bottom_wall_width+zk5ad_board_bt_clearence])
        cube([36, 3*zk5ad_wall_width, zk5ad_h+zk5ad_bottom_wall_width]);
    }
  }
  if(draw_lid || draw_as_close_box) {
    rotate(enclosure_close_box_lid_rotate_ang(draw_as_close_box))
      translate(enclosure_close_box_lid_translate_xyz(draw_as_close_box=draw_as_close_box, length=zk5ad_l, width=zk5ad_w, height=zk5ad_h, xy_wall_width=zk5ad_wall_width, z_wall_width=zk5ad_bottom_wall_width))
        difference() {
          enclosure_box(
            length=zk5ad_l, width=zk5ad_w, height=zk5ad_h, lid_height=zk5ad_lid_h,
            xy_wall_width=zk5ad_wall_width, z_wall_width=zk5ad_bottom_wall_width,
            fitted_lid=fitted_lid, draw_lid=true,
            tolerance=ptr_tolerance
          );
          // IO socket
          //translate([2*zk5ad_wall_width, 1*zk5ad_wall_width-0.01, -2*zk5ad_bottom_wall_width])
          translate([zk5ad_l+0*zk5ad_wall_width-16, zk5ad_w-2*zk5ad_wall_width+0.01, -2*zk5ad_bottom_wall_width])
            cube([16, 3*zk5ad_wall_width+0.01, zk5ad_h+zk5ad_bottom_wall_width]);
        }
      }
}

difference() {
  *zk5ad_enclosure(draw_as_close_box=true);
  *zk5ad_enclosure(draw_lid=true, draw_container=true);
  zk5ad_enclosure(draw_container=true);
  *translate([zk5ad_enclosure_l/2, -10, -10])
    cube(500);
}
