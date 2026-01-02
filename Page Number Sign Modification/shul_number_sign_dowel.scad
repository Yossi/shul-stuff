// this is a .scad file intended to be opened with OpenSCAD or a similar program.

/*
  Instructions:

  1. Install OpenSCAD from https://openscad.org/ if you don't have it already.
  2. Open this file in OpenSCAD.
  3. Adjust the measurements near the top of the file to match your sign dimensions if necessary. Remember to save.
  4. Render the model by pressing F6 or going to Design > Render.
  5. Export the rendered model as an STL file by pressing F7 or going to File > Export > Export as STL.
  6. Use the STL file with your preferred slicing software to prepare it for 3D printing.

  Note: The dowel is designed to fit into a sign with specific window and frame dimensions.
        Make sure to measure your sign accurately and adjust the parameters accordingly.
*/

/*

  Representation of the sign layout:

 ╭window_width
┏┷┯━┯━┓
┃ │ │ ┃
┡━┿━┷━┛
│ ╰inner_frame
╰outer_frame

  Representation of the dowel:

        ╭──────────These cones should fit flush back to back over an inner_frame without sticking out over the window holes.
_____╱││╲_____
     ╲││╱╰─────────This spot should line up with the edge of the window.
═════╗  ╔═════
     ║  ╟───inner_frame width
  ╷  ║  ║  ╷
  ╰──╢  ╟──┴─partial representation of window space

*/


// measurements in inches
in_window_width = 6;
in_outer_frame = 1.2;
in_inner_frame = .8;

// converting to mm
to_mm = 25.4;
window_width = in_window_width * to_mm;
outer_frame = in_outer_frame * to_mm;
inner_frame = in_inner_frame * to_mm;

// rest of these measurements in mm
radius = 7; // dowel radius. comes from the size of the OEM plastic stick-on retrofit. both raise the rings about 7mm.
big_radius = 25; // big radius for the cone. should be at least too big for a ring to slip over.
length = window_width/2; // length of the dowel. half the width of a window.
slice_gap = 2.2; // thickness of the metal the sign is made of. 0.2mm added to account for printer imperfections. adjust if your printer necessitates it.
chamfer_size = 1.2; // size of the chamfer on the slot. makes it easier to insert the dowel on to the sign.
resolution = 100; // higher number = smoother cylinder. too high = slow rendering. 100 is just fine



module Frame(windows) {
    full_width = windows*window_width + 2*outer_frame + ((windows-1)*inner_frame);

    rotate([0,-90,-90])
    difference(){
        cube([full_width ,50,.1]);

        for (i = [0:windows-1])
            translate([outer_frame + i * (window_width + inner_frame), -.1, -.5])
            cube([window_width, 52, 1]);
    }
}

module Slot(length, radius) { // creates a slot cutout
    translate([radius/2,0,0])
    cube([radius + 0.1, slice_gap, length + 1], center=true);

    // chamfers
    translate([radius, slice_gap/2, 0])
    rotate([0, 0, 45])
    cube([chamfer_size, chamfer_size, length + 1], center=true);

    translate([radius, -slice_gap/2, 0])
    rotate([0, 0, 45])
    cube([chamfer_size, chamfer_size, length + 1], center=true);
}

module Dowel(length, radius) { // creates a dowel with the slot cutout
    difference(){
        cylinder(h=length, r=radius, $fn=resolution, center=true);
        Slot(length, radius);
    }
}

module Cone(length) { // creates a cone for recentering the hanging number cards a little bit
    difference() {
        cylinder(r1=big_radius, r2=radius, h=length, $fn=resolution, center=true);
        Slot(length, big_radius);
    }
}



// creates a mockup of a horizontal slice of the sign with 3 windows.
// the * prefix makes it commented out. change it to # to make it partially transparent.
// only for helping visualize the dowel placement. remember to remove by changing back to * before rendering the stl for printing.
*Frame(3); // change the number to match the number of windows on your sign. doesnt really matter at all though.


translate([0, 0, length/2 + outer_frame])
Dowel(length, radius);


translate([0, 0, inner_frame/4+outer_frame-inner_frame/2])
Cone(inner_frame/2);
