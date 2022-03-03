// ----------------------------------------------------------------------------------
use<./modules/motor_mount_GM37.scad>
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
  botttom_supports=false,
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
            enclosure_wall_width=4,
            tolerance=tolerance
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
