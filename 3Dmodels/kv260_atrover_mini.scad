
// *********************************************************************************************
// KV260-ATRover
// (mini version for testing)
// Units 1:1mm
//
// TODO:
// +Ultrasonic sensor (front->kv260_enclosure)
// +IR floor sensor   (front_bottom->kv260_enclosure)
// -> CAM later
// + DOF (camera mount?)
// Cable holders/passthrough for dc motors
// ----------------------------------------------------------------------------------
include<./modules/printer_limits.scad>
// ----------------------------------------------------------------------------------
use<./modules/wheel.scad>
use<./modules/caster.scad>
// ----------------------------------------------------------------------------------
include<kv260_atrover_mini_dims.scad>
include<rear_motors_wheels.scad>
// *********************************************************************************************
// ----------------------------------------------------------------------------------
// Global Setup
// ----------------------------------------------------------------------------------
$fn = 50;
tolerance = 0.35;

wheel_diameter = 80;
wheel_width = 12;
wheel_offset = 40;
xy_wall_width = ptr_wall_width;
// ----------------------------------------------------------------------------------
// Drawing options
draw_base = true;
draw_motors_support = true;
draw_base_casters = true;
draw_battery_enclosure = false;

use_3dprint_casters = false;

// ---------------------------------------
draft_guides = false;
draft_wheels = false;
draft_motors = false;
draft_battery = false;
draft_kv260_enclosure = false;

// ---------------------------------------
perimeters_test = false;
dims_test = false;
bat_enclosure_slot_test_chk = false;
bat_enclosure_slot_test = false;
bat_enclosure_slide_test_chk = false;
bat_enclosure_slide_test = false;

full_caster_test = false;
bearing_caster_test = false;
caster_tolerance = 0.7;
_caster_rod_screw_offset = 5;
caster_bearing_tolerance = 1.0;

motor_enclosure_test = false;
motor_enclosure_tolerance = 0.35;

half_model = false;
// ---------------------------------------
_draw_base = (draw_base || bat_enclosure_slot_test_chk || bat_enclosure_slot_test) && !(bat_enclosure_slide_test_chk || bat_enclosure_slide_test);
_draw_motors_support = draw_motors_support && !(bat_enclosure_slide_test_chk || bat_enclosure_slide_test);
_draw_base_casters = draw_base_casters && !(bat_enclosure_slide_test_chk || bat_enclosure_slide_test);
_draw_battery_enclosure = (draw_battery_enclosure || bat_enclosure_slide_test_chk || bat_enclosure_slide_test) && !motor_enclosure_test && !(bat_enclosure_slot_test_chk || bat_enclosure_slot_test);
_half_model = half_model;
_bat_case_xy_wall_width = (_draw_battery_enclosure) ? (1.0*ptr_4lines) : (1.2*ptr_4lines);
_bat_case_z_tolerance = (_draw_battery_enclosure) ? (0) : (2);
_bat_case_z_wall_width = z_dim_adj(3);
_bat_enclosure_vertical_walls_trim_w = (_draw_battery_enclosure) ? (15) : (16);

_rotate_model = !(draft_guides || draft_wheels || draft_motors || _draw_battery_enclosure || draft_battery || draft_kv260_enclosure);

// *********************************************************************************************
// ----------------------------------------------------------------------------------
// KV260 enclosure
// ----------------------------------------------------------------------------------
include<./enclosures/KV260_enclosure.scad>
// from echo: screws_xy = [[43.92, 43.92], [119.56, 43.92], [43.92, 100.04], [119.56, 100.04]]
kv260_screws_xy = kv260_enclosure_screws_xy;
kv260_screws_d = 3.2;
kv260_x_trans = (kv260_enclosure_w+2*kv260_enclosure_wall_width)/2;
kv260_y_trans = -(kv260_enclosure_l+2*kv260_enclosure_wall_width);//base_length/2 - battery_width-kv260_enclosure_l;
kv260_z_trans = bottom_wall_width;
// *********************************************************************************************
// ----------------------------------------------------------------------------------
// Battery enclosure
// ----------------------------------------------------------------------------------
bat_screws_xy =  [[48.8, 24.4], [117.12, 24.4], [48.8, 109.8], [117.12, 109.8]];
bat_screws_d = 3.2;

// *********************************************************************************************
// ----------------------------------------------------------------------------------
// Base screws holes and others
// ----------------------------------------------------------------------------------
// holding screws
mounting_screws = [
  // [x, y, d]
  // DC motor cable
  [-base_width/2+28, -8, 8],
  [base_width/2-28, -8, 8],
];
// --------------------------------------------------
// Caster screws
_caster_offset = 12;
_caster_l = 38;
_caster_w = 32;
_caster_wheel_d = 41.3;
_caster_wheel_w = 25;
_caster_screws_corner_offset = ptr_6lines;
_base_front_left_corner = [-base_width/2+xy_screw_4mm_d/2+_caster_screws_corner_offset, -base_length/2+xy_screw_4mm_d/2+_caster_screws_corner_offset];
_base_front_right_corner = [base_width/2-xy_screw_4mm_d/2-_caster_screws_corner_offset, -base_length/2+xy_screw_4mm_d/2+_caster_screws_corner_offset];
_caster_l_screw_offset = 2*(2+4/2);
_caster_screws_l = _caster_l-_caster_l_screw_offset;
_caster_screws_w = _caster_w-_caster_l_screw_offset;
caster_screws = [  
  // Left caster
  [_base_front_left_corner[0]+0*_caster_screws_w, _base_front_left_corner[1]+0*_caster_screws_l, xy_screw_4mm_d],
  [_base_front_left_corner[0]+0*_caster_screws_w, _base_front_left_corner[1]+1*_caster_screws_l, xy_screw_4mm_d],
  [_base_front_left_corner[0]+1*_caster_screws_w, _base_front_left_corner[1]+0*_caster_screws_l, xy_screw_4mm_d],
  [_base_front_left_corner[0]+1*_caster_screws_w, _base_front_left_corner[1]+1*_caster_screws_l, xy_screw_4mm_d],
  
  // Right Caster
  [_base_front_right_corner[0]-0*_caster_screws_w, _base_front_right_corner[1]+0*_caster_screws_l, xy_screw_4mm_d],
  [_base_front_right_corner[0]-0*_caster_screws_w, _base_front_right_corner[1]+1*_caster_screws_l, xy_screw_4mm_d],
  [_base_front_right_corner[0]-1*_caster_screws_w, _base_front_right_corner[1]+0*_caster_screws_l, xy_screw_4mm_d],
  [_base_front_right_corner[0]-1*_caster_screws_w, _base_front_right_corner[1]+1*_caster_screws_l, xy_screw_4mm_d],
];
// --------------------------------------------------
// Rear Left mark
rear_left_mark = [
  [-base_width/2+14, base_length/2-10, xy_screw_3mm_d],
];
// --------------------------------------------------
atrover_passthough_holes = concat(mounting_screws, caster_screws, rear_left_mark);

// *********************************************************************************************
// ----------------------------------------------------------------------------------
module kv260_atrover_mini(
  wheel_diameter=195,
  wheel_width=15,
  mower_height=30,
  flipped=false,
  draw_wheels=false,
  draw_motors=false,
  draft=false,
  botttom_supports=false,
  tolerance=0.5
 )
 {
  // ----------------------------------------------------------------------------------
  rod_width = 15;
  caster_bearing_diameter = rod_width*2/sqrt(2);
  caster_bearing_radius_ext = caster_bearing_diameter-1.5*xy_wall_width;
  echo(caster_bearing_radius_ext=caster_bearing_radius_ext);
  battery_enclosure_motor_mount_offset = base_width/2-battery_width -45.1/2 -21;
  // ----------------------------------------------------------------------------------
  // Mower/Blade enclosures
  motor_enclosure_diameter = 44.6 + tolerance;
  enclosure_depth = wheel_diameter/2;
  bottom_rear_front_distance = 85;
  front_mower_space = base_width-5.5*caster_bearing_radius_ext;
  
  // ----------------------------------------------------------------------------------
  // Battery case
  bat_case_l = battery_length + 2*_bat_case_xy_wall_width;
  bat_case_w = battery_width  + 2*_bat_case_xy_wall_width;
  bat_case_h = battery_height + _bat_case_z_wall_width;
  bat_wall_supports_offset = 10;
  bat_wall_supports_lateral_offset = 10;
  bat_supports_offset = 10;
  bat_supports_xy_size = 25;
  bat_supports_z_size = bat_supports_offset+bottom_wall_width+_bat_case_z_tolerance;
  // --------------------------------------------------
  module battery_enclosure() {
    translate([-bat_case_l/2, base_length/2-bat_case_w+_bat_case_xy_wall_width, bottom_wall_width-bat_supports_offset-_bat_case_z_tolerance-_bat_case_z_wall_width])
    difference() {
      cube([bat_case_l, bat_case_w, bat_case_h+bat_supports_offset+_bat_case_z_wall_width]);
      translate([_bat_case_xy_wall_width, _bat_case_xy_wall_width, -_bat_case_z_wall_width])
        cube([battery_length, battery_width, battery_height+bat_supports_offset+2*_bat_case_z_wall_width]);
      
      _bat_top_w_offset = bat_case_w/2-1.5*bat_wall_supports_offset;
      _bat_top_l_offset = bat_case_l/2-1.5*bat_wall_supports_offset;
      for(xy_trans = [
        [bat_wall_supports_offset,     bat_wall_supports_offset],
        [bat_wall_supports_offset, bat_case_w-_bat_top_w_offset-bat_wall_supports_offset],
        [bat_case_l-_bat_top_l_offset-bat_wall_supports_offset,     bat_wall_supports_offset],
        [bat_case_l-_bat_top_l_offset-bat_wall_supports_offset, bat_case_w-_bat_top_w_offset-bat_wall_supports_offset],
      ])
      {
        xyz_trans = [xy_trans[0], xy_trans[1], bat_case_h+bat_supports_offset-_bat_case_z_wall_width];
        translate(xyz_trans)
          cube([_bat_top_l_offset, _bat_top_w_offset, 3*_bat_case_z_wall_width]);
      }
      
      l_chunk = bat_case_l - 2*_bat_enclosure_vertical_walls_trim_w;
      translate([_bat_enclosure_vertical_walls_trim_w, -_bat_case_xy_wall_width, -bat_wall_supports_lateral_offset])
        cube([l_chunk, 3*_bat_case_xy_wall_width, bat_case_h]);
      translate([_bat_enclosure_vertical_walls_trim_w, battery_width, -bat_wall_supports_lateral_offset])
        cube([l_chunk, 3*_bat_case_xy_wall_width, bat_case_h]);
      
      w_chunk = bat_case_w - 2*_bat_enclosure_vertical_walls_trim_w;
      translate([-_bat_case_xy_wall_width, _bat_enclosure_vertical_walls_trim_w, -bat_wall_supports_lateral_offset])
        cube([3*_bat_case_xy_wall_width, w_chunk, bat_case_h]);
      translate([battery_length, _bat_enclosure_vertical_walls_trim_w, -bat_wall_supports_lateral_offset])
        cube([3*_bat_case_xy_wall_width, w_chunk, bat_case_h]);
        
      // PWR terminals
      _bat_terminal_l = 14;
      _bat_terminal_w = 12;
      _bat_terminal_h = 10;
      translate([_bat_case_xy_wall_width+10, _bat_case_xy_wall_width+3, battery_height-_bat_terminal_h])
        cube([_bat_terminal_l, _bat_terminal_w, 3*_bat_terminal_h]);
      translate([_bat_case_xy_wall_width+10, bat_case_w-_bat_case_xy_wall_width-_bat_terminal_w-3, battery_height-_bat_terminal_h])
        cube([_bat_terminal_l, _bat_terminal_w, 3*_bat_terminal_h]);
    }
  }
  module battery_enclosure_supports() {
    for(xy_trans = [
      [-bat_case_l/2-1.8*xy_wall_width                    , base_length/2-bat_case_w-0.3*xy_wall_width, bat_supports_xy_size/2, bat_supports_xy_size/2],
      [bat_case_l/2-bat_supports_xy_size+1.9*xy_wall_width, base_length/2-bat_case_w-0.3*xy_wall_width, -xy_wall_width, bat_supports_xy_size/2],
      //[-bat_case_l/2-2*xy_wall_width                    , base_length/2-bat_supports_xy_size, bat_supports_xy_size/2, -xy_wall_width],
      //[bat_case_l/2-bat_supports_xy_size+2*xy_wall_width, base_length/2-bat_supports_xy_size, -xy_wall_width, -xy_wall_width],
    ])
    {
      xyz_trans = [xy_trans[0], xy_trans[1], -bat_supports_z_size+xy_wall_width];
      xyz_diff_trans = [xy_trans[2], xy_trans[3], -xy_wall_width];
      %translate(xyz_trans)
        difference() {
          cube([bat_supports_xy_size, bat_supports_xy_size, bat_supports_z_size+xy_wall_width]);
          translate(xyz_diff_trans)
            cube([bat_supports_xy_size/2+xy_wall_width, bat_supports_xy_size/2+xy_wall_width, bat_supports_z_size+3*xy_wall_width]);
        }
    }
  }
  module battery_enclosure_screws() {
    screws_xy = [
      [-bat_case_l/2+(bat_supports_xy_size/2+xy_wall_width)/2, -z_screw_3mm_d],
      [ bat_case_l/2-(bat_supports_xy_size/2+xy_wall_width)/2, -z_screw_3mm_d],
    ];
    screw_h = bat_supports_xy_size + 0*xy_wall_width;
    z = base_length/2;
    for(xy = screws_xy) {
      rotate([90, 0, 0])
        translate([xy[0], xy[1], -z])
          union() {
            cylinder(h=screw_h, d=z_screw_3mm_d, $fn=50, center=true);
            translate([0, -bat_supports_xy_size/2+z_screw_3mm_nut_d/2+2*tolerance, bat_supports_xy_size/4])
              cube([z_screw_3mm_nut_d, bat_supports_xy_size, z_screw_3mm_nut_h], center=true);
          }
    }
    for(xy = screws_xy) {
      rotate([90, 0, 0])
        translate([xy[0], xy[1], -10])
          union() {
            translate([0, 0, 12])
              cylinder(h=screw_h, d=z_screw_3mm_d, $fn=50, center=true);
            translate([0, -bat_supports_xy_size/2+z_screw_3mm_nut_d/2+2*tolerance, bat_supports_xy_size/4])
              cube([z_screw_3mm_nut_d, bat_supports_xy_size, z_screw_3mm_nut_h], center=true);
          }
    }
  }
  // ----------------------------------------------------------------------------------
  difference() {
    union() {
      if(_draw_base) {
        // base
        //color("orange", alpha=0.3)
          difference() {
            translate([0,0,bottom_wall_width/2])
              cube([base_width, base_length, bottom_wall_width], center=true);
            // Caster bearings
            if(use_3dprint_casters) {
              for(m=[0:1]) {
                mirror([m,0,0]) {
                  translate([-base_width/2+caster_bearing_radius_ext+xy_wall_width/2, -base_length/2+caster_bearing_radius_ext+xy_wall_width/2, -bottom_wall_width]) {
                    cylinder(r=caster_bearing_radius_ext, h = 3*bottom_wall_width);
                    translate([0, 0, -caster_bearing_radius_ext/2+bottom_wall_width])
                      rotate([0, 0, 180])
                        difference() {
                          cube(caster_bearing_radius_ext+xy_wall_width);
                          translate([0, 0, -caster_bearing_radius_ext])
                            cylinder(r=caster_bearing_radius_ext+xy_wall_width/2, h = 3*caster_bearing_radius_ext);
                        }
                  }
                }
              }
            }
            else {
              // Nothing to do here for regular casters
            }
          }
      }
      if(_draw_motors_support) {
        // Rear motors support
        for(m=[0:1]) {
          mirror([m,0,0])
            translate([base_width/2+0, base_length/2, xy_wall_width])
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
                  tolerance=motor_enclosure_tolerance
                );
        }
      }
      if(_draw_base_casters) {
        if(use_3dprint_casters) {
        // front casters
        //color("green", alpha=0.15)
          for(m=[0:1]) {
            mirror([m,0,0])
              translate([-base_width/2+caster_bearing_radius_ext+xy_wall_width/2, -base_length/2+caster_bearing_radius_ext+xy_wall_width/2, bottom_wall_width])
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
                      bearing=true,
                      l_wheel=draw_wheels,
                      r_wheel=draw_wheels,
                      wheels_screw=false,
                      rod_length = 30,
                      rod_screw_offset=_caster_rod_screw_offset,  // Manually adjust to proper display
                      rod_width=rod_width,
                      rod_screw_diameter=10,
                      bearing_tolerance=caster_bearing_tolerance,
                      draft=false,
                      wall_width=xy_wall_width_adj(2),
                      tolerance=caster_tolerance
                    );
                    *translate([50, 0, 0])
                      cube(100, center=true);
                }
          }
        }
        else {
          if(_caster_offset>0) {
            translate([base_width/2-_caster_w-_caster_screws_corner_offset, -base_length/2, -_caster_offset])
              cube([_caster_w+_caster_screws_corner_offset, _caster_l+_caster_screws_corner_offset, _caster_offset]);
              
            translate([-base_width/2, -base_length/2, -_caster_offset])
              cube([_caster_w+_caster_screws_corner_offset, _caster_l+_caster_screws_corner_offset, _caster_offset]);
          }
          color("gray", alpha=0.5)
          if(draw_wheels) {
            translate([base_width/2-_caster_wheel_w/2, -base_length/2+_caster_wheel_d/2, -_caster_wheel_d/2-_caster_offset])
              rotate([0, 90, 0])
                cylinder(d=_caster_wheel_d, h=_caster_wheel_w, center=true);
                
            translate([-base_width/2+_caster_wheel_w/2, -base_length/2+_caster_wheel_d/2, -_caster_wheel_d/2-_caster_offset])
              rotate([0, 90, 0])
                cylinder(d=_caster_wheel_d, h=_caster_wheel_w, center=true);
          }
        }
      }
      
      if(botttom_supports) {
        vaccum_offset = -20;
        vaccum_d = 140;
        difference() {
            union() {
            // circumference
            translate([0, vaccum_offset, -enclosure_depth])
                cylinder(d=vaccum_d+2*xy_wall_width, h=enclosure_depth);
                
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
            cube([1.2*base_width, bottom_rear_front_distance-2*xy_wall_width, 1.2*enclosure_depth], center=true);
            translate([0, -bottom_rear_front_distance, -enclosure_depth/2 -0.01])
            cube([front_mower_space-2*xy_wall_width, 100, 1.2*enclosure_depth], center=true);
            translate([0, -base_length/2-10, -enclosure_depth/2 -0.01])
            cube([base_width, 20, 1.2*enclosure_depth], center=true);
        }
      }
      
      if(_draw_battery_enclosure) {
        battery_enclosure();
        
        if(draft_battery) {
          %color("blue", alpha=0.1)
          translate([-bat_case_l/2+_bat_case_xy_wall_width, base_length/2-bat_case_w+2*_bat_case_xy_wall_width, bottom_wall_width])
            cube([battery_length, battery_width, battery_height]);
        }
      }
      // battery supports
      if(_draw_base) {
        battery_enclosure_supports();
      }
    }
    // ------------------------------------------------------------
    // Start diffs
    // ------------------------------------------------------------
    // KV260 screws
    translate([kv260_x_trans, kv260_y_trans, kv260_z_trans])
      rotate([0,0,90])
        for(xy = kv260_screws_xy) {
            translate([xy[0], xy[1], -bottom_wall_width])
              cylinder(h=xy_screw_3mm_d*bottom_wall_width, d=kv260_screws_d, $fn=50, center=true);
    }
    // ------------------------------------------------------------
    // Battery enclosure
    if(!_draw_battery_enclosure) {
      battery_enclosure();
    }
    battery_enclosure_screws();
    
    // Base holes
    for(xy = atrover_passthough_holes) {
      translate([xy[0], xy[1], -max_z])
        cylinder(h=2*max_z, d=xy[2], $fn=50);
    }
  }
}

// ----------------------------------------------------------------------------------
module draw_kv260_atrover_mini() {
  kv260_atrover_mini(
      wheel_diameter=wheel_diameter,
      wheel_width=wheel_width,
      mower_height=10,
      flipped=flipped,
      draw_wheels=draft_wheels,
      draw_motors=draft_motors,
      botttom_supports=false,
      draft=false
    );
}
rotate_angle = (_rotate_model)?(180):(0);
flipped = _rotate_model;
rotate([0, 0, 90])
difference() {
  union() {
    rotate([0, rotate_angle, 0])
      draw_kv260_atrover_mini();
      
    // --------------------------------------------------
    if(draft_kv260_enclosure) {
      // ------------------------------------------------------------
        color("blue", alpha=0.25)
        translate([kv260_x_trans, kv260_y_trans, kv260_z_trans])
          rotate([0,0,90])
            KV260_enclosure(draw_as_close_box=true, draw_other_enclosures=true);
    }
    // --------------------------------------------------
    if(draft_guides) {
      union() {
        // caster radius
        caster_bearing_diameter = 18.25;
        color("blue", alpha=0.15)
        translate([-base_width/2+caster_bearing_diameter+xy_wall_width/2, -base_length/2+caster_bearing_diameter+xy_wall_width/2, -wheel_diameter])
          cylinder(d=3*caster_bearing_diameter, h=wheel_diameter);
        
        // ------------------------------------------------------------
        // Draw helpers
        ground_offset = 15.5 + wheel_diameter/2;
        translate_orientation = (_rotate_model)?(1):(-1);
        
        // wheel plane
        color("black", alpha=0.25)
        translate([0, 0, ground_offset*translate_orientation])
          cube([2*base_width, 2*base_length, 4], center=true);
        }
    }
  }
  
  // *********************************************************************************************
  // Tests
  // *********************************************************************************************
  // ------------------------------------------------------------
  if(_half_model) {
    translate([-500, 0, 0])
      cube(1000, center=true);
  }
  // ------------------------------------------------------------
  if(perimeters_test) {
    translate([0,0,max_z/2-bottom_wall_width+first_layer_height])
      cube([1.2*base_width, 1.2*base_length, max_z], center=true);
    
    translate([0, 0, -1.5*bottom_wall_width])
      cube([base_width-ptr_2lines, base_length-ptr_2lines, 3*bottom_wall_width], center=true);
  }
  // ------------------------------------------------------------
  if(dims_test) {
    difference() {
      cube([2*base_width, 2*base_length, max_z], center=true);
      translate([0,0,-2*bottom_wall_width])
        cube([base_width, base_length, 45], center=true);
    }
  }
  // ------------------------------------------------------------
  if(full_caster_test || bearing_caster_test) {
    z_offset = (full_caster_test) ? (200) : (60);
    w_offset = (full_caster_test) ? ((use_3dprint_casters)?(50):(70-_caster_screws_corner_offset)) : (60);
    l_offset = (full_caster_test) ? ((use_3dprint_casters)?(55):(70-_caster_screws_corner_offset)) : (65);
    difference() {
      cube([2*base_width, 2*base_length, max_z], center=true);
      translate([base_width/2+w_offset,-base_length/2-l_offset,-2*bottom_wall_width])
        cube([base_width, base_length, z_offset], center=true);
    }
    if(half_model)
      translate([base_width/2+83,-base_length/2-60,-2*bottom_wall_width])
        cube([base_width, base_length, z_offset], center=true);
  }
  // ------------------------------------------------------------
  if(bat_enclosure_slide_test || bat_enclosure_slide_test_chk) {
    z_offset  = (bat_enclosure_slide_test) ? (500) : (50);
    at_z_base = (bat_enclosure_slide_test_chk) ? (90) : (-2*bottom_wall_width);
    y_offset = (bat_enclosure_slide_test) ? (500) : (50);
    difference() {
      cube([2*base_width, 2*base_length, 2*max_z], center=true);
      translate([-65,base_length/2-92.5,at_z_base])
        cube([50, y_offset, z_offset], center=true);
    }
    if(half_model)
      translate([base_width/2+83,-base_length/2-60,-2*bottom_wall_width])
        cube([base_width, base_length, z_offset], center=true);
  }
  // ------------------------------------------------------------
  if(bat_enclosure_slot_test_chk || bat_enclosure_slot_test) {
    z_offset = 200;
    y_offset = (bat_enclosure_slot_test) ? (250) : (34);
    y_toffset = (bat_enclosure_slot_test) ? (0) : (92.5);
    difference() {
      cube([2*base_width, 2*base_length, 2*max_z], center=true);
      translate([base_width/2-32,base_length/2-y_toffset,-2*bottom_wall_width])
        cube([38, y_offset, z_offset], center=true);
    }
    if(half_model)
      translate([base_width/2+83,-base_length/2-60,-2*bottom_wall_width])
        cube([base_width, base_length, z_offset], center=true);
  }
  // ------------------------------------------------------------
  if(motor_enclosure_test) {
    z_offset = 200;
    difference() {
      cube([2*base_width, 2*base_length, max_z], center=true);
      translate([base_width/2+55,base_length/2-42.5,-2*bottom_wall_width])
        cube([base_width, 46, z_offset], center=true);
    }
    if(half_model)
      translate([base_width/2+83,-base_length/2-60,-2*bottom_wall_width])
        cube([base_width, base_length, z_offset], center=true);
  }
  // ------------------------------------------------------------
}
