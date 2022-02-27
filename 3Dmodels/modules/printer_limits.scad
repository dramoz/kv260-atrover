
// TODO: add function to get match wall_width

first_layer_height = 0.4;
layer_height = 0.6;

bottom_width = first_layer_height + 3*layer_height;
top_width = 2*layer_height;
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
function  z_dim_adj(z) = ceil(z/layer_height)*layer_height;
