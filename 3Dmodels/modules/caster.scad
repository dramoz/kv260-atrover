use <../ext_modules/threads.scad>
use <../ext_modules/bearing.scad>
use <wheel.scad>
use <caster_bearing.scad>

module caster(
  bearing_diameter=2*18/sqrt(2),
  bearing_width=15,
  wheel_diameter=100,
  wheel_width=15,
  bearing=false,
  l_wheel=false,
  r_wheel=false,
  wheels_screw=true,
  reference_wheel=false,
  wheel_nut_test=false,
  wheel_spokes=360/45,
  wheel_tread_depth=5,
  wheel_thickness=6,
  wheel_total_treads = 360/15,
  wheel_tolerance=0.35,
  bearing_tolerance=0.8,
  rod_length = 100*2/3,
  rod_screw_offset=5,
  rod_width=18,
  rod_screw_diameter=12,
  draft=false,
  wall_width=2,
  tolerance=0.5
)
{
  wheel_offset = 4*tolerance;
  rod_screw_zpos = (bearing_width+rod_length-rod_screw_offset-rod_screw_diameter/2-tolerance);
  wheel_screw_zpos = -(2*rod_screw_offset-rod_screw_diameter/2-4*tolerance);
  caster_height = bearing_width + rod_length + wheel_diameter/2 - rod_screw_offset - rod_screw_diameter/2 - 2*tolerance - wheel_tolerance;
  echo(caster_height=caster_height);

  // reference wheel
  if(reference_wheel) {
    %color("Blue", 0.05)
      translate([(caster_height-wheel_diameter)/2, 0, 0])
        cylinder(d=caster_height, h=2*bearing_diameter, $fn=100, center=true);
  }
  if(l_wheel) {
    color("orange", 0.5)
      // L-wheel
    translate([wheel_screw_zpos, 0, -rod_width/2 - wheel_width - wheel_offset/2])
      wheel(
          wheel_diameter = wheel_diameter - 2*wheel_tread_depth,
          wheel_width = wheel_width,
          wheel_thickness = wheel_thickness,
          
          tread_depth = wheel_tread_depth,
          tread_tickness = wheel_thickness,
          total_treads = wheel_total_treads,
          
          spokes = wheel_spokes,
          motor_coupling = false,
          motor_plate_coupling = false,
          add_bearing = false,
          screw_wheel = true,
          
          dshaft = false, shaft_dshaft_inset = 0,
          setscrew_nut_at_shaft = false,
          setscrew_allan_key_hole = 0,
          hub_diameter = rod_screw_diameter,
          hub_support_diameter = 2*rod_screw_diameter,
          draft=draft,
          tolerance = wheel_tolerance
      );
  }
  if(r_wheel) {
  color("orange", 0.5)
    // R-wheel
    translate([wheel_screw_zpos, 0, (rod_width/2 + wheel_offset )])
      wheel(
        wheel_diameter = wheel_diameter - 2*wheel_tread_depth,
        wheel_width = wheel_width,
        wheel_thickness = wheel_thickness,
        
        tread_depth = wheel_tread_depth,
        tread_tickness = wheel_thickness,
        total_treads = wheel_total_treads,
        
        spokes = wheel_spokes,
        motor_coupling = false,
        motor_plate_coupling = false,
        add_bearing = false,
        screw_wheel = true,
        
        dshaft = false, shaft_dshaft_inset = 0,
        setscrew_nut_at_shaft = false,
        setscrew_allan_key_hole = 0,
        hub_diameter = rod_screw_diameter,
        hub_support_diameter = 2*rod_screw_diameter,
        draft=draft,
        tolerance = wheel_tolerance
      );
  }
  if(wheels_screw==true && draft==false) {
    screw_chamfer = 0;
    translate([wheel_screw_zpos, 0, -rod_width/2 - wheel_width - wheel_offset/2]) {
      screw_length = 2*wheel_width+rod_width+wheel_offset;
      shaft_length = rod_width-2*screw_chamfer+wheel_offset;
        difference() {
          union() {
            thread_for_screw(diameter=rod_screw_diameter, length=screw_length);
            translate([0, 0, screw_length/2-shaft_length/2]) {
              cylinder(d=rod_screw_diameter, h=shaft_length, $fn=100);
              if(screw_chamfer>0) {
                translate([0, 0, shaft_length])
                  cylinder(d1=rod_screw_diameter, d2=rod_screw_diameter/2, h=screw_chamfer, $fn=100);
                translate([0, 0, -screw_chamfer])
                  cylinder(d2=rod_screw_diameter, d1=rod_screw_diameter/2, h=screw_chamfer, $fn=100);
              }
            }
          }
          translate([0, 0, -screw_length])
            thread_for_nut(diameter=5, length=3*screw_length);
        }
      // uncomment if not full internal screw
      //translate([0, 0, -rod_width/2])
      //  cylinder(d=rod_screw_diameter, h=shaft_length-screw_chamfer, $fn=100);
    }
  }
  
  if(wheel_nut_test) {
    difference() {
      cylinder(d=2*rod_screw_diameter, h=wheel_width, center=true);
      translate([0, 0, -wheel_width])
        thread_for_nut(diameter=rod_screw_diameter, length=3*wheel_width);
    }
  }
  
  // bearing
  if(bearing) {
    translate([rod_screw_zpos, 0, 0])
      rotate([-90, 0, 90]) {
        d2 = bearing_diameter;
        caster_bearing(
          d2=d2, h=bearing_width, hw=4,
          shaft_h=rod_length+2*tolerance, shaft_h_offset=tolerance,
          rod_screw_diameter=rod_screw_diameter+2*tolerance, rod_screw_offset=rod_screw_offset,
          tolerance=bearing_tolerance, angle=45, wall_width=wall_width,
          draft=draft,
          half=false
        );
      }
  }
}

// Full caster
module full_caster(
  back_wheel_diameter=200,
  back_wheel_offset=15,
  bearing_diameter=70,
  bearing_width=15,
  wheel_width=15,
  wheel_spokes=360/45,
  wheel_tread_depth=5,
  wheel_thickness=6,
  wheel_total_treads = 360/15,
  bearing=true,
  l_wheel=true,
  r_wheel=true,
  wheels_screw=true,
  rod_length = 2/3 * 200,
  rod_screw_offset=5,
  rod_width=18,
  rod_screw_diameter=12,
  bearing_tolerance=1.0,
  draft=false,
  wall_width=2,
  tolerance=0.5
)
{
  expected_caster_height = back_wheel_diameter/2 + back_wheel_offset;
  echo(expected_caster_height=expected_caster_height);
  
  wheel_diameter = back_wheel_diameter/2 + back_wheel_offset - bearing_width - 5;
  echo(wheel_diameter=wheel_diameter);
  
  caster_height = bearing_width+rod_length-rod_screw_offset-(rod_screw_diameter+2*tolerance)/2;
  echo(rod_screw_offset=rod_screw_offset);
  rotate([180, 0, 0])
  translate([0, 0, caster_height])
    union() {
      rotate([0, 1*90, 0])
      caster(
        bearing_diameter=bearing_diameter,
        bearing_width=bearing_width,
        wheel_diameter=wheel_diameter,
        wheel_width=wheel_width,
        wheel_spokes=wheel_spokes,
        wheel_tread_depth=wheel_tread_depth,
        wheel_thickness=wheel_thickness,
        wheel_total_treads=wheel_total_treads,
        bearing=bearing,
        l_wheel=l_wheel,
        r_wheel=r_wheel,
        wheels_screw=wheels_screw,
        wheel_nut_test=false,
        reference_wheel=false,
        rod_length=rod_length,
        rod_screw_offset=rod_screw_offset,
        bearing_tolerance=bearing_tolerance,
        rod_width=rod_width,
        rod_screw_diameter=rod_screw_diameter,
        draft=draft,
        wall_width=wall_width,
        tolerance=tolerance
      );
    }
}

full_caster(
  bearing=true,
  l_wheel=true,
  r_wheel=true,
  wheels_screw=true,
  draft=false
);
