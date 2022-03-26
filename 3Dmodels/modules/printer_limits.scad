// ----------------------------------------------------------------------------------
// TODO: add function to get match wall_width
// ----------------------------------------------------------------------------------
first_layer_height = 0.3;
min_layer_height = 0.3;
layer_height = 0.6;

ptr_top_wall_width = 2*layer_height;
ptr_tolerance = min_layer_height/2;
// ----------------------------------------------------------------------------------
// lines: width (mm)
ptr_2lines = 1.67;
ptr_3lines = 2.44;
ptr_4lines = 3.21;
ptr_5lines = 3.98;
ptr_6lines = 4.76;

ptr_smallest_wall_width = ptr_2lines;
ptr_wall_width = ptr_3lines;
// ----------------------------------------------------------------------------------
min_x = 8;
max_x = 223;
min_y = 2;
max_y = 207;
max_z = 230;
// ----------------------------------------------------------------------------------
// LxW
max_printable_length = max(max_x-min_x, max_y-min_y);
max_printable_width = min(max_x-min_x, max_y-min_y);
// ----------------------------------------------------------------------------------
function xy_dim_adj(x) = ceil(x/ptr_smallest_wall_width)*ptr_smallest_wall_width;
function  z_dim_adj(z) = ceil((z-first_layer_height)/min_layer_height)*min_layer_height + first_layer_height;
function xy_wall_width_adj(x) =
    (x <= ptr_2lines) ? (ptr_2lines) :
    (x <= ptr_3lines) ? (ptr_3lines) :
    (x <= ptr_4lines) ? (ptr_4lines) :
    (x <= ptr_5lines) ? (ptr_5lines) :
    (x <= ptr_6lines) ? (ptr_6lines) :
    (ptr_6lines);
    
// ----------------------------------------------------------------------------------
// screws diameters with tolerances
// https://www.engineersedge.com/hardware/standard_metric_hex_nuts_13728.htm
xy_tolerance = 0.1;
z_tolerance = min_layer_height;

// M3
xy_screw_3mm_d      = 3 + xy_tolerance;
xy_screw_3mm_hd_d   = 5.3 + xy_tolerance;
xy_screw_3mm_hd_h   = z_dim_adj(2.1 + xy_tolerance);
xy_screw_3mm_nut_d  = 5.50+z_tolerance;
xy_screw_3mm_nut_dd = 6.35+z_tolerance;
xy_screw_3mm_nut_h  = z_dim_adj(2.55+z_tolerance);

z_screw_3mm_d      = z_dim_adj(3+z_tolerance);
z_screw_3mm_nut_d  = z_dim_adj(5.50+z_tolerance);
z_screw_3mm_nut_dd = z_dim_adj(6.35+z_tolerance);
z_screw_3mm_nut_h  = z_dim_adj(2.55+z_tolerance);

// M4
xy_screw_4mm_d      = 4 + xy_tolerance;
xy_screw_4mm_nut_d  = 7.00+z_tolerance;
xy_screw_4mm_nut_dd = 8.08+z_tolerance;
xy_screw_4mm_nut_h  = 3.20+z_tolerance;

z_screw_4mm_d      = z_dim_adj(4+z_tolerance);
z_screw_4mm_nut_d  = z_dim_adj(7.00+z_tolerance);
z_screw_4mm_nut_dd = z_dim_adj(8.08+z_tolerance);
z_screw_4mm_nut_h  = z_dim_adj(3.20+z_tolerance);

// M5
xy_screw_5mm_d = 5 + xy_tolerance;
z_screw_5mm_d  = z_dim_adj(5+z_tolerance);
//z_screw_5mm_nut_d  = z_dim_adj(5.50+z_tolerance);
//z_screw_5mm_nut_dd = z_dim_adj(6.35+z_tolerance);
//z_screw_5mm_nut_h  = z_dim_adj(2.55+z_tolerance);

