////////////////////////////////////////////////////////////////////////////////////
// Customizable connected boxes
//
// v4 - reduced base block size to 40mm, some modularization
// v5 - added divider_width into box size calculations, debug simplify switch
// v6 - organization and renaming
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
// Start editing here
////////////////////////////////////////////////////////////////////////////////////

// First select what should be made:

// Create the actual box. If make_connector is also true, the connector will be put next 
// to the box to judge the fitting
make_box = true;

// Create a connector. If make_box is also true, the fitting can be judged
make_connector = true;

// Set make_box and make_connector to false to print a fitting test sample

// Set both make_box and make_connector to true to view how the connectors fit into
// the cutouts in the container bottom.


// Each box is made up from a grid of x * y square units. Set the base unit size
// and the number of units in X and Y direction next. Each unit will have a cutout 
// for a connector on the outside.

// Size of one unit, which has one connector
unit_size = 20;

// Number of units in X-direction.
// This value is also used when making a connector bar.
box_width = 2;

// Number of units in Y-direction
// This value is not used for the connector bar
box_depth = 1;

// Total height of the box in mm
box_height = 3;

// Thickness of the walls in mm
wall_thickness = 1;


// The floor is made up of three parts. The upper_floor is the visible floor 
// at the bottom of the box.The bottom_floor below that has cutout where the
// connectors fit in. The heigt of the bottom floor part is equal to the height
// (or thickness) of the connectors plus some distance so they don't touch.

// Thickness of the upper floor part. This can be rather thin, as it only
// covers the cutouts. 
top_floor_height = 0.8;

// Thickness of the connector bar and connectors
connector_height = 1;

// Space between connector and upper floor
floor_distance = 0.2;

// The connectors are triangular shapes that connect the cutouts of two adjacent
// boxes. They can be attached to a connector bar (or divider), but that will add 
// a gap between the boxes. Also it will complicated calculations for the
// box dimensions and connector positions...

// Width of the divider bar with the connectors. Set to zero to create only individual
// connector pieces.
bar_width = 4;

// How much the connectors should overlap
// When zero, the connectors will touch their edges in the middle of the
// divider bar. When increasing this value, the connectors will be moved towards
// each other, so they overlap in the divider bar
connector_overlap = 5;

// You might want to adjust this value (the connector size) when changing the connector 
// overlap above. The cutouts for the connectors must not touch each other.
// For an overlap of 15 a divisor of 3.5 here works well.
connector_radius = unit_size / 3.5;

// How much the divider goes under the boxes (probably needs supports on the boxes)
bar_overlap = 2;

// Size difference between radii of the connector and the cutouts in mm
connector_margin = 0.5;

////////////////////////////////////////////////////////////////////////////////////
// Stop editing here
////////////////////////////////////////////////////////////////////////////////////

// Debugging:
simplify = false;

// Calculate some helper variables
sizeX = (make_box || make_connector) ? box_width : 1;
sizeY = (make_box || make_connector) ? box_depth : 1;

// Calculate total floor thickness from the individual layers
total_floor_thickness = top_floor_height + connector_height + floor_distance;

// The height of the bottom part of the floor, this will encase the connectors 
bottom_floor_thickness = connector_height + floor_distance;

div_adjust = bar_width - 2 * bar_overlap;

lengthX = sizeX * unit_size + (sizeX - 1) * div_adjust;
lengthY = sizeY * unit_size + (sizeY - 1) * div_adjust;

outer_radius = connector_radius + connector_margin / 2;
inner_radius = connector_radius - connector_margin / 2;

height = (make_box || make_connector) ? box_height : total_floor_thickness;

// Make the box
intersection() {    
    box();
    
    if (make_box) {
        box_mask_outerlimits(); 
    } else {
        if (make_connector) { 
            box_mask_hide(); 
        } else {
            box_mask_connector();
        }
    }
    
}

// Make the connector bar
if (make_connector || ! make_box) {
    
    // Where to place the connector: 
    // make box and connector: fit connectors into cutouts on +y side
    // only connector bar: keep in center
    // fitting test: place connector next to box cutout
    y_offset = make_box ? (lengthY + bar_width) / 2 - bar_overlap : ( make_connector ? 0 : unit_size); 

    translate ([0, y_offset, connector_height / 2]) 
        connector_bar();
        

}


module connector_bar() {
    union() {
            
        // The middle part of the connector. Only create, if it should be wider than 0
        if (bar_width > 0) {
            
            // Pre-calc length of the divider
            cyl_len = lengthX - bar_overlap * 2;
            
            // Build the actual divider itself
            scale ([cyl_len, bar_width - connector_margin, connector_height])  cube (1, true);
            
            // Add a triangular guide on top so the boxes can slide in place
            // translate([0,0, bar_width * 0.3660254 ]) 
            //    rotate ([60, 0, 0]) 
            //        rotate ([0, 90, 0]) 
            //            cylinder(c_height, bar_width / 2, bar_width / 2, true, $fn=3);
        }
        
        // Attach connectors to both sides of the middle part
        for (i = [1:sizeX] ) {
            
           translate([conn_pos(i, sizeX), -inner_radius + connector_overlap / 2, 0]) 
                connectorX(connector_height, inner_radius);
            
           translate([conn_pos(i, sizeX), inner_radius - connector_overlap / 2, 0]) 
                connectorX(connector_height, inner_radius, true);
        }
    }
}

// Some boxes to mask out the needed parts of the box

// Enclose the complete box, nothing is masked out
module box_mask_outerlimits() {
    translate ([0, 0, height / 2]) 
        scale ([lengthX, lengthY, height]) 
            cube (1, true);
}

// 
module box_mask_hide() {
    translate([lengthX, lengthY, 0]) cube(0.01, true);
}

module box_mask_connector() {
    translate([0, outer_radius,total_floor_thickness / 2])
        scale([outer_radius * 2, outer_radius * 2, total_floor_thickness]) cube(1, true);
}

// The complete box with all parts, centered and starting at height 0
module box() {
    intersection() {
        union() {
            // Bottom floor with connector cutouts
            difference() {
                
                // Bottom floor which will house the connectors
                bottom_floor_height = bottom_floor_thickness + top_floor_height / 2;
                translate ([0, 0, bottom_floor_height / 2])
                    scale ([lengthX - bar_overlap * 2, lengthY - bar_overlap * 2, bottom_floor_height]) 
                        cube(1, true);
                
                // Connector cutouts
                union() {
                   
                    conn_offset = (bar_width + connector_overlap) / 2 - bar_overlap + outer_radius - inner_radius;
                    
                    c_height = 10 * total_floor_thickness;
                    
                    for ( i = [1:sizeX] ) {
                        
                       translate([conn_pos(i, sizeX), lengthY / 2 - outer_radius + conn_offset, 0]) 
                        connectorX(c_height, outer_radius);
                            //cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                        
                       translate([conn_pos(i, sizeX), -(lengthY / 2 - outer_radius + conn_offset), 0]) 
                           connectorX(c_height, outer_radius, true);
                            // cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                    }

                    for ( i = [1:sizeY] ) {
                       translate([lengthX / 2 - outer_radius + conn_offset, conn_pos(i, sizeY), 0]) 
                           connectorY(c_height, outer_radius, false);
                        
                       translate([-(lengthX / 2 - outer_radius + conn_offset), conn_pos(i, sizeY), 0]) 
                           connectorY(c_height, outer_radius, true);
                    }
                }
            }


            // Upper floor
            translate ([0, 0, top_floor_height / 2 + bottom_floor_thickness + floor_distance]) 
                scale ([lengthX, lengthY, top_floor_height]) 
                    cube(1, true);
            
            // Walls
            w_offset = (height - total_floor_thickness) / 2 + total_floor_thickness;
            translate ([0,  - lengthY / 2 + wall_thickness / 2, w_offset]) 
                scale ([lengthX, wall_thickness, height - total_floor_thickness]) 
                cube (1, true);
            
            translate ([0,  lengthY / 2 - wall_thickness / 2, w_offset]) 
                scale ([lengthX, wall_thickness, height - total_floor_thickness]) 
                    cube (1, true);

            translate ([ - lengthX / 2 + wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, lengthY, height - total_floor_thickness]) 
                    cube (1, true);

            translate ([ + lengthX / 2 - wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, lengthY, height - total_floor_thickness]) 
                    cube (1, true);

        }
        
        // Cut off the corners of the box
        if (!simplify) {
            roundedcube([lengthX, lengthY, 2 * height], true, 2, "z");
        }
        
    }   
}

function conn_pos(i, size) = (i - size / 2 - 0.5) * unit_size + (i - size / 2 - 0.5) * div_adjust;

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