// csc-boxes v1 - rectangular box with connector cutouts and connector bar

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
total_floor_thickness = 4;

// Space between connector and upper floor
floor_tolerance = 0.2;

// Width of the divider with the connectors
div_width = 3;

// Space between the connectors on the divider
div_inner = 2;

// How much the divider goes under the boxes (probably needs supports on the boxes)
div_overlap = 0;

connector_radius = unit / 6;

outer_radius = connector_radius * 1.1;
inner_radius = connector_radius * 0.9;

floor_thickness = (total_floor_thickness - floor_tolerance) / 2;

if (make_box) {
    union() {
        // lower floor with cutouts
        difference() {
            
            translate ([0, 0, floor_thickness])
                scale ([sizeX * unit - div_overlap * 2, sizeY * unit - div_overlap * 2, 2 * floor_thickness]) 
                    cube(1, true);
            
            union() {
               
                conn_offset = (div_width) / 2 - div_overlap;
                c_height = 10 * total_floor_thickness;
                for ( i = [1:sizeX] ) {
                    
                   translate([(i - sizeX / 2 - 0.5) * unit, unit * sizeY / 2 - outer_radius + conn_offset, 0]) 
                        cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                   translate([(i - sizeX / 2 - 0.5) * unit, - unit * sizeY / 2 + outer_radius - conn_offset, 0]) 
                        cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                }

                for ( i = [1:sizeY] ) {
                   translate([unit * sizeX / 2 - outer_radius + conn_offset, (i - sizeY / 2 - 0.5) * unit, 0]) 
                        cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
                   translate([- unit * sizeX / 2 + outer_radius - conn_offset, (i - sizeY / 2 - 0.5) * unit, 0]) 
                        cylinder(c_height, outer_radius, outer_radius, true, $fn=8);
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
}

if (make_connector) {
    
    y_offset = make_box ? (1 + sizeY * unit) : 0; 

translate ([0, y_offset, floor_thickness / 2]) 
        union() {
            if (div_width > 0) {
                scale ([sizeX * unit - div_overlap * 2, div_width, floor_thickness])  cube (1, true);
            }
            for ( i = [1:sizeX] ) {
                
               translate([(i - sizeX / 2 - 0.5) * unit, -inner_radius, 0]) 
                    cylinder(floor_thickness, inner_radius, inner_radius, true, $fn=8);
               translate([(i - sizeX / 2 - 0.5) * unit, inner_radius, 0]) 
                    cylinder(floor_thickness, inner_radius, inner_radius, true, $fn=8);
            }
        }

}