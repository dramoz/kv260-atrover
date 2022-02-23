// KV260-ATRover
// (mini version for testing)
// Units 1:1mm

// ----------------------------------------------------------------------------------
use<./modules/wheel.scad>
use<./modules/motor_mount_GM37.scad>
use<./modules/caster.scad>
// ----------------------------------------------------------------------------------
include<kv260_atrover_mini_dims.scad>
// ----------------------------------------------------------------------------------
module rear_motors_wheels(
  wheel_diameter=195,
  wheel_width=15,
  tread_depth=10,
  wheel_thickness=10,
  total_treads=360/15,
  spokes=360/45,
  wheels=false,
  motor=false,
  draft=false,
  wall_width=2,
  tolerance=0.35
) {
  gear_length = 24;
  body_length = 57;
  motor_length = gear_length + body_length;
  color("green", alpha=0.4)
    rotate([180,0,0])
      rotate([0, 0, 90])
        difference() {
          motor_mount_GM37_simple(
            base_height=2,
            max_enclosure_length=(base_width-motor_length)/3,
            enclose_gear_only=false,
            full_enclosure=0,
            full_support=false,
            full_enclosure_wall_width=wall_width,
            render_motor=motor,
            enclosure_wall_width=4
          );
          *translate([192, 0, 0])
            cube(300, center=true);
        }
  // wheels
  if(wheels) {
    color("gray", alpha=0.25)
      translate([0, -wheel_diameter/2-tread_depth, -15.5])
        rotate([0, 90, 0])
          wheel(
            wheel_diameter = wheel_diameter - 2*tread_depth,
            wheel_width = wheel_width,
            wheel_thickness = wheel_thickness,
            
            tread_depth = tread_depth,
            tread_tickness = wheel_thickness,
            total_treads = total_treads,

            spokes = spokes,
            dshaft = true, shaft_dshaft_inset = 0,
            setscrew_nut_at_shaft = true,
            setscrew_allan_key_hole = 2.5 + tolerance,
            hub_setscrews = 1,
            draft=draft,
            tolerance = tolerance
          );
  }
}
// ----------------------------------------------------------------------------------
module kv260_atrover_mini(
  wheel_diameter=195,
  wheel_width=15,
  mower_height=30,
  flipped=false,
  draw_wheels=false,
  draw_motors=false,
  blades=true,
  draft=false,
  wall_width=2,
  tolerance=0.5
 )
 {
  rod_width = 15;
  caster_bearing_diameter = rod_width*2/sqrt(2);
  caster_bearing_radius_ext = caster_bearing_diameter-1.5*wall_width;
  echo(caster_bearing_radius_ext=caster_bearing_radius_ext);
  battery_enclosure_motor_mount_offset = base_width/2-battery_width -45.1/2 -21;
  
  // Mower/Blade enclosures
  motor_enclosure_diameter = 44.6 + tolerance;
  enclosure_depth = wheel_diameter/2;
  bottom_rear_front_distance = 85;
  front_mower_space = base_width-5.5*caster_bearing_radius_ext;
  
  // holding screws
  mounting_screw_diameter = 4 + tolerance;
  mounting_screw_inset = (flipped)?(2.5):(2);
  mounting_screw_inset_diameter = 7.4 + tolerance;
  mounting_screws = [
    // [x, y, d]
    // rear motors enclosure
    [50, 38],
    [-50, 38],
    [35, 40+58],
    [-35, 40+58],
    // mower motor top enclosure
    [0, -0],
    [0, -70],
    [35, -35],
    [-35, -35],
    // lateral grass router
    [base_width/2-10, 0],
    [-base_width/2+10, 0],
    [base_width/2-10, -30],
    [-base_width/2+10, -30],
    // battery
    [-battery_width/2, 0],
    [+battery_width/2, 0],
    [-base_width/2+20, base_length/2-10],
    [base_width/2-20, base_length/2-10],
    // circuit board
    [-48, -base_length/2+5],
    [+48, -base_length/2+5],
    [-48, -base_length/2+35],
    [+48, -base_length/2+35],
  ];
  
  // cables_holes
  cables_holes = [
    // rear motors
    [base_width/2-20, 35, 10]
  ];
  difference() {
    union() {
      // base
      color("orange", alpha=0.3)
        difference() {
          translate([0,0,base_wall_width/2])
            cube([base_width, base_length, base_wall_width], center=true);
          // Caster bearings
          for(m=[0:1]) {
            mirror([m,0,0]) {
              translate([-base_width/2+caster_bearing_radius_ext+wall_width/2, -base_length/2+caster_bearing_radius_ext+wall_width/2, -base_wall_width]) {
                cylinder(r=caster_bearing_radius_ext, h = 3*base_wall_width);
                translate([0, 0, -caster_bearing_radius_ext/2+base_wall_width])
                  rotate([0, 0, 180])
                    difference() {
                      cube(caster_bearing_radius_ext+wall_width);
                      translate([0, 0, -caster_bearing_radius_ext])
                        cylinder(r=caster_bearing_radius_ext+wall_width/2, h = 3*caster_bearing_radius_ext);
                    }
              }
            }
          }
        }
      // Rear motors support
      for(m=[0:1]) {
        mirror([m,0,0])
          translate([base_width/2+0, base_length/2, wall_width])
              rear_motors_wheels(
                wheel_diameter=wheel_diameter,
                wheel_width=wheel_width,
                tread_depth=2.5,
                wheel_thickness=5,
                wheels=draw_wheels,
                motor=draw_motors,
                total_treads=360/8,
                spokes=360/60,
                draft=draft,
                tolerance=0.3
              );
      }
      
      // front casters
      color("green", alpha=0.15) {
        for(m=[0:1]) {
          mirror([m,0,0])
            translate([-base_width/2+caster_bearing_radius_ext+wall_width/2, -base_length/2+caster_bearing_radius_ext+wall_width/2, base_wall_width])
              rotate([0, 0, -m*0])
                difference() {
                  full_caster(
                    back_wheel_diameter=80,
                    back_wheel_offset=21,
                    bearing_diameter=caster_bearing_diameter,
                    bearing_width=15,
                    wheel_width=5,
                    wheel_spokes=360/60,
                    wheel_tread_depth=2,
                    wheel_thickness=4,
                    wheel_total_treads = 360/15,
                    oring_width = 0,
                    bearing=true,
                    l_wheel=draw_wheels,
                    r_wheel=draw_wheels,
                    wheels_screw=false,
                    rod_length = 30,
                    rod_screw_offset=4,
                    rod_width=rod_width,
                    rod_screw_diameter=10,
                    bearing_tolerance=0.5,  // TODO: test me!
                    draft=false,
                    tolerance=0.2
                  );
                  *translate([50, 0, 0])
                    cube(100, center=true);
              }
        }
      }
      
      vaccum_offset = -20;
      vaccum_d = 140;
      difference() {
        union() {
          // circumference
          translate([0, vaccum_offset, -enclosure_depth])
            cylinder(d=vaccum_d+2*wall_width, h=enclosure_depth);
            
          // squares
          translate([0, -bottom_rear_front_distance/2+25, -enclosure_depth/2])
            cube([base_width, bottom_rear_front_distance, enclosure_depth], center=true);
          translate([0, -bottom_rear_front_distance, -enclosure_depth/2])
            cube([front_mower_space, 60, enclosure_depth], center=true);
        }
        
        // circumference
        translate([0, vaccum_offset, -enclosure_depth-0.01])
          cylinder(d=vaccum_d, h=1.2*enclosure_depth);
        // squares
        translate([0, -bottom_rear_front_distance/2+25, -enclosure_depth/2 -0.01])
          cube([1.2*base_width, bottom_rear_front_distance-2*wall_width, 1.2*enclosure_depth], center=true);
        translate([0, -bottom_rear_front_distance, -enclosure_depth/2 -0.01])
          cube([front_mower_space-2*wall_width, 100, 1.2*enclosure_depth], center=true);
        translate([0, -base_length/2-10, -enclosure_depth/2 -0.01])
          cube([base_width, 20, 1.2*enclosure_depth], center=true);
      }
      
      // battery supports
      *translate([0, base_length/2-2*mounting_screw_diameter+wall_width/2, -1.5*mounting_screw_diameter])
        rotate([90, 0, 0])
          difference() {
            cube([4*mounting_screw_diameter, 3*mounting_screw_diameter, 12+3+1], center=true);
            cylinder(d=mounting_screw_diameter, h=20, center=true);
          }
    }
    
  }
}

// ----------------------------------------------------------------------------------
$fn = 50;
wheel_diameter = 80;
wheel_width = 12;
wheel_offset = 40;
wall_width = 2;
draft_guides = false;
rotate_model = !draft_guides;

difference() {
  union() {
    rotate_angle = (rotate_model)?(180):(0);
    flipped = rotate_model;
    rotate([0, rotate_angle, 0])
      kv260_atrover_mini(
        wheel_diameter=wheel_diameter,
        wheel_width=wheel_width,
        mower_height=10,
        flipped=flipped,
        draw_wheels=draft_guides,
        draw_motors=draft_guides,
        blades=draft_guides,
        wall_width=wall_width,
        draft=false
      );

  // --------------------------------------------------
  if(draft_guides) {
    color("black", alpha=0.25)
      union() {
        // Battery
        translate([-battery_length/2, base_width/2-battery_width, 0])
          cube([battery_length, battery_width, batter_height]);
        
        // caster radius
        caster_bearing_diameter = 18.25;
        translate([-base_width/2+caster_bearing_diameter+wall_width/2, -base_length/2+caster_bearing_diameter+wall_width/2, -wheel_diameter])
          cylinder(d=3*caster_bearing_diameter, h=wheel_diameter);
          
        // ------------------------------------------------------------
        // Draw helpers
        ground_offset = 15.5 + wheel_diameter/2;
        translate_orientation = (rotate_model)?(1):(-1);
        
        // wheel plane
        translate([0, 0, ground_offset*translate_orientation])
          cube([2*base_width, 2*base_length, 4], center=true);
        }
    }
  }
  *translate([-500, 0, 0])
    cube(1000, center=true);
}
