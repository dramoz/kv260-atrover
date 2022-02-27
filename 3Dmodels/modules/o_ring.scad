use <./holding_screws.scad>

module o_ring(
  diameter,
  inner_diameter,
  width,
  screws=0,
  washer_diameter=0,
  tolerance=0,
  center=false,
  screw_distance_offset=0,
  fn=100
)
{
  $fn = fn;
  translate_z = (center==true)?(-width/2):(0);

  translate([0, 0, translate_z])
    difference() {
      cylinder(d=diameter, h=width);
      translate([0, 0, width/2])
      cylinder(d=inner_diameter, h=2*width, center=true);
      // ring screws
      translate([0, 0, -width])
        if(screws>0) {
          holding_screws(
              screws=screws,
              screw_diameter=5+tolerance,
              screw_distance=diameter/2 - washer_diameter/2 + screw_distance_offset,
              screw_inset=3*width,
              screw_start_angle=0,
              center=false
          );
        }
    }
}
