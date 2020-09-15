// csc-boxes v3 - triangular connectors

make_box = true;

make_connector = true;

// Size of one unit, which has one connector
unit = 20;

// Number of units in Y-direction
sizeX = 2;

// Number of units in Y-direction
sizeY = 1;

// Total height of the box in mm
height = 5;

// Thickness of the walls
wall_thickness = 2;

// Total thickness of the floor. Will be evenly distributed between cutout and complete part
total_floor_thickness = 1;

// Space between connector and upper floor
floor_tolerance = 0.2;

// Width of the divider with the connectors
div_width = 2;

// How much the connectors should overlap
connector_overlap = 2;

// How much the divider goes under the boxes (probably needs supports on the boxes)
div_overlap = 0;

// Size difference between radii of the connector and the cutouts in %
connector_tolerance = 10;

connector_radius = unit / 6;

outer_radius = connector_radius * (1 + connector_tolerance / 100);
inner_radius = connector_radius * (1 - connector_tolerance / 100);

floor_thickness = (total_floor_thickness - floor_tolerance) / 2;

if (make_box) {
    intersection() {
        union() {
            // lower floor with cutouts
            difference() {
                
                translate ([0, 0, floor_thickness])
                    scale ([sizeX * unit - div_overlap * 2, sizeY * unit - div_overlap * 2, 2 * floor_thickness]) 
                        cube(1, true);
                
                union() {
                   
                    conn_offset = (div_width + connector_overlap) / 2 - div_overlap + outer_radius - inner_radius;
                    
                    c_height = 10 * total_floor_thickness;
                    
                    for ( i = [1:sizeX] ) {
                        
                       translate([(i - sizeX / 2 - 0.5) * unit, unit * sizeY / 2 - outer_radius + conn_offset, 0]) 
                        connectorX(c_height, outer_radius);
                            //cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                        
                       translate([(i - sizeX / 2 - 0.5) * unit, - unit * sizeY / 2 + outer_radius - conn_offset, 0]) 
                           connectorX(c_height, outer_radius, true);
                            // cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                    }

                    for ( i = [1:sizeY] ) {
                       translate([unit * sizeX / 2 - outer_radius + conn_offset, (i - sizeY / 2 - 0.5) * unit, 0]) 
                           connectorY(c_height, outer_radius, false);
                            // cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                        
                       translate([- unit * sizeX / 2 + outer_radius - conn_offset, (i - sizeY / 2 - 0.5) * unit, 0]) 
                           connectorY(c_height, outer_radius, true);
                            // cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                    }
                }
            }
            // Upper floor
            translate ([0, 0, floor_thickness * 1.5 + floor_tolerance]) scale ([sizeX * unit, sizeY * unit, floor_thickness]) cube(1, true);
            
            // Walls
            w_offset = (height - total_floor_thickness) / 2 + total_floor_thickness;
            translate ([0,  - sizeY * unit / 2 + wall_thickness / 2, w_offset]) 
                scale ([sizeX * unit, wall_thickness, height - total_floor_thickness]) 
                cube (1, true);
            
            translate ([0,  sizeY * unit / 2 - wall_thickness / 2, w_offset]) 
                scale ([sizeX * unit, wall_thickness, height - total_floor_thickness]) 
                    cube (1, true);

            translate ([ - sizeX * unit / 2 + wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, sizeY * unit, height - total_floor_thickness]) 
                    cube (1, true);

            translate ([ + sizeX * unit / 2 - wall_thickness / 2, 0, w_offset]) 
                scale ([wall_thickness, sizeY * unit, height - total_floor_thickness]) 
                    cube (1, true);

        }
        
        // Cut off the corners of the box
        roundedcube([sizeX * unit, sizeY * unit, 2 * height], true, 2, "z");
        
    }   
}

if (make_connector) {
    
    y_offset = make_box ? (sizeY * unit + div_width) / 2 : 0; 

    translate ([0, y_offset, floor_thickness / 2]) 
        union() {
            if (div_width > 0) {
                scale ([sizeX * unit - div_overlap * 2, div_width, floor_thickness])  cube (1, true);
            }
            for ( i = [1:sizeX] ) {
                
               translate([(i - sizeX / 2 - 0.5) * unit, -inner_radius + connector_overlap / 2, 0]) 
                    connectorX(floor_thickness, inner_radius);
                    // cylinder(floor_thickness, inner_radius, inner_radius, true, $fn=8);
                
               translate([(i - sizeX / 2 - 0.5) * unit, inner_radius - connector_overlap / 2, 0]) 
                    connectorX(floor_thickness, inner_radius, true);
            }
        }

}

module connector(height = 1, radius = 1) {
    
    intersection() {
        cylinder(height, radius, radius, true, $fn=3);
        cylinder(height, radius * 0.8, radius * 0.8, true, $fn=12);
    }

}


module connectorX(height = 1, radius = 1, mirrored = false) {
    
    angle = mirrored ? 30 : -30;
    rotate ([0,0,angle]) connector(height, radius);
    
}


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