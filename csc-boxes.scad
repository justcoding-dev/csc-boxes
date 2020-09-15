////////////////////////////////////////////////////////////////////////////////////
// Customizable connected boxes
//
// v4 - reduced base block size to 40mm, some modularization
// v5 - added divider_width into box size calculations, debug simplify switch
// v6 - organization and renaming
// v6.2 - modularization, placement of objects
// v6.3 - set useful starting values
// v6.4 - documentation
//
//
// Each box is made up from a grid of x * y square units. Set the base unit size
// and the number of units in X and Y direction next. Each unit in the box will 
// have a cutout for a connector on the outside.
//
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
// Start editing here
//
// Place your commands for creating things in the run() module. It will be run
// after all variables have been initialized.
//
// Edit the parameters for the box and connector geometry in the lines below
// the run() module. 
////////////////////////////////////////////////////////////////////////////////////


// Set to true for debugging (disables corner rounding for faster ren):
simplify = false;

// This will be run once all variables have been initialized. Put your 
// wanted things here or uncomment one of the predefined functions (they
// are defined further down in the script).
module run() {

    // Create a set of containers and connector bars over a 9x9 area to
    // judge how they fit together
    // create_demo_box_set_9x9();

    // Create a small smaple of connector and cutout to see how well they fit together
    // Useful for testing out new sizes and tolerances
    // create_fitting_test();

    // Create a single container with width, depth, height and wall thickness parameters
    // The box is placed at 0/0 and extends in positive directions.
    // box(width, depth, height, wall_thickness);
    // box(2,2,60,2);

    // Create a box and move it by dx base units to the right (use negative values
    // to move to the left) and by dy base unit sizes along the y-axis.
    // box_at(width, depth, height, wall_thickness, dx, dy);
    // box_at(2,2,40,2,3,2);

    // Create a connector bar in x or y direction with a given length (in base units).
    // The bar will begin at 0/0 and extend in positive direction and is then
    // moved by dx and dy base unit sizes along the x and y axis.
    // connector_bar_x_at(length, dx, dy);
    // connector_bar_x_at(2, 1, 2);

    // Create two boxes and a connector bar and place them spaced for direct printing
    // box_at(2,1,30,2,0,0);
    // connector_bar_x_at(2, 0, 2);
    // box_at(2,2,30,2,0,3);
}


// Size of one unit, which has one connector
unit_size = 40;

// The floor is made up of three parts. The upper_floor is the visible floor 
// at the bottom of the box.The bottom_floor below that has cutout where the
// connectors fit in. The heigt of the bottom floor part is equal to the height
// (or thickness) of the connectors plus some distance so they don't touch.

// Thickness of the upper floor part. This can be rather thin, as it only
// covers the cutouts. 
top_floor_height = 1.6;

// Thickness of the connector bar and connectors
connector_height = 1.6;

// Space between connector and top floor
floor_distance = 0.4;

// The connectors are triangular shapes that connect the cutouts of two adjacent
// boxes. They can be attached to a connector bar (or divider), but that will add 
// a gap between the boxes. Also it will complicated calculations for the
// box dimensions and connector positions...

// Width of the divider bar with the connectors. Set to zero to create only individual
// connector pieces.
// Possible value: bar_width >= 0
bar_width = 6;

// How much the divider goes under the boxes. If this is greater than 0, the box
// must be printed with supports.
// Possible values: 0 <= bar_overlap <= bar_width
bar_overlap = 3;

// How much the connectors should overlap
// When zero, the connectors will touch their edges in the middle of the
// connector bar. When increasing this value, the connectors will be moved towards
// each other, so they overlap in the connector bar
connector_overlap = 12;

// You might want to adjust this value (the connector size) when changing the connector 
// overlap above. The cutouts for the connectors must not touch each other.
// For an overlap of 15 a divisor of 3.5 here works well.
connector_radius = unit_size / 3.5;

// Size difference between radii of the connector and the cutouts in mm
connector_margin = 0.3;

////////////////////////////////////////////////////////////////////////////////////
// Stop editing here. 
////////////////////////////////////////////////////////////////////////////////////

// Calculate some helper variables

// Calculate total floor thickness from the individual layers
total_floor_height = top_floor_height + connector_height + floor_distance;

// The height of the bottom part of the floor, this will encase the connectors 
bottom_floor_height = connector_height + floor_distance;

// Size adjustment to account for bar width and overlap (two 1x1 boxes with a connector
// bar between them must take the same space as one 1x2 box)
div_adjust = bar_width - 2 * bar_overlap;

bar_adjust = max(bar_width / 2 - bar_overlap, 0);

// Calculate total box length for a given number of base units
function length(numUnits) = numUnits * unit_size + sign(numUnits) * (abs(numUnits) - 1) * div_adjust;

outer_radius = connector_radius + connector_margin / 2;
inner_radius = connector_radius - connector_margin / 2;

// Everything ist set. Run the module with the user commands.
run();

// Create two half 1x1 boxes without walls and a connector for quickly
// printing a test sample to judge the fitting of the connectors to
// the boxes.
module create_fitting_test() {
    
    // Setup one box in the origin location, mask out one half
    intersection() {
        box(1, 1, total_floor_height, 3);
        box_mask_connector();
    }
    
    // Setup a second box further down the x axis, mask out half of it
    translate ([shift(1.5) + bar_offset(1.5), shift(0) + bar_offset(0), 0]) 
        intersection() {
            box(1, 1, total_floor_height, 3);
            box_mask_connector();
        }

    // Put a connector between the boxes
    connector_bar_y_at(1, 1.5, 0);
}


// Mask out everything except the area around one connector. 
// Box size must be 1,1
module box_mask_connector() {
    
    translate([length(1) / 2, length(1) / 4, 0])
        translate([length(1) / 4 + bar_adjust, length(1) / 4 + bar_adjust, total_floor_height / 2])
            // scale([outer_radius * 2, outer_radius * 2, total_floor_height]) 
            scale([length(1) / 2, length(1), total_floor_height]) 
                cube(1, true);
}


module create_box_with_bar(width = 1, depth = 1, height = 10, wall_thickness = 2) {
    
    box(1, 1, height, wall_thickness);

    // Where to place the connector: 
    // make box and connector: fit connectors into cutouts on +y side:
    // (lengthY + bar_width) / 2 - bar_overlap
    y_offset = (lengthY + bar_width) / 2 - bar_overlap; 

    translate ([0, y_offset, 0]) 
        connector_bar();
        

}

module create_demo_box_set_9x9() {
    
    // top right
    connector_bar_y_at(2, 0, 0);
    box(2,2,30,1);
    connector_bar_y_at(3, 2, 0);
    box_at(3,1,30,1,-1,2);
    box_at(1,3,30,1,2,0);
    connector_bar_x_at(2,0,2);

    // top left
    connector_bar_x_at(4, -1, 0);
    box_at(1,1,30,1,-1,0);
    box_at(1,1,30,1,-1,1);
    connector_bar_x_at(1, -1, 1);
    connector_bar_y_at(5, -1, -3);
    box_at(2,3,30,1, -3, -1);
    connector_bar_x_at(3, -3, 2);
    box_at(2,1,30,1, -3, 2);
    connector_bar_y_at(1, -1, 2);

    
    // bottom left
    connector_bar_y_at(1, 0, -1);
    box_at(1,1,30,1,-1,-1);
    box_at(2,2,30,1, -1, -3);
    box_at(2,2,30,1, -3, -3);
    connector_bar_x_at(2, -3, -1);

    // bottom right
    box_at(2,1,30,1,1,-3);
    box_at(2,1,30,1,0,-1);
    box_at(1,1,30,1,1,-2);
    box_at(1,2,30,1,2,-2);
    connector_bar_x_at(3, -1, -1);
    connector_bar_x_at(2, 1, -2);
    connector_bar_y_at(2, 2, -2);
    connector_bar_y_at(2, 1, -3);


}


// Position of the i-th connector 
function conn_pos(i, size) = (i - size / 2 - 0.5) * unit_size + (i - size / 2 - 0.5) * div_adjust;

function shift(num_units) = num_units != 0 ? length(num_units) : 0;
function bar_offset(num) = num != 0 ? sign(num) * max(bar_width / 2 - bar_overlap, 0) * 2 : 0;


module connector_bar_x_at(length = 1, x = 0, y = 0) {
    

    translate ([shift(x) + bar_offset(x), shift(y) + bar_offset(y), 0]) 
        connector_bar(length);
}

module connector_bar_y_at(length = 1, x = 0, y = 0) {


    translate ([shift(x) + bar_offset(x), shift(y) + bar_offset(y), 0]) 
        rotate ([0, 0, 90]) 
            connector_bar(length );
}

// Create a connector bar of a given length , oriented along the x-axis
module connector_bar(l = 1) {
    translate([length(l) / 2 + (bar_width / 2 - bar_overlap), 0, connector_height / 2])
        union() {
                
            // The middle part of the connector. Only create, if it should be wider than 0
            if (bar_width > 0) {
                
                // Pre-calc length of the divider
                cyl_len = length(l) - bar_overlap * 2;
                
                // Build the actual divider itself
                scale ([cyl_len, bar_width - connector_margin, connector_height])  cube (1, true);
                
                // Add a triangular guide on top so the boxes can slide in place
                // translate([0,0, bar_width * 0.3660254 ]) 
                //    rotate ([60, 0, 0]) 
                //        rotate ([0, 90, 0]) 
                //            cylinder(c_height, bar_width / 2, bar_width / 2, true, $fn=3);
            }
            
            // Attach connectors to both sides of the middle part
            for (i = [1:l] ) {
                
               translate([conn_pos(i, l), -inner_radius + connector_overlap / 2, 0]) 
                    connectorX(connector_height, inner_radius);
                
               translate([conn_pos(i, l), inner_radius - connector_overlap / 2, 0]) 
                    connectorX(connector_height, inner_radius, true);
            }
        }
}



module box_at(width = 1, depth = 1, height = 1, wall_thickness = 1, x = 0, y = 0) {

    // x_offset = x != 0 ? length(x) : 0;
    // y_offset = y != 0 ? length(y) : 0;

    translate ([shift(x) + bar_offset(x), shift(y) + bar_offset(y), 0]) 
        box(width, depth, height, wall_thickness);
    
}

// function max(a,b) = a > b ? a : b;

// The complete box with all parts, centered and starting at height 0
module box(width = 1, depth = 1, height = 20, wall_thickness = 2) {
    
    // offset = max(bar_width / 2 - bar_overlap, 0);
    
    translate([length(width) / 2 + bar_adjust, length(depth) / 2 + bar_adjust, 0])
    intersection() {
        union() {
            // Bottom floor with connector cutouts
            difference() {
                
                // Bottom floor which will house the connectors
                bottom_floor_height = bottom_floor_height + top_floor_height / 2;
                
                translate ([0, 0, bottom_floor_height / 2])
                    scale ([length(width) - bar_overlap * 2, length(depth) - bar_overlap * 2, bottom_floor_height]) 
                        cube(1, true);
                
                // Connector cutouts
                union() {
                   
                    conn_offset = (bar_width + connector_overlap) / 2 - bar_overlap + outer_radius - inner_radius;
                    
                    c_height = 10 * total_floor_height;
                    
                    for ( i = [1:width] ) {
                        
                       translate([conn_pos(i, width), length(depth) / 2 - outer_radius + conn_offset, 0]) 
                        connectorX(c_height, outer_radius);
                        
                       translate([conn_pos(i, width), -(length(depth) / 2 - outer_radius + conn_offset), 0]) 
                           connectorX(c_height, outer_radius, true);
                    }

                    for ( i = [1:depth] ) {
                       translate([length(width) / 2 - outer_radius + conn_offset, conn_pos(i, depth), 0]) 
                           connectorY(c_height, outer_radius, false);
                        
                       translate([-(length(width) / 2 - outer_radius + conn_offset), conn_pos(i, depth), 0]) 
                           connectorY(c_height, outer_radius, true);
                    }
                }
            }


            // Upper floor
            translate ([0, 0, top_floor_height / 2 + bottom_floor_height + floor_distance]) 
                scale ([length(width), length(depth), top_floor_height]) 
                    cube(1, true);
            
            // Walls
            w_offset = (height - total_floor_height) / 2 + total_floor_height;
            translate ([0,  - length(depth) / 2 + wall_thickness / 2, w_offset]) 
                scale ([length(width), wall_thickness, height - total_floor_height]) 
                cube (1, true);
            
            translate ([0,  length(depth) / 2 - wall_thickness / 2, w_offset]) 
                scale ([length(width), wall_thickness, height - total_floor_height]) 
                    cube (1, true);

            translate ([ - length(width) / 2 + wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, length(depth), height - total_floor_height]) 
                    cube (1, true);

            translate ([ + length(width) / 2 - wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, length(depth), height - total_floor_height]) 
                    cube (1, true);

        }
        
        // Cut off the corners of the box
        if (!simplify) {
            roundedcube([length(width), length(depth), 2 * height], true, 2, "z");
        }
        
    }   
}

// A triangular connector
module connector(height = 1, radius = 1) {
    
    intersection() {

        // Basic connector shape is a triangle
        cylinder(height, radius, radius, true, $fn=3);

        if (!simplify) {
            // Round the corners of the triangle
            cylinder(height, radius * 0.8, radius * 0.8, true, $fn=12);
        }
    }

}

// A triangular connector, rotated for placement on the X axis
module connectorX(height = 1, radius = 1, mirrored = false) {
    
    angle = mirrored ? 30 : -30;
    rotate ([0,0,angle]) connector(height, radius);
    
}

// A triangular connector, rotated for placement on the Y axis
module connectorY(height = 1, radius = 1, mirrored = false) {
    
    angle = mirrored ? 60 : 0;
    rotate ([0,0,angle]) connector(height, radius);

}


// Higher definition curves for the cube
$fs = 0.01;

module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	module build_point(type = "sphere", rotate = [0, 0, 0]) {
		if (type == "sphere") {
			sphere(r = radius);
		} else if (type == "cylinder") {
			rotate(a = rotate)
			cylinder(h = diameter, r = radius, center = true);
		}
	}

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							build_point("sphere");
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							build_point("cylinder", rotate);
						}
					}
				}
			}
		}
	}
}