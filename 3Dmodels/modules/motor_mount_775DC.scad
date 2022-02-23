// https://www.alibaba.com/product-detail/42mm-12v-high-torque-dc-motor_60415055244.html
module motor_mount_775DC(
  wall_width = 4.4,
  fn=100,
  tolerance=0.5
)
{
  $fn = fn;

  // Motor parameters
  motor_shaft_base_diameter = 17.4 + tolerance;
  mounting_screw_distance = 29/2;
  mounting_screw_diameter = 4 + tolerance;
  mounting_screw_inset = 2 + tolerance;
  mounting_screw_inset_diameter = 7.4 + tolerance;
  mounting_screws = 2;
  motor_vent_width = 10;
  motor_vent_depth = 3.5;
  motor_vent_inset = 0.5;
  motor_vents = 4;

  motor_diameter = 42 + tolerance;
  motor_enclosure_diameter = 44.6 + tolerance;
  motor_length = 44;
  motor_enclosure_length = 34;
  motor_enclosure_offset = 5 - tolerance;

  // Base parameters
  base_length = 70;
  base_width = 70;
  base_height = 4 + tolerance;

  // Base holding screws
  base_screw_distance = 36;
  base_screws = 4;
  base_screw_diameter = 5 + tolerance;
  
  difference() {
    union() {
      // Base plate
      cube([base_length, base_width, base_height], center=true);
      // motor enclosure
      translate([0, 0, base_height/2 + motor_length/2])
        cylinder(d=motor_enclosure_diameter + wall_width, h=motor_length + wall_width, center=true);
      // enclosure supports
      *difference() {
        translate([0, 0, -base_height/2])
          union() {
            rotate([0, 90, 0])
              rotate([0, 0, 45])
                cube([base_length, base_width, base_height], center=true);
            rotate([90, 0, 0])
              rotate([0, 0, 45])
                cube([base_length, base_width, base_height], center=true);
          }
        translate([-base_length, -base_width, -base_length -base_height/2])
          cube([2*base_length, 2*base_width, base_length]);
      }
      // motor vents pipes
      for(hole=[0:motor_vents-1]) {
      rotate([0, 0, 45 + 360/motor_vents * hole])
        translate([motor_enclosure_diameter/6 + mounting_screw_distance - mounting_screw_diameter/2, 0, base_height/2 - motor_vent_inset])
          cube([0.3*motor_enclosure_diameter, motor_vent_width, motor_vent_depth], center=true);
    }
    }
    // Hollow motor enclosure
    union() {
      translate([0, 0, base_height/2 + 1.2*motor_length/2 + motor_enclosure_offset])
        cylinder(d=motor_enclosure_diameter, h=1.2*motor_length, center=true);
      translate([0, 0, base_height/2 + 1.2*motor_length/2])
        cylinder(d=motor_diameter, h=1.2*motor_length, center=true);
    }
    // Holding screws
    for(hole=[0:base_screws-1]) {
      rotate([0, 0, 45 + 360/base_screws * hole]) {
        translate([base_screw_distance, 0, 0])
          cylinder(d=base_screw_diameter, h=1.2*base_height, center=true);
      }
    }
    
    // Motor front step
    cylinder(d=motor_shaft_base_diameter, h=1.2*base_height, center=true);
    // Motor screws
    for(hole=[0:mounting_screws-1]) {
      rotate([0, 0, 360/mounting_screws * hole]) {
        translate([mounting_screw_distance, 0, 0])
          cylinder(d=mounting_screw_diameter, h=1.2*base_height, center=true);
        translate([mounting_screw_distance, 0, -base_height/2 + mounting_screw_inset/2 - 1])
          cylinder(d=mounting_screw_inset_diameter, h=mounting_screw_inset+1, center=true);
      }
    }
    // Motor vents
    for(hole=[0:motor_vents-1]) {
      rotate([0, 0, 45 + 360/motor_vents * hole])
        translate([motor_enclosure_diameter/6 + mounting_screw_distance - mounting_screw_diameter/2, 0, base_height/2 - motor_vent_inset])
          cube([0.3*motor_enclosure_diameter, motor_vent_width, motor_vent_depth], center=true);
    }
  }

  // Motor support

}

module mini_motor_mount_775DC(
  length,
  base_thickness = 2,
  shaft_cap=false,
  wall_width = 2,
  motor=false,
  flipped = false,
  fn=100,
  tolerance=0.5
)
{
  $fn = fn;

  // Motor parameters
  motor_shaft_length = 15.5;
  motor_shaft_diameter = 5;
  motor_shaft_base_height = 4.5;
  motor_shaft_base_diameter = 17.5 + tolerance;  // measured
  mounting_screw_distance = 29/2;
  mounting_screw_diameter = 4 + tolerance;
  mounting_screw_inset = (flipped)?(2.5):(2);
  mounting_screw_inset_diameter = 7.4 + tolerance;
  mounting_screws = 2;
  motor_vent_width = 10;
  motor_vent_depth = 3.5;
  motor_vent_inset = 0.5;
  motor_vents = 4;

  motor_diameter = 42 + tolerance;
  motor_enclosure_diameter = 44.6 + tolerance;
  echo(motor_enclosure_diameter=motor_enclosure_diameter);
  motor_length = 66.5;
  motor_enclosure_length = 34;
  motor_mount_length = (length>motor_length)?(motor_length):(length);
  motor_enclosure_offset = (flipped)?(4.4):(5.2);
  
  // Base parameters
  base_length = 70;
  base_width = 70;
  base_height = 4 + tolerance;

  // Base holding screws
  base_screw_distance = 36;
  base_screws = 4;
  base_screw_diameter = 5 + tolerance;
  
  mount_diameter = motor_enclosure_diameter + base_thickness;
  echo(mount_diameter=mount_diameter);
  
  module motor_775DC () {
    translate([0, 0, motor_shaft_base_height]) {
      // shaft
      translate([0, 0, -motor_shaft_base_height])
        cylinder(d=motor_shaft_base_diameter, h=motor_shaft_base_height);
      translate([0, 0, -(motor_shaft_base_height+motor_shaft_length)])
        cylinder(d=motor_shaft_diameter+tolerance, h=motor_shaft_length);
        
      // motor
      translate([0, 0, 0])
        cylinder(d=motor_diameter, h=motor_length);
      translate([0, 0, motor_enclosure_offset])
        cylinder(d=motor_enclosure_diameter, h=motor_enclosure_length);
    }
  }
  
  if(motor) {
    %motor_775DC();
  }
  // Motor support
  difference() {
    union(){
      // enclosure cylinder
      cylinder(d=motor_enclosure_diameter + 2*wall_width, h=motor_mount_length + base_thickness);
      // vents cylinder
      difference() {
        cylinder(d=motor_enclosure_diameter + 6*wall_width, h=motor_mount_length + base_thickness);
        translate([0, 0, base_thickness])
          cylinder(d=motor_enclosure_diameter + 4*wall_width, h=2*motor_mount_length + base_thickness);
      }
      // base shaft protection
      if(shaft_cap) {
        translate([0, 0, -wall_width-0.01])
          cylinder(d=motor_shaft_base_diameter+4, h=wall_width);
      }
      // enclosure supports
      translate([0, 0, length+base_height+0.5])
        difference() {
          union() {
            rotate([0, 90, 0])
              rotate([0, 0, 45])
                cube([base_length, base_width, base_height], center=true);
            rotate([90, 0, 0])
              rotate([0, 0, 45])
                cube([base_length, base_width, base_height], center=true);
          }
          translate([-base_length, -base_width, 0])
            cube([2*base_length, 2*base_width, base_length]);
          translate([0, 0, -(length+base_height+0.5)-base_length/2])
            cube([base_length, base_length, base_length], center=true);
          cylinder(d=motor_enclosure_diameter + 6*wall_width, h=base_length, center=true);
        }
    }
    // Hollow motor enclosure
    motor_775DC();
    // motor vents pipes
    for(hole=[0:motor_vents-1]) {
      rotate([0, 0, 45 + 360/motor_vents * hole])
        translate([motor_enclosure_diameter/6 + mounting_screw_distance - mounting_screw_diameter/2, 0, base_height/2 - motor_vent_inset + wall_width])
          cube([0.3*motor_enclosure_diameter, motor_vent_width, motor_vent_depth], center=true);
    }
    // Motor front step
    translate([0, 0, -0.1])
      cylinder(d=motor_shaft_base_diameter, h=1.2*motor_shaft_base_height);
    // Motor screws
    for(hole=[0:mounting_screws-1]) {
      rotate([0, 0, 360/mounting_screws * hole]) {
        translate([mounting_screw_distance, 0, -0.01])
          cylinder(d=mounting_screw_diameter, h=1.2*base_height);
        translate([mounting_screw_distance, 0, -0.01])
          cylinder(d=mounting_screw_inset_diameter, h=mounting_screw_inset);
      }
    }
  }
}

motor_mount_775DC();