# csc-boxes

An OpenSCAD generator for customizable, stackable and connectable boxes for 3D-printing

## Overview

The script can generate boxes and connectors. The connectors are placed at the borders of 
each box and hold boxes together.

Every box is made up from a grid of square base units. Every base unit has one cutout in 
the bottom for a connector on the outside of the box. The size of each box is given as 
number of base units along the x and y axis.

Boxes can have an inset bottom. When matching the inset to the wall thickness, the boxes
become stackable. See the comments in the script parameters for more details.

## Getting started

Download the script, open in OpenSCAD, set the simplify parameter at the beginning to 'true',
un-comment the line *create_demo_box_set*
and run the script. This will create a set of boxes based on a 40mm base size with connector bars.

Feel free to experiment with the parameters in the top sections (marked by *Start Editing* and 
*Stop Editing* comments). 

Next, comment out the *create_demo_box_set* command and un-comment the *create_fitting_test();* 
line. Set the *simplify* parameter back to **false**. This will generate one connector bar and 
two half boxes without walls. These can be used to print and check how well the connectors
fit the cutouts in the boxes.

Experiment with the parameters for the box and connector geometry, if you want.

When you are satisfied with the geometry and want to start creating boxes, create one or
more boxes and/or connectors, export to STL and print.


## The *simplify* parameter

For printing, the boxes should have rounded corners and rounded connectors. However, displaying
the model with all this rounding slows down generation and responsiveness of the 3D viewer. 

Therefore the rounding can be switched off by setting the *simplify* parameter to **true**.

