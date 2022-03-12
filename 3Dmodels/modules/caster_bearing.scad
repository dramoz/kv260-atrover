$fn = 100;

// Cone math
// r^2 + h^2 = sh (slant height)
// tan(x) = h/r

// Frustum (r1, r2)
// hc = hf + hu
// hu = (hf*r2)/(r1-r2)
// hc -> height of full cone
// -> hc = hf + (hf*r2)/(r1-r2)
//    hc = (hf*(r1-r2) + hf*r2) / (r1-r2)

// tan(x) = hc/r1
// -> tan(x) = (hf*(r1-r2) + hf*r2) / (r1-r2) / r1
// -> tan(x) = (hf*r1-hf*r2 + hf*r2) / r1*(r1-r2)
// -> tan(x) = hf/(r1-r2)
// => hf = tan(x)(r1-r2)

// For r2
// -> hf = r1*tan(angle)-r2*tan(angle)
// -> r2*tan(angle) = r1*tan(angle)-hf
// => r2 = (r1*tan(angle) - hf) / tan(angle)

// For r1
// -> hf = tan(angle)(r1-r2)
// -> hf+r2*tan(angle) = r1*tan(angle)
// -> r1 = (hf + r2*tan(angle)) / tan(angle)


// Visual test
//hu = (hf*r2)/(r1-r2);
//hc = hf + hu;
//cylinder(r1=r1, r2=0, h=hc);

module turn_slot(h) {
  w1 = 3.0;
  l1 = 7.5;
  w2 = 1.5;
  l2 = 6.0;
  hp  = 12.5;
  poly_ztx = (h>hp)?(-h/2-0.1):(-hp+h/2);
  translate([-l1/2, -w1/2, poly_ztx]) {
    l0 = (l1-l2)/2;
    w0 = (w1-w2)/2;
    polyhedron(
      points=[
        // bottom
        [  0,  0,  0 ],  //0
        [ l1,  0,  0 ],  //1
        [ l1, w1,  0 ],  //2
        [  0, w1,  0 ],  //3
        // top
        [    l0,    w0,  hp],  //4
        [ l2+l0,    w0,  hp],  //5
        [ l2+l0, w2+w0,  hp],  //6
        [    l0, w2+w0,  hp],  //7
      ],
      faces=[
        [0,1,2,3],  // bottom
        [4,5,1,0],  // front
        [7,6,5,4],  // top
        [5,6,2,1],  // right
        [6,7,3,2],  // back
        [7,4,0,3] // left
      ]
    );
  }
}

module bicone(r1, r2, h, hw=0) {
    hf = h/2;
    difference() {
      union() {
        //translate([0, 0, hw/2])
          cylinder(r1=r1, r2=r2, h=hf);
        mirror([0, 0, 1])
          //translate([0, 0, hw/2])
            cylinder(r1=r1, r2=r2, h=hf);
        //if(hw > 0) {
        //    cylinder(r=r1, h=hw, center=true);
        //}
      }
      if(hw>0) {
        // -> Use cylinder_r = r1-hw/2 (pitagoras)
        union() {
          difference() {
            cylinder(r=2*r1, h=10*hf, center=true);
            cylinder(r=r1-hw/2, h=30*hf, center=true);
          }
        }
      }
    }
}

module simple_bearing(
    d1 = 20,
    d2 = 0,
    h = 15,
    hw = 0,
    wall_width = 1.1,
    tolerance = 0.3,
    angle = 45,
) {
    hf = h/2;
    r1 = (d2==0)?(d1/2)
                :((hf + d2/2*tan(angle)) / tan(angle));
    r2 = (d2==0)?((r1*tan(angle) - hf) / tan(angle))
                :(d2/2);
    
    // Draw
    // Inside
    difference() {
      bicone(r1, r2, h, hw);
      turn_slot(h);
    }
    // Outside
    scale_factor = (r1+tolerance)/r1;
    cylider_r = wall_width + ( (hw>0)?((r1-hw/2)*scale_factor):(r1*scale_factor) );
    echo(cylider_r=cylider_r);
    difference() {
      cylinder(r=cylider_r, h=h, center=true);
      scale(scale_factor)
        bicone(r1, r2, h, hw);
      translate([0, 0, -h+0.2])
        cylinder(r=scale_factor*(r2+tolerance), h=h, center=true);
    }
}

module caster_bearing(d2=15, h=15, hw=10, shaft_h=30, shaft_h_offset=0, rod_screw_diameter=10, rod_screw_offset=5, tolerance=0.5, angle=45, wall_width=2.2, draft=false, half=false) {
  translate([0, 0, h/2])
    difference() {
      side = sqrt(2)*d2/2;
      union() {
        if(draft==false) {
          simple_bearing(d2=d2, h=h, hw=hw, tolerance=tolerance, angle=angle, wall_width=2.2);
        }
        else {
          r = (h/2 + d2/2*tan(angle)) / tan(angle);
          scale_factor = (r+tolerance)/r;
          scale(scale_factor)
            translate([0, 0, -h/2])
              cylinder(r=r, h=h);
        }
        translate([0, 0, shaft_h/2+h/2])
          cube([side, side, shaft_h], center=true);
      }
      if(draft==false) {
        translate([0, 0, shaft_h-shaft_h_offset])
          rotate([90, 180, 0]) {
            rod_width = 2*side;
            cylinder(d=rod_screw_diameter, h=rod_width, center=true, $fn=18);
            // circle top bearing feature
            translate([0, -12.3*rod_screw_diameter/100, 0])
              rotate([0, 0, 90])
                difference() {
                  cylinder(d=rod_screw_diameter-1.0, h=rod_width, center=true, $fn=6);
                  translate([0.69*rod_screw_diameter, 0, 0])
                    cube([2*rod_screw_diameter, 2*rod_screw_diameter, 6*rod_screw_diameter], center=true);
                }
          }
      }
      
      if(half) {
        translate([20, 0, 0])
          cube([40, 80, h+shaft_h+80], center=true);
      }
    }
}

*caster_bearing(d2=2*18/sqrt(2), h=15, hw=4, shaft_h=30, rod_screw_diameter=10, rod_screw_offset=5, tolerance=0.75, angle=45, wall_width=2.2, half=false);

/*
for(hw=[
    [0, 0],
    [5, 40]
  ])
  {
  for(t=[
      [0.6,    0],
      [0.7,   40],
      [0.8,  80],
  ])
  {
    translate([t[1], hw[1], 0])
      caster_bearing(d2=15, h=15, hw=hw[0], tolerance=t[0], angle=45, wall_width=2.2, half=false);
  }
}
*/