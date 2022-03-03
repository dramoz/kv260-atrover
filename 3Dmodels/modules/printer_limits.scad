
// TODO: add function to get match wall_width

first_layer_height = 0.3;
min_layer_height = 0.3;
layer_height = 0.6;

ptr_top_wall_width = 2*layer_height;
ptr_tolerance = min_layer_height/2;

// lines: width (mm)
ptr_2lines = 1.67;
ptr_3lines = 2.44;
ptr_4lines = 3.21;
ptr_5lines = 3.98;
ptr_6lines = 4.76;

ptr_wall_width = ptr_3lines;

min_x = 8;
max_x = 223;
min_y = 2;
max_y = 207;
max_z = 200;

// LxW
max_printable_length = max(max_x-min_x, max_y-min_y);
max_printable_width = min(max_x-min_x, max_y-min_y);

function xy_dim_adj(x) = ceil(x/ptr_wall_width)*ptr_wall_width;
function  z_dim_adj(z) = ceil((z-first_layer_height)/min_layer_height)*min_layer_height + first_layer_height;

// screws diameters with tolerances
xy_screw_3mm_d = 3.2;
z_screw_3mm_d = 3.35;
