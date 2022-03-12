use <../ext_modules/bearing.scad>
use <../ext_modules/threads.scad>

module shaft_coupling(
    coupling_length, coupling_diameter,
    shaft_diameter, dshaft_diameter, shaft_dshaft_inset,
    setscrews, setscrews_distance, setscrew_diameter, setscrew_inset, setscrew_shaft_position,
    setscrew_nut_thickness, setscrew_nut_diameter, setscrew_nut_shaft_inset, setscrew_nut_angle=0,
    as_inset=false,
    center=false
) {
  // setscrew (M3)
  setscrew_length = coupling_diameter/2;
  nut_shaft_inset = abs(setscrew_nut_shaft_inset);

  // motor D shaft
  ddshaft_diameter = (dshaft_diameter>0)?(dshaft_diameter):(shaft_diameter);
  shaft_length = coupling_length;
  dshaft_length = coupling_length - shaft_dshaft_inset;
  
  // calculate parameters
  translate_shaft_coupling = (center==true)?(shaft_length/2):(0);

  // Paint
  translate([0, 0, translate_shaft_coupling])
    difference() {
      // hub
      if(as_inset==false) {
        cylinder(d=coupling_diameter, h=coupling_length, center=true);
      }
      // shaft + setscrew
      translate([0, -shaft_diameter/2, -shaft_length/2]) {
        // setscrew
        for(screw_num = [0:setscrews-1]) {
          translate([0, ddshaft_diameter, setscrew_shaft_position + screw_num * (setscrew_nut_diameter+setscrews_distance)])
            rotate([-90, setscrew_nut_angle, 0])
              union() {
                // internal nut
                if(setscrew_nut_shaft_inset>0) {
                  translate([0, 0, -nut_shaft_inset]) {
                    cylinder(d=setscrew_nut_diameter, h=nut_shaft_inset+setscrew_nut_thickness);
                  }
                }
                else {
                  translate([0, 0, nut_shaft_inset]) {
                    cube([setscrew_nut_diameter, coupling_length, setscrew_nut_thickness], center=true);
                  }
                }
                // setscrew
                cylinder(d=setscrew_diameter, h=1.2*setscrew_length);
                if(setscrew_inset>0) {
                  translate([0, 0, setscrew_length-setscrew_inset-shaft_diameter/2])
                    cylinder(d=setscrew_nut_diameter, h=setscrew_length);
                }
              }
        }
        // motor shaft
        difference() {
          translate([0, shaft_diameter/2, -0.01])
            cylinder(d=shaft_diameter, h=0.02+shaft_length);
          // d-shaft
          if(dshaft_diameter>0) {
            translate([-dshaft_diameter, dshaft_diameter, 0])
              cube([2*dshaft_diameter, dshaft_diameter, dshaft_length]);
          }
        }
      }
    }
}

module shaft_plate_coupling(
  hub_diameter,
  setscrews, setscrew_length, setscrew_diameter, plate_setscrew_distance,
  setscrew_nut_thickness, setscrew_nut_diameter, setscrew_nut_inset, setscrew_nut_angle,
  center=false
) {
  // Paint
  center_move = (center==true) ? (-setscrew_length/2) : (0);
  nut_angle_pos = 360/setscrews;
  translate([0 , 0 , center_move])
    for(screw_num = [0:setscrews-1]) {
      rotate([0, 0, screw_num*nut_angle_pos])
        translate([plate_setscrew_distance, 0, 0])
          union() {
            // internal nut
            translate([0, 0, setscrew_length - setscrew_nut_thickness - setscrew_nut_inset]) {
              // nut
              rotate([0, 0, setscrew_nut_angle])
                cylinder(d=setscrew_nut_diameter, h=setscrew_nut_thickness, $fn=6);
              // nut slot
              translate([0, -setscrew_nut_diameter/2, 0])
                cube([hub_diameter/2, setscrew_nut_diameter, setscrew_nut_thickness]);
            }
            // setscrew
            cylinder(d=setscrew_diameter, h=setscrew_length);
          }
    }
}

module wheel(
  wheel_diameter, wheel_width, wheel_thickness,
  tread_depth, tread_tickness, total_treads,
  spokes,
  motor_coupling = true,
  motor_plate_coupling = false,
  add_bearing = false,
  screw_wheel = false,
  dshaft = true, shaft_dshaft_inset = 0,
  hub_setscrews = 2,
  setscrew_nut_at_shaft=true,
  setscrew_allan_key_hole = 0,
  hub_diameter = 0,
  hub_support_diameter = 0,
  draft=false,
  tolerance = 0.5
)
{
  // Design parameters
  
  $fn=100;

  rim_width = wheel_width;
  rim_thickness = tread_tickness;
  
  hub_height = (motor_coupling)?(wheel_width):(wheel_width);
  hub_support_diameter_set = (add_bearing)?(60):( (hub_support_diameter)?(hub_support_diameter):(30));
  hub_diameter_d = (add_bearing)?(70):(23);
  hub_diameter_inset = (hub_diameter)?(hub_diameter):(20 + tolerance);
  hub_setscrews_distance = (setscrew_nut_at_shaft)?(0):(0.6);
  hub_setscrew_diameter = 3 + tolerance;
  hub_setscrew_inset = (dshaft==true)?(1):(1.8);
  hub_shaft_diameter = 6 + tolerance;
  hub_dshaft_diameter = (dshaft==true)?(5.4 + tolerance):(0);
  hub_shaft_dshaft_inset = (dshaft==true)?(shaft_dshaft_inset):(0);
  hub_setscrew_nut_diameter = (setscrew_nut_at_shaft)?(6.5 + tolerance):(5.5 + tolerance);
  hub_setscrew_nut_thickness = 2.3 + tolerance;
  hub_setscrew_nut_shaft_inset = (setscrew_nut_at_shaft)?(hub_shaft_diameter/2):(-3.5);
  motor_shaft_length = 12;
  hub_setscrew_height = (hub_height - hub_shaft_dshaft_inset) - hub_setscrews*motor_shaft_length/(1+hub_setscrews) - hub_setscrews_distance;

  plate_thickness = 2;
  plate_setscrew_nut_diameter = 6 + tolerance;
  plate_setscrew_length = 8 + tolerance;
  plate_setscrew_distance = 8;
  plate_setscrew_diameter = 3 + tolerance;
  plate_setscrew_nut_thickness = 2.5 + tolerance;
    
  // Calculate parameters
  tread_angle = (total_treads>0)?(360/total_treads):(0);
  rim_angle = 360/spokes;
  
  // Paint
  difference() {
    union() {
      difference() {
        translate([0, 0, wheel_width/2]) {
          // Exterior Wheel
          difference() {
            cylinder(d=wheel_diameter, h=wheel_width, center=true);
            cylinder(d=wheel_diameter-2*wheel_thickness, h=3*wheel_width, center=true);
          }
          // treads
          if(draft==false) {
            offset = 2;
            if(tread_angle) {
              for(ang=[0:tread_angle:360])
              {
                rotate([0, 0, ang])
                  translate([wheel_diameter/2, 0, 0])
                    difference()
                    {
                      translate([-offset, 0, -wheel_width/2])
                        linear_extrude(height=wheel_width)
                          polygon(points=[ [0, tread_tickness/2 + offset/2], [0, -tread_tickness/2 - offset/2], [tread_tickness/2 + tread_depth + offset, 0] ]);
                      translate([1.5*tread_depth, 0, 0])
                        cube([tread_depth, tread_tickness, 1.2*wheel_width], center=true);
                      //translate([tread_depth/2, 0, 0]) cube([tread_depth, tread_tickness, 1.2*wheel_width], center=true);
                    }
              }
            }
            
            // Rim
            translate([0,0, rim_width/2 - wheel_width/2])
              for(ang=[0:rim_angle:360]) {
                rotate([0, 0, ang])
                  cube([wheel_diameter-wheel_width/4, rim_thickness, rim_width], center=true);
              }
            
            // Hub support
            cylinder(d=hub_support_diameter_set, h=hub_height, center=true);
          }
          else {
            // Rim
            translate([0,0, rim_width/2 - wheel_width/2])
              for(ang=[0:rim_angle:360]) {
                rotate([0, 0, ang])
                  cube([wheel_diameter-wheel_width/4+2*tread_depth, rim_thickness, rim_width], center=true);
              }
          }
        }
        if(draft==false) {
          // Get hub space
          if(motor_coupling || add_bearing) {
            translate([0, 0, hub_height/2])
              cylinder(d=hub_diameter_d-tolerance, h=1.2*hub_height, center=true);
          }
          else {
            if(screw_wheel) {
              translate([0, 0, -wheel_width])
                thread_for_nut(diameter=hub_diameter, length=3*wheel_width);
            }
            else {
              translate([0, 0, hub_height/2])
                cylinder(d=hub_diameter_inset, h=1.2*hub_height, center=true);
            }
          }
        }
      }

      // Motor coupling
      if(motor_coupling) {
        union() {
          rotate([0, 0, rim_angle/2-90])
            shaft_coupling(
              coupling_length=hub_height, coupling_diameter=hub_diameter_d,
              shaft_diameter=hub_shaft_diameter, dshaft_diameter=hub_dshaft_diameter, shaft_dshaft_inset=hub_shaft_dshaft_inset,
              setscrews=hub_setscrews, setscrews_distance=hub_setscrews_distance, setscrew_diameter=hub_setscrew_diameter, setscrew_inset=hub_setscrew_inset, setscrew_shaft_position=hub_setscrew_height,
              setscrew_nut_thickness=hub_setscrew_nut_thickness, setscrew_nut_diameter=hub_setscrew_nut_diameter, setscrew_nut_shaft_inset=hub_setscrew_nut_shaft_inset, setscrew_nut_angle=0,
              center=true);
        }
      }

      if(add_bearing) {
        base_width = 45;
        base_depth = base_width;
        base_height = 5;
        base_support_width = 3;
        base_screws = 2;
        base_screw_distance = 17;
        base_screw_diameter = 5 + tolerance;

        base_center_offset = 0;
        base_2_shaft = -7;
        shaft_length = 2 + base_support_width;
        shaft_diameter = 20;

        bearing(
          D=hub_diameter_d,   // outer diameter of ring
          T=wheel_width,     // thickness
          tol=0.18,  // clearance
          number_of_planets=7,
          number_of_teeth_on_planets=7,
          approximate_number_of_teeth_on_sun=14,
          P=45,      // pressure angle[30:60]
          nTwist=1,  // number of teeth to twist across
          w=6.7,     // width of hexagonal hole
          DR=0.5*1,  // maximum depth ratio of teeth
          center_inset_fn = 0
        );
        // shaft cube
        translate([0, 0, wheel_width + shaft_length/2 - tolerance])
          //cube([shaft_diameter, shaft_diameter, shaft_length + tolerance], center=true);
          cylinder(d=shaft_diameter, h=shaft_length + tolerance, center=true);
        // base
        translate([0, base_center_offset, wheel_width + shaft_length/4  + sqrt(base_width*base_width + base_depth*base_depth)/2 + base_2_shaft])
        rotate([90, 0, 0]) rotate([0, 0, 45])
          difference() {
            union() {
              // base
              cube([base_width, base_depth, base_height], center=true);
              // base support triangle(s)
              difference() {
                union() {
                  translate([0, 0, -base_height/2])
                    rotate([0, 0, 90]) rotate([90, 0, 0]) rotate([0, 0, 45])
                      cube([base_width, base_depth, base_height], center=true);
                  translate([0, 0, -base_height/2])
                    rotate([0, 0, 0]) rotate([90, 0, 0]) rotate([0, 0, 45])
                      cube([base_width, base_depth, base_height], center=true);
                }
                rotate([0, 0, 45])
                  translate([-25, 0, 0])
                    cube(50, center=true);
              }
              rotate([0, 0, -45]) rotate([0, 90, 0])
                translate([0, -10, 0])
                  cube([shaft_diameter-2, base_depth/2, 1.5*base_height], center=true);
            }
            translate([0, 0, -5*base_height - base_height/2])
              cube([1.2*base_width, 1.2*base_depth, 10*base_height], center=true);
            // Holding screws
            for(hole=[0:base_screws-1]) {
              rotate([0, 0, -45 + 360/base_screws * hole]) {
                translate([base_screw_distance, 0, 0]) {
                  cylinder(d=base_screw_diameter, h=10*base_height, center=true);
                  *translate([0, 0, base_height])
                    cylinder(d=19, h=1, center=true);
                }
              }
            }
            rotate([0, 0, 45])
              translate([base_screw_distance, 0, 0]) {
                cylinder(d=base_screw_diameter, h=10*base_height, center=true);
                *translate([0, 0, base_height])
                  cylinder(d=19, h=1, center=true);
              }
            // clean corners
            translate([0, 0, base_depth + base_height + 5])
              cube(2*base_depth, center=true);
            translate([0, 0, -1.5*base_height])
              cube([1.5*base_width, 1.5*base_depth, 2*base_height], center=true);
          }
      }
    }

    union() {
      if(motor_coupling) {
        // Wheel setscrew holes for allan key
        if(setscrew_allan_key_hole > 0) {
          for(screw_num=[0, hub_setscrews-1]) {
            translate([0, 0, hub_setscrew_height + screw_num * hub_setscrew_nut_diameter])
              rotate([0, 90, rim_angle/2])
                cylinder(d=setscrew_allan_key_hole, h=wheel_diameter + 10);
          }
        }
        
        // Coupling insets
        rotate([0, 0, rim_angle/2-90])
          shaft_coupling(
            coupling_length=hub_height, coupling_diameter=hub_diameter_d,
            shaft_diameter=hub_shaft_diameter, dshaft_diameter=hub_dshaft_diameter, shaft_dshaft_inset=hub_shaft_dshaft_inset,
            setscrews=hub_setscrews, setscrews_distance=hub_setscrews_distance, setscrew_diameter=hub_setscrew_diameter, setscrew_inset=hub_setscrew_inset, setscrew_shaft_position=hub_setscrew_height,
            setscrew_nut_thickness=hub_setscrew_nut_thickness, setscrew_nut_diameter=hub_setscrew_nut_diameter, setscrew_nut_shaft_inset=hub_setscrew_nut_shaft_inset, setscrew_nut_angle=0,
            as_inset=true,
            center=true);
        
        // Motor plate adapter coupling
        if(motor_plate_coupling) {
          translate([0, 0, hub_height-plate_setscrew_length+plate_thickness])
            rotate([0, 0, -rim_angle/2])
              shaft_plate_coupling(
                hub_diameter=hub_diameter_d,
                setscrews=4, setscrew_length=plate_setscrew_length, setscrew_diameter=plate_setscrew_diameter, plate_setscrew_distance=plate_setscrew_distance,
                setscrew_nut_thickness=plate_setscrew_nut_thickness, setscrew_nut_diameter=plate_setscrew_nut_diameter, setscrew_nut_inset=plate_thickness+3, setscrew_nut_angle=90,
                center=false);
        }
      }
    }
  }
}
