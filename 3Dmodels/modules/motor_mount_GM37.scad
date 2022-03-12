//include<alu_channel.scad>
use <../ext_modules/threads.scad>

module motor_mount_GM37_simple(
  // Enclosure type
  enclose_gear_only=false,
  full_enclosure=0,
  max_enclosure_length=37,
  full_support=true,
  motor_connections_offset=15,
  // From slicer settings, set widths as:
  base_height=4,
  enclosure_wall_width=4,
  full_enclosure_wall_width=2,
  // Rendering options
  render_mount=true,
  render_motor=false,
  // Test options
  half=false,
  // 3D-print adjust options
  vertical_print=false,
  tolerance = 0.5
){
  $fn=50;
  
  gear_diameter = 37;
  gear_length = 24;
  body_diameter = 37.5;
  body_length = 57;
  intake_distance = 39;
  
  shaft_base_diameter = 12+tolerance;
  shaft_base_length = 6;
  shaft_diameter = 6;
  shaft_length = 15;
  shaft_position_offset = 7;
  
  total_screws = 6;
  screw_diameters = 3+tolerance;  // M3
  screw_position_offset = gear_diameter/2-3;
  screw_length = shaft_base_length;
  
  base_calc_height = 40;
  
  gear_case_width = 3.5;  // gear case wall width + internal plate width -> This + enclosure_wall_width will set the max. allowed screw length when assembling
  internal_plate_width = 1.5;
  enclosure_cap_length = 10;
  
  min_allowed_screw_length = enclosure_wall_width + gear_case_width;
  echo(min_allowed_screw_length=min_allowed_screw_length);
  max_allowed_screw_length = enclosure_wall_width + gear_case_width + internal_plate_width;
  echo(max_allowed_screw_length=max_allowed_screw_length);
  
  // calc values
  base_overhang = 20;
  base_screw_inset_distance = base_overhang/3;
  base_length = gear_length + body_length + tolerance;
  max_base_length = (max_enclosure_length && base_length>max_enclosure_length)?(max_enclosure_length):(base_length);
  enclosure_diameter = gear_diameter + 2*enclosure_wall_width;
  motor_length = gear_length+body_length;
  full_enclosure_length = motor_length + motor_connections_offset;
  base_width = enclosure_diameter + 2*base_overhang;
  
  cap_diameter = enclosure_diameter+4*full_enclosure_wall_width+tolerance;
  cap_srew = enclosure_diameter+2*full_enclosure_wall_width+tolerance;

  
  vertical_rotation = (vertical_print)?(90):(0);
  side_rotation = 0;
  
  module gm37_motor() {
    // Based on lukas@chihaimotor.cn
    $fn = 17;
    cube_adj = 0.4*body_diameter+tolerance;
    translate([0, 0, body_length]) {
      // gear
      cylinder(d=gear_diameter+tolerance,h=gear_length);
      translate([-15, 0, 0])
        rotate([0, 0, 45])
          translate([-cube_adj/2, -cube_adj/2, -body_length])
            cube([cube_adj, cube_adj, gear_length+body_length]);
      // body
      translate([0, 0, -body_length+tolerance])
        cylinder(d=body_diameter+tolerance, h=body_length);
      // shaft
      translate([shaft_position_offset, 0, gear_length]) {
        cylinder(d=shaft_base_diameter, h=shaft_base_length);
        cylinder(d=shaft_diameter, h=shaft_length);
      }
      // screws
      translate([0, 0, gear_length]) {
        for(i=[1:total_screws]) {
          rotate([0, 0, 30+i*360/total_screws])
            translate([screw_position_offset, 0, 0])
              cylinder(d=screw_diameters, h=screw_length);
        }
      }
    }
  }
  
  // --------------------------------------------------------------------------------------------------
  module motor_base(
    render_base=render_mount,
    render_gm37_motor=render_mount,
    render_buttress=render_mount
  )
  {
    // base
    if(render_base) {
      cube([base_width, max_base_length, base_height]);
      translate([base_width/2-enclosure_diameter/2, 0, 0])
        cube([enclosure_diameter, max_base_length, enclosure_diameter/2]);
    }
    
    // motor enclosure
    if(render_gm37_motor) {
      translate([base_width/2, 0, enclosure_diameter/2])
        rotate([-90,0,0]) {
          difference() {
            cylinder(d=enclosure_diameter, h=max_base_length);
            if(enclose_gear_only) {
              translate([-enclosure_diameter, -2*enclosure_diameter, gear_length])
                cube([2*enclosure_diameter, 2*enclosure_diameter, 2*body_length]);
            }
          }
          // full enclosure
          if(full_support || full_enclosure) {
            full_enclosure_base_width = 26;
            difference() {
              union() {
                h = (full_enclosure)?(full_enclosure_length):(motor_length);
                difference() {
                  cylinder(d=enclosure_diameter, h=h);
                  if(!full_enclosure) {
                   translate([-enclosure_diameter, -1.75*enclosure_diameter, gear_length])
                      cube([2*enclosure_diameter, 2*enclosure_diameter, 2*body_length]);
                  }
                }
                // extra base
                if(vertical_print==false)
                  translate([-full_enclosure_base_width/2, enclosure_diameter/2-base_height, 0])
                    cube([full_enclosure_base_width, base_height, h]);
              }
              cylinder(d=enclosure_diameter-2*full_enclosure_wall_width, h=1.2*full_enclosure_length);
            }
          }
        }
    }
  
    if(render_buttress) {
      poly_points_front = [
        [-base_width/2, 0],
        [-enclosure_diameter/2, enclosure_diameter/2 - base_height],
        [ enclosure_diameter/2, enclosure_diameter/2 - base_height],
        [ base_width/2,0]
      ];
      poly_points_rear = [
        [-0.60*base_width/2, 0],
        [-enclosure_diameter/3, enclosure_diameter/3 - base_height],
        [ enclosure_diameter/3, enclosure_diameter/3 - base_height],
        [ 0.6*base_width/2,0]
      ];
      // Front Buttress
      translate([base_width/2,0,base_height]) {
        rotate([-90,180,0]) {
          linear_extrude(height=enclosure_wall_width)  
            polygon(points=poly_points_front);
        }
      }
    
      // Rear buttress
      translate([base_width/2,max_base_length,base_height]) {
        rotate([90,0,0]) {
          linear_extrude(height=enclosure_wall_width) {
            if(vertical_print==true)
              polygon(points=poly_points_rear);
            else
              polygon(points=poly_points_front);
          }
        }
      }
    }
  }
  
  rotate([vertical_rotation, side_rotation, 0]) {
    difference() {
      union() {
        motor_base();
        if(render_motor) {
          color("blue")
          translate([base_width/2, gear_length+body_length+base_height, enclosure_diameter/2])
            rotate([90,90,0])
              gm37_motor();
        }
      }
      // carve motor
      translate([base_width/2, gear_length+body_length+base_height, enclosure_diameter/2])
        rotate([90,90,0])
          gm37_motor();
      
      if(half) {
        translate([-10, -10, gear_diameter/2])
          cube([base_width+20, full_enclosure_length+enclosure_cap_length+20, max_base_length]);
      }
    }
  }
}
