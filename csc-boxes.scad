////////////////////////////////////////////////////////////////////////////////////
// Customizable connected boxes
//
// v4 - reduced base block size to 40mm, some modularization
// v5 - added divider_width into box size calculations, debug simplify switch
// v6 - organization and renaming
// v6.2 - modularization, placement of objects
// v6.3 - set useful starting values
// v6.4 - documentation
// v6.5 - code cleanup, moved modules
// v6.6 - grooved bottom for stackability
// v6.7 - added edge taper
// v6.7.1 - fixed partial overlap
// v6.8 - added label pocket
// v7.0 - added auto-calculation of bar width and overlap and connector size
//        CAUTION: Placement of connectors probably incompatible to earlier versions
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
simplify = true;

// This will be run once all variables have been initialized. Put your 
// wanted things here or uncomment one of the predefined functions (they
// are defined further down in the script).
module run() {

    // Create a set of containers and connector bars over a 9x9 area to
    // judge how they fit together.
    // Use 'simplify = true' to increase responsiveness of the viewer.
    create_demo_box_set_9x9();

    // Create a small smaple of connector and cutout to see how well they fit together
    // Useful for testing out new sizes and tolerances
    // create_fitting_test();

    // Create a single container with width, depth, height and wall thickness parameters
    // The box is placed at 0/0 and extends in positive directions.
    // box(width, depth, height);
    // box(1,2,30);
    
    // Create a box and move it by dx base units to the right (use negative values
    // to move to the left) and by dy base unit sizes along the y-axis.
    // box_at(width, depth, height, dx, dy);
    // box_at(2,2,40,3,2);

    // Create a connector bar in x or y direction with a given length (in base units).
    // The bar will begin at 0/0 and extend in positive direction and is then
    // moved by dx and dy base unit sizes along the x and y axis.
    // bar_x_at(length, dx, dy);
    // bar_x_at(2, 1, 2);

    // Create two boxes and a connector bar and place them spaced for direct printing
    // box_at(2,1,30,0,0);
    // bar_x_at(2, 0, 2);
    // box_at(2,2,30,0,3);
}


// Size of one unit, which has one connector
unit_size = 40;

////////////////////////////////////////////////////////////////////////////////////
// Box walls

// The thickness of the box walls
wall_thickness = 2.0;

// Add a 45-degree slope to the bottom of each inside wall. 
// This value controls the depth of the slope
// Possible values: 0 <= wall_edge_taper <= half of box width 
wall_edge_taper = 1.5;


////////////////////////////////////////////////////////////////////////////////////
// Box floor
//
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

////////////////////////////////////////////////////////////////////////////////////
// Connector bars
//
// The connectors are triangular shapes that connect the cutouts of two adjacent
// boxes. They can be attached to a connector bar (or divider). The connector 
// bar can sit between the boxes or partially or completely underneath the boxes.

// Width of the divider bar with the connectors. Set to zero to create only individual
// connector pieces.
// Possible value: 
// _bar_width >= 0, 
// _bar_width = -1 to set automatically to 2 * bar_overlap
bar_width = -1;

// How much the divider goes under the boxes. If this is greater than 0, the box
// must be printed with supports.
// Set _bar_overlap = _bar_width / 2 to avoid ending up with spaces between the boxes.
// Set your box wall_thickness to slightly less than the _bar_overlap to make the
// boxes stackable.
// Possible values: 
// 0 <= _bar_overlap <= _bar_width
// bar_overlap = -1 to set automatically to wall_thickness + 1/2 * connector_margin
bar_overlap = -1;

// How much the connectors should overlap
// When zero, the connectors will touch their edges in the middle of the
// connector bar. When increasing this value, the connectors will be moved towards
// each other, so they overlap in the connector bar
connector_overlap = 12;

// Set the size of the connectors here, represented as a circle radius.
// The cutouts for the connectors must not touch each other.
// For an overlap of 12-15 a divisor of 3.5 here works well.
// Set the value to -1 to enable auto calculation
connector_radius = -1;

// Size difference between radii of the connector and the cutouts in mm
connector_margin = 0.3;

////////////////////////////////////////////////////////////////////////////////////
// Label pockets
//
// Boxes can have a pocket for inserting labels. Deactivate the label pocket by setting
// label_max_width = 0;
// The pocket is always placed on the wall parallel to and farthest away from the x axis. 
// If you want it on another wall, just switch the x and y dimensions of the box.
// The vertical position is calculated so that there is room for another box to stack on top.

// Maximum width of the inside of the label pocket
label_max_width = 60;

// Thickness of the front wall of the label box
label_front = 0.6;

// Depth needed for the label
label_space = 1.0;

// Height of the overlapping bottom front part 
label_front_bottom = 2;

// Widht of the overlapping left and right front parts
label_front_side = 3;

// Height of the label pocket
label_height = 10;

// The left and right bars of the label pocket that connect the front plate to 
// the box can be merged into the box walls if the box becomes smaller than 
// the label_max_width.
// Possible values:
// true: merge sides into walls
// false: always keep the bars inside the box
label_hide_side_bars = true;

////////////////////////////////////////////////////////////////////////////////////
// Stop editing here. 
////////////////////////////////////////////////////////////////////////////////////

// Calculate some helper variables

_bar_overlap = (bar_overlap < 0 ? wall_thickness + connector_margin / 2 : bar_overlap);
echo(bar_overlap=_bar_overlap);

_bar_width = (bar_width < 0 ? 2 * _bar_overlap : bar_width);
echo(bar_width=_bar_width);

// Calculate maximum connector radius for the given other parameters
// u = unit_size
// w = bar_width
// o = bar_overlap
// v = connector_overlap
function radius(u, w, o, v) = 0.5 * (sqrt(2) * sqrt(4 * o * o - 4 * o * u - 4 * o * v - 4 * o * w + u * u + 2 * u * v + 2 * u * w + v * v + 2 * v * w + w * w) + 2 * o - u - v - w);
// solve {sqrt(2 * (us/2 + (bw / 2 - bo) + co/2 - r) ^ 2) == 2*r,r} 

_connector_radius = (connector_radius > 0 ? connector_radius : radius(unit_size, _bar_width, _bar_overlap, connector_overlap)); 

echo(radius=_connector_radius);

// Calculate total floor thickness from the individual layers
_floor_height = top_floor_height + connector_height + floor_distance;

// The height of the bottom part of the floor, this will encase the connectors 
_bottom_floor_height = connector_height + floor_distance;

// Size adjustment to account for bar width and overlap (two 1x1 boxes with a connector
// bar between them must take the same space as one 1x2 box)
_div_adjust = max(_bar_width - 2 * _bar_overlap, 0);

// Adjust position for wide bars (wider than the overlap on both sides)
_bar_adjust = max(_bar_width / 2 - _bar_overlap, 0);

// Calculate total box length for a given number of base units
function length(numUnits) = numUnits * unit_size + sign(numUnits) * (abs(numUnits) - 1) * _div_adjust;

// Radius of the cutout in the box floor
_outer_radius = _connector_radius + connector_margin / 2;

// Radius of the connector
_inner_radius = _connector_radius - connector_margin / 2;

// Total depth of the label
_label_depth = label_front + label_space;

// Include the left and right bars in the total label width
_label_width = label_max_width + 2 * wall_thickness;

// Position of the i-th connector 
function conn_pos(i, size) = (i - size / 2 - 0.5) * unit_size + (i - size / 2 - 0.5) * _div_adjust;

// Calculate how far a connector bar must be moved when placing in wanted position
function shift(num) = num != 0 ? length(num) : 0;

// Calculate how far a connector bar must be shifted to match the box cutouts
function bar_offset(num) = num != 0 ? sign(num) * max(_bar_width / 2 - _bar_overlap, 0) * 2 : 0;

// Everything ist set. Run the module with the user commands.
run();


module box_at(width = 1, depth = 1, height = 1, x = 0, y = 0) {

    translate ([shift(x) + bar_offset(x), shift(y) + bar_offset(y), 0]) 
        box(width, depth, height);
    
}

// The complete box with all parts, centered and starting at height 0
module box(width = 1, depth = 1, height = 20) {
    
    translate([length(width) / 2 + _bar_adjust, length(depth) / 2 + _bar_adjust, 0])
    intersection() {
        union() {
            // Bottom floor with connector cutouts
            difference() {
                
                // Bottom floor which will house the connectors
                _bottom_floor_height = _bottom_floor_height + top_floor_height / 2;
                
                translate ([0, 0, _bottom_floor_height / 2])
                union() {
                    // Create individual bottom parts for each unit
                    
                    x_offset =  - length(width) / 2 - length(1) / 2;
                    y_offset =  - length(depth) / 2 - length(1) / 2;
                    
                    for (i = [1:width]) {
                        for (j = [1:depth]) {
                            // Create one bottom piece and move it to it's unit position
                            translate ([x_offset + length(i), y_offset + length(j), 0])                     
                                scale ([unit_size - _bar_overlap * 2, unit_size - _bar_overlap * 2, _bottom_floor_height]) 
                                    cube(1, true);
                        }
                    }
                } 
                
                // Connector cutouts
                union() {
                   
                    conn_offset = _bar_adjust + connector_overlap / 2 - _connector_radius;
                    
                    c_height = 10 * _floor_height;
                    
                    for ( i = [1:width] ) {
                        
                       translate([conn_pos(i, width), length(depth) / 2 + conn_offset, 0]) 
                        connectorX(c_height, _outer_radius);
                        
                       translate([conn_pos(i, width), -(length(depth) / 2 + conn_offset), 0]) 
                           connectorX(c_height, _outer_radius, true);
                    }

                    for ( i = [1:depth] ) {
                       translate([length(width) / 2 + conn_offset, conn_pos(i, depth), 0]) 
                           connectorY(c_height, _outer_radius, false);
                        
                       translate([-(length(width) / 2 + conn_offset), conn_pos(i, depth), 0]) 
                           connectorY(c_height, _outer_radius, true);
                    }
                }
            }


            // Upper floor
            translate ([0, 0, top_floor_height / 2 + _bottom_floor_height + floor_distance]) 
                scale ([length(width), length(depth), top_floor_height]) 
                    cube(1, true);
            
            // Walls
            w_offset = (height - _floor_height) / 2 + _floor_height;
            translate ([0,  - length(depth) / 2 + wall_thickness / 2, w_offset]) 
                scale ([length(width), wall_thickness, height - _floor_height]) 
                cube (1, true);
            
            translate ([0,  length(depth) / 2 - wall_thickness / 2, w_offset]) 
                scale ([length(width), wall_thickness, height - _floor_height]) 
                    cube (1, true);

            translate ([ - length(width) / 2 + wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, length(depth), height - _floor_height]) 
                    cube (1, true);

            translate ([ + length(width) / 2 - wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, length(depth), height - _floor_height]) 
                    cube (1, true);

            // put a triangular edge at the bottom of each wall
            if (wall_edge_taper > 0) {

                edge_taper = wall_edge_taper + wall_thickness;
                
                // left:
                translate([- length(width) / 2, 0, _floor_height])
                    scale([edge_taper, length(depth), edge_taper])
                        angled_edge();
                    
                // right:
                translate([length(width) / 2, 0, _floor_height])
                    scale([edge_taper, length(depth), edge_taper])
                        rotate([0,0,180])
                        angled_edge();

                // top:
                translate([0, - length(depth) / 2, _floor_height])
                    scale([length(width), edge_taper, edge_taper])
                        rotate([0,0,90])
                            angled_edge();
                    
                // bottom:
                translate([0, length(depth) / 2, _floor_height])
                    scale([length(width), edge_taper, edge_taper])
                        rotate([0,0,270])
                            angled_edge();
                            
            }
            
            // Add a label pocket on the rear wall
            if (label_max_width > 0) {
                translate([0, length(depth) / 2 - wall_thickness, height - label_height - _bottom_floor_height - connector_margin]) 
                    label_pocket(min(min(_label_width, label_hide_side_bars ?  length(width) : length(width) - 2 * wall_thickness), length(width)));
            }
        }
        
        // Cut off the corners of the box
        if (!simplify) {
            roundedcube([length(width), length(depth), 2 * height], true, wall_thickness, "z");
        }
        
    }   
}

// Create a connector bar in x-direction and move it to the given x and y position
module bar_x_at(length = 1, x = 0, y = 0) {
    

    translate ([shift(x) + bar_offset(x), shift(y) + bar_offset(y), 0]) 
        connector_bar(length);
}

// Create a connector bar in y-direction and move it to the given x and y position
module bar_y_at(length = 1, x = 0, y = 0) {


    translate ([shift(x) + bar_offset(x), shift(y) + bar_offset(y), 0]) 
        rotate ([0, 0, 90]) 
            connector_bar(length );
}

// Create a connector bar of a given length , oriented along the x-axis
module connector_bar(l = 1) {
    
    translate([length(l) / 2 + _bar_adjust, 0, connector_height / 2])
        union() {
                
            // The middle part of the connector. Only create, if it should be wider than 0
            if (_bar_width > 0) {
                
                // Pre-calc length of the divider
                cyl_len = length(l) - _bar_overlap * 2;
                
                // Build the actual divider itself
                scale ([cyl_len, _bar_width - connector_margin, connector_height])  cube (1, true);
                
                // Add a triangular guide on top so the boxes can slide in place
                // translate([0,0, _bar_width * 0.3660254 ]) 
                //    rotate ([60, 0, 0]) 
                //        rotate ([0, 90, 0]) 
                //            cylinder(c_height, _bar_width / 2, _bar_width / 2, true, $fn=3);
            }
            
            // Attach connectors to both sides of the middle part
            for (i = [1:l] ) {
                
               translate([conn_pos(i, l), - _connector_radius + connector_overlap / 2, 0]) 
                    connectorX(connector_height, _inner_radius);
                
               translate([conn_pos(i, l), _connector_radius - connector_overlap / 2, 0]) 
                    connectorX(connector_height, _inner_radius, true);
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

// create a pocket for the rear wall. IT is aligned with the rear on
// the xz-plane, extending in -y. 
module label_pocket(width = 40) {

    translate ([0, -_label_depth / 2, -_label_depth / 2]) {
        intersection() {
            union() {

                // The bottom with a sloped overhang.
                scale([width, _label_depth, _label_depth])
                    rotate([90,0,270]) 
                        translate ([0,0,-0.5]) 
                            linear_extrude(height=1)
                                polygon(points=[[-0.5,-0.5],[0.5,0.5],[-0.5,0.5]]);

                side_width = label_front_side + wall_thickness;
                
                // Bottom front
                translate([0, - (_label_depth - label_front) / 2, (_label_depth + label_front_bottom) / 2])    
                    scale([width, label_front, label_front_bottom]) 
                    cube(1,true);

                // left front
                translate([-(width - side_width) / 2, - (_label_depth - label_front) / 2, (_label_depth + label_height) / 2])    
                    scale([side_width, label_front, label_height]) 
                        cube(1,true);

                // right front
                translate([(width - side_width) / 2, - (_label_depth - label_front) / 2, (_label_depth + label_height) / 2])    
                    scale([side_width, label_front, label_height]) 
                        cube(1,true);

                // left back
                translate([-(width - wall_thickness) / 2, 0, (_label_depth + label_height) / 2])    
                    scale([wall_thickness, _label_depth, label_height]) 
                        cube(1,true);

                // right back
                translate([(width - wall_thickness) / 2, 0, (_label_depth + label_height) / 2])    
                    scale([wall_thickness, _label_depth, label_height]) 
                        cube(1,true);

            }
            
            // Round of the sides 
            if (!simplify) {
                translate([0, _label_depth * 1.5, label_height / 2 + _label_depth / 2])
                    roundedcube([width, _label_depth, label_height + 2 * label_height], true, wall_thickness, "z");
            }
        }
    }
}


// Create two half 1x1 boxes without walls and a connector for quickly
// printing a test sample to judge the fitting of the connectors to
// the boxes.
module create_fitting_test() {
    
    // Setup one box in the origin location, mask out one half
    intersection() {
        box(1, 1, _floor_height);
        box_mask_connector();
    }
    
    // Setup a second box further down the x axis, mask out half of it
    translate ([shift(1.5) + bar_offset(1.5), shift(0) + bar_offset(0), 0]) 
        intersection() {
            box(1, 1, _floor_height);
            box_mask_connector();
        }

    // Put a connector between the boxes
    bar_y_at(1, 1.5, 0);
}

// A mask to hide half of a 1x1 box for the fitting test
module box_mask_connector() {
    
    translate([length(1) / 2, length(1) / 4, 0])
        translate([length(1) / 4 + _bar_adjust, length(1) / 4 + _bar_adjust, _floor_height / 2])
            scale([length(1) / 2, length(1), _floor_height]) 
                cube(1, true);
}

// Create one box with one connector bar
module create_box_with_bar(width = 1, depth = 1, height = 10) {
    
    box(1, 1, height);

    // Where to place the connector: 
    // make box and connector: fit connectors into cutouts on +y side:
    // (lengthY + _bar_width) / 2 - _bar_overlap
    y_offset = (lengthY + _bar_width) / 2 - _bar_overlap; 

    translate ([0, y_offset, 0]) 
        connector_bar();
        

}

// Create a set of boxes and connectors across all quadrants to check positioning 
// and fitting
module create_demo_box_set_9x9() {
    
    // top right
    bar_y_at(2, 0, 0);
    box(2,2,30);
    bar_y_at(3, 2, 0);
    box_at(3,1,30,-1,2);
    box_at(1,3,30,2,0);
    bar_x_at(2,0,2);

    // top left
    bar_x_at(4, -1, 0);
    box_at(1,1,30,-1,0);
    box_at(1,1,30,-1,1);
    bar_x_at(1, -1, 1);
    bar_y_at(5, -1, -3);
    box_at(2,3,30, -3, -1);
    bar_x_at(3, -3, 2);
    box_at(2,1,30, -3, 2);
    bar_y_at(1, -1, 2);

    
    // bottom left
    bar_y_at(1, 0, -1);
    box_at(1,1,30,-1,-1);
    box_at(2,2,30, -1, -3);
    box_at(2,2,30, -3, -3);
    bar_x_at(2, -3, -1);

    // bottom right
    box_at(2,1,30,1,-3);
    box_at(2,1,30,0,-1);
    box_at(1,1,30,1,-2);
    box_at(1,2,30,2,-2);
    bar_x_at(3, -1, -1);
    bar_x_at(2, 1, -2);
    bar_y_at(2, 2, -2);
    bar_y_at(2, 1, -3);
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

// Create a triangle lying on it's 90 degree angle, hypothenusis on the right
module angled_edge() {
    translate ([0,0.5,0]) 
        rotate([90,0,0]) 
            linear_extrude(height=1)
                polygon(points=[[0,0],[1,0],[0,1]]);
}

 
