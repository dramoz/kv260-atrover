
// KV260-ATVRover Mini dimensions
// Units: 1 = 1mm
// NOTE: Printing limits are based on my current 3D printer limitations
tolerance = 0.35;
min_x = 10;
max_x = 230;
min_y = 20;
max_y = 205;

// LxW
max_printable_length = max(max_x-min_x, max_y-min_y);
max_printable_width = min(max_x-min_x, max_y-min_y);

// Base dimensions
base_width  = max_printable_width;   // Wheel Motors (2) min. required length: 10cm
base_length = max_printable_length;
base_wall_width = 5;                 // sets min. width for weight support, e.g. 5mm from current available sheet of PVC

// Battery dimensions
battery_length = 151;
battery_width = 99.1;
batter_height = 94.2;
