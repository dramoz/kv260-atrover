//include<alu_channel.scad>
use<lawntina_alu_supports.scad>
use <../modules/threads.scad>
use <../modules/grid.scad>

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
  $fn=100;
  
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
    translate([0, 0, body_length]) {
      // gear
      cylinder(d=gear_diameter+tolerance,h=gear_length);
      // boy
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

module motor_mount_GM37(
  // Enclosure type
  enclose_gear_only=false,
  full_enclosure=true,
  motor_connections_offset=20,
  cap_grid=true,
  // From slicer settings, set widths as:
  base_height=4,
  enclosure_wall_width=4,
  full_enclosure_wall_width=2,
  enclosure_cap_slot_heigth = 1,
  enclosure_cap_slot_depth = 1,
  // Rendering options
  render_mount=true,
  render_alu_frame_connectors=0,
  render_cap=false,
  render_motor=false,
  // Test options
  fit_check_front=false,
  fit_check_back=false,
  half=false,
  // 3D-print adjust options
  vertical_print=true,
  tolerance = 0.5
){
  $fn=100;
  
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
  
  base_screw_drill = 5;
  base_screw_washer_diameter = 12.8+tolerance;
  base_screw_washer_height = 1.6;
  base_calc_height = 40;
  
  gear_case_width = 3.5;  // gear case wall width + internal plate width -> This + enclosure_wall_width will set the max. allowed screw length when assembling
  internal_plate_width = 1.5;
  enclosure_cap_length = 10;
  
  min_allowed_screw_length = enclosure_wall_width + gear_case_width;
  echo(min_allowed_screw_length=min_allowed_screw_length);
  max_allowed_screw_length = enclosure_wall_width + gear_case_width + internal_plate_width;
  echo(max_allowed_screw_length=max_allowed_screw_length);
  
  // calc values
  base_overhang = 2*base_screw_washer_diameter;
  base_screw_inset_distance = base_overhang/3;
  base_length = gear_length + body_length + tolerance;
  enclosure_diameter = gear_diameter + 2*enclosure_wall_width;
  motor_length = gear_length+body_length;
  full_enclosure_length = motor_length + motor_connections_offset;
  base_width = enclosure_diameter + 2*base_overhang;
  
  cap_diameter = enclosure_diameter+4*full_enclosure_wall_width+tolerance;
  cap_srew = enclosure_diameter+2*full_enclosure_wall_width+tolerance;

  
  vertical_rotation = (
    (vertical_print && render_alu_frame_connectors!=-1) || (render_alu_frame_connectors>1 && render_mount==false)
  )?
    (90)
   :
    ((render_alu_frame_connectors==-1)?(180):(0))
  ;
  side_rotation = (render_alu_frame_connectors==1 && render_mount==false)?(90):(0);
  
  module gm37_motor() {
    // Based on lukas@chihaimotor.cn
    translate([0, 0, body_length]) {
      // gear
      cylinder(d=gear_diameter+tolerance,h=gear_length);
      // boy
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
      cube([base_width, base_length, base_height]);
      translate([base_width/2-enclosure_diameter/2, 0, 0])
        cube([enclosure_diameter, base_length, enclosure_diameter/2]);
    }
    
    // Alu frame supports
    if(render_alu_frame_connectors) {
      color("silver", alpha=0.5) {
        // front
        if(render_alu_frame_connectors==1 || render_alu_frame_connectors==-1)
          rotate([180, 0, 0])
            rotate([0, 0, 90])
              translate([-alu_ch_width/2-alu_wall_width, -base_width/2, 0])
                alu_frame_connector(base_width, screw_diameter=0);
        // side right
        if(render_alu_frame_connectors==2 || render_alu_frame_connectors==-1)
          translate([body_length, body_length+tolerance, 0])
            rotate([0, 0, 180])
              rotate([180, 0, 0])
                alu_frame_cap(gear_length);
        //side left
        if(render_alu_frame_connectors==3 || render_alu_frame_connectors==-1)
          translate([base_width, body_length+tolerance, 0])
            rotate([0, 0, 180])
              rotate([180, 0, 0])
                alu_frame_cap(gear_length);
      }
    }
    
    // motor enclosure
    if(render_gm37_motor) {
      translate([base_width/2, 0, enclosure_diameter/2])
        rotate([-90,0,0]) {
          difference() {
            cylinder(d=enclosure_diameter, h=base_length);
            if(enclose_gear_only) {
              translate([-enclosure_diameter, -2*enclosure_diameter, gear_length])
                cube([2*enclosure_diameter, 2*enclosure_diameter, 2*body_length]);
            }
          }
          // full enclosure
          if(full_enclosure) {
            cap_pos = full_enclosure_length - (motor_length+2*full_enclosure_wall_width+2*tolerance);
            echo(cap_pos=cap_pos);
            full_enclosure_base_width = 26;
            difference() {
              union() {
                cylinder(d=enclosure_diameter, h=full_enclosure_length);
                // extra base
                if(vertical_print==false)
                  translate([-full_enclosure_base_width/2, enclosure_diameter/2-base_height, 0])
                    cube([full_enclosure_base_width, base_height, full_enclosure_length-cap_pos]);
                // cap ring slot
                translate([0, 0, full_enclosure_length+full_enclosure_wall_width+tolerance/2])
                  rotate([180, 0, 0,]){
                    thread_for_screw(diameter=cap_srew, length=enclosure_cap_length);
                  }
              }
              cylinder(d=enclosure_diameter-2*full_enclosure_wall_width, h=1.2*full_enclosure_length);
            }
          }
        }
    }
    if(render_cap) {
      translate_me = (render_gm37_motor)?(1):(0);
      rotate_me = (render_gm37_motor)?(-90):(90);
      translate([translate_me*base_width/2, 0, translate_me*enclosure_diameter/2])
        rotate([rotate_me, 0, 0]) {
          //color("black", alpha=0.4)
            translate([0, 0, translate_me*full_enclosure_length+2*full_enclosure_wall_width+0.1])
              rotate([180, 0, 0,]){
                difference() {
                  //cap
                  union() {
                    translate([0, 0, full_enclosure_wall_width])
                      cylinder(d=cap_diameter, h=enclosure_cap_length);
                    difference() {
                      cylinder(d=cap_diameter, h=full_enclosure_wall_width);
                      translate([0, 0, -1])
                        cylinder(d=cap_diameter-full_enclosure_wall_width, h=2+full_enclosure_wall_width);
                    }
                    if(cap_grid) {
                      xy_factor = 1.5; //sqrt(2);
                      xy_size = cap_diameter/xy_factor;
                      xy_separation = xy_factor;
                      grid_radius = 1;
                      difference() {
                        cylinder(d=cap_diameter, h=enclosure_cap_length+full_enclosure_wall_width);
                        translate([0, 0, -full_enclosure_wall_width])
                        difference() {
                          //grid_rectangles(wall_width=full_enclosure_wall_width, x_size=cap_diameter, y_size=cap_diameter, rect_xlen=4, rect_ylen=4, separation=1.1);
                          cylinder(d=cap_diameter, h=2*full_enclosure_wall_width);
                          translate([0, 0, -5])
                            grid_cylinders(wall_width=10+2*full_enclosure_wall_width, x_size=xy_size, y_size=xy_size, shape=6, rotation=0, x_separation=xy_separation, y_separation=xy_separation, radius=grid_radius);
                          difference() {
                            cube(2*xy_size, center=true);
                            cube(  xy_size-tolerance, center=true);
                          }
                        }
                      }
                    }
                    else {
                      cylinder(d=cap_diameter, h=enclosure_cap_length+full_enclosure_wall_width);
                    }
                  }
                  translate([0, 0, full_enclosure_wall_width])
                    thread_for_nut(diameter=cap_srew, length=enclosure_cap_length);
                  // cable slot
                  translate([0, -0.42*enclosure_diameter, -full_enclosure_wall_width])
                    cylinder(d=5, h=3*full_enclosure_wall_width);
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
      translate([base_width/2,base_length,base_height]) {
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
  
  module base_screw() {
     translate([0, 0, -base_calc_height/2])
      cylinder(d=base_screw_drill, h=base_calc_height);
    translate([0, 0, base_height])
      cylinder(d=base_screw_washer_diameter, h=base_screw_washer_height);
  }   
  
  module base_screws_holes() {
    // Front left
    translate([base_width-base_screw_inset_distance, body_length/2,0])
      base_screw();
    translate([base_width-base_screw_inset_distance-base_screw_washer_diameter, body_length/2,0])
      base_screw();
    // Front right
    translate([base_screw_inset_distance, body_length/2,0])
      base_screw();
    translate([base_screw_inset_distance+base_screw_washer_diameter, body_length/2,0])
      base_screw();
    
    // side left
    translate([base_width-body_length/2, base_length-base_screw_washer_diameter/2-tolerance, 0])
      base_screw();
    translate([base_width-body_length/2, base_length-1.5*base_screw_washer_diameter-3*tolerance, 0])
      base_screw();
    
    // side right
    translate([body_length/2, base_length-base_screw_washer_diameter/2-tolerance, 0])
      base_screw();
    translate([body_length/2, base_length-1.5*base_screw_washer_diameter-3*tolerance, 0])
      base_screw();
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
      // drill holes for mounting
      base_screws_holes();
    
      // Fit check
      // Front mount (+screws) and rear fit
      if(fit_check_front) {
        translate([-base_width/2, alu_ch_width-alu_ch_thickness-alu_wall_width/2, -base_height])
          cube([2*base_width, full_enclosure_length, 2*body_diameter]);
      }
      if(fit_check_back) {
        translate([-base_width/2, -enclosure_wall_width, -base_height])
          cube([2*base_width, base_length, 2*body_diameter]);
        translate([-base_width/2, base_length+2*enclosure_wall_width, -2*base_height])
          cube([2*base_width, body_length, 2*body_diameter]);
      }
      if(half) {
        translate([-10, -10, gear_diameter/2])
          cube([base_width+20, full_enclosure_length+enclosure_cap_length+20, base_length]);
      }
    }
  }
}

motor_mount_GM37(
  // Enclosure type
  enclose_gear_only=false,
  full_enclosure=true,
  motor_connections_offset=20,
  cap_grid=true,
  // From slicer settings, set widths as:
  base_height=0.3+4*0.7,
  enclosure_wall_width=3.4,
  full_enclosure_wall_width=1.8,
  enclosure_cap_slot_heigth=0.7*2,
  enclosure_cap_slot_depth=1.8,
  // Rendering options
  render_mount=true,
  render_alu_frame_connectors=-1,
  render_cap=true,
  render_motor=false,
  // Test options
  fit_check_front=false,
  fit_check_back=false,
  half=false,
  // 3D-print adjust options
  vertical_print=true,
  tolerance = 0.5
);
