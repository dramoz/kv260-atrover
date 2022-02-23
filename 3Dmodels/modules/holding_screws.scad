module holding_screws(
  screws=4,
  screw_diameter=5,
  screw_distance=10,
  screw_inset=10,
  screw_start_angle=0,
  washer_diameter=0,
  center=false,
  fn=100
)
{
  $fn = fn;
  // Holding screws
  for(screw=[0:screws-1]) {
    rotate([0, 0, screw_start_angle + 360/screws * screw]) {
      translate([screw_distance, 0, 0]) {
        cylinder(d=screw_diameter, h=screw_inset, center=center);
        %if(washer_diameter>0) {
            washer_height = 0.5;
            cylinder(d=washer_diameter, h=washer_height, center=center);
            translate([0, 0, screw_inset-washer_height])
              cylinder(d=washer_diameter, h=washer_height, center=center);
        }
      }
    }
  }
}

holding_screws();