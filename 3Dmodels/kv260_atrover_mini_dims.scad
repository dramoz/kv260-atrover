
// KV260-ATVRover Mini dimensions
// Units: 1 = 1mm
// NOTE: Printing limits are based on my current 3D printer limitations
// ----------------------------------------------------------------------------------
include<./modules/printer_limits.scad>
// ----------------------------------------------------------------------------------
// Base dimensions
base_width  = max_printable_width;   // Wheel Motors (2) min. required length: 10cm
base_length = max_printable_length;
base_wall_width = 5;                 // sets min. width for weight support, e.g. 5mm from current available sheet of PVC

// Battery dimensions
battery_length = 152;
battery_width = 100;
battery_height = 95;
