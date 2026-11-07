$fn = 64;


module slider() {
    difference() {
        union() {
            // Section A: Top section (28mm x 54mm x 2mm)
            translate([10, 76, 0])
                cube([28, 54, 2]);
            
            // Section B: Bottom section (14mm x 56mm x 2mm)
            translate([24, 20, 0])
                cube([14, 56, 2]);
        }
        
        // 1. Central Notch Cutout
        translate([36, 63, -1])
            cube([3, 24, 4]);

        // 2. Bottom Hole (Section B): 
        // Centered at X = 31mm, perimeter is 6mm from Y = 20 (Center Y = 27mm)
        translate([33, 26, -1])
            cylinder(h = 4, d = 2);

        // 3. Top Hole (Section A): 
        // Centered at X = 24mm, perimeter is 6mm from Y = 130 (Center Y = 123mm)
        translate([26, 124, -1])
            cylinder(h = 4, d = 2);
    }
}
slider();


// Module for the custom bolt
module custom_bolt() {
    // Bolt Head: 4mm diameter, 2mm length
    cylinder(h = 2, d = 4, $fn = 30);
    
    // Bolt Body: 2mm diameter, 10mm length
    translate([0, 0, 2])
        cylinder(h = 10, d = 2, $fn = 30);
}

// Bolt 1 aligned with your first hole (Y = 68.5)
translate([5, 20, 2]) // Shifted X to 100 so the shaft passes through the 4mm hole + 5mm object
    rotate([0, 90, 0])
        custom_bolt();

// Bolt 2 aligned with your second hole (Y = 101.5)
translate([5, 30, 2])
    rotate([0, 90, 0])
        custom_bolt();

// Other bolts.
translate([5, 40, 2])
    rotate([0, 90, 0])
        custom_bolt();
translate([5, 50, 2])
    rotate([0, 90, 0])
        custom_bolt();
translate([5, 60, 2])
    rotate([0, 90, 0])
        custom_bolt();
translate([5, 70, 2])
    rotate([0, 90, 0])
        custom_bolt();

module backdoor() {
 
difference(){
    union() {
        // Notched Plate (73mm x 114mm x 2mm offset by X=1)
        translate([1, 0, 0]) {
            difference() {
                // Base plate
                cube([73, 114, 2]);
                
                // Front-Left Cutout (8mm on X, 2mm on Y)
                translate([-1, -1, -1])
                    cube([9, 3, 4]); 
                    
                // Back-Left Cutout (8mm on X, 2mm on Y, 110mm spacing)
                translate([-1, 112, -1])
                    cube([9, 3, 4]); 
            }
        }

        // Integrated Cylinder (2mm diameter, 118mm length)
        rotate([-90, 0, 0])
            translate([1, -1, -2])
                cylinder(h = 118, d = 2);
        translate([70, 46, 2])
            cube([2, 22, 10]);
    }
    
    translate([68,29,1])
    cylinder(h=4,d=2,center=true);
    translate([68,85,1])
    cylinder(h=4,d=2,center=true);
    }
}
translate([50,10,0])
rotate([0,0,0])
backdoor();

module hinge_plate() {
    union() {
        difference() {
            // Base plate assembly
            union() {
                // Left section: 10mm wide (X = 0 to 10), Y = 4 to 110mm
                translate([0, 4, 0])
                    cube([10, 106, 2]);
                
                // Right section: 65mm wide (X = 17 to 82mm)
                translate([17, 0, 0])
                    cube([65, 114, 2]);

                // Middle connection plate (X = 10 to 17mm)
                translate([10, 2, 0])
                    cube([7, 110, 2]);
            }
            
            // 1. Carve 8mm wide (X = 1 to 9), 20mm long (Y = 47 to 67) hole
            // Centered along Y-axis with 2mm solid borders along the X-edges
            translate([2, 47, -1])
                cube([8, 20, 4]);
        }

        // Hinge cylinder pin (centered at X = 11mm, Z = 1mm)
        translate([11, -2, 1])
            rotate([-90, 0, 0])
                cylinder(h = 118, d = 2);

        // 2. Add 6mm long rings at the ends of the 20mm cutout
        // Leaves a 6mm gap in the middle (from Y = 54mm to Y = 60mm)
        // Ring 1: Front end (Y = 47 to 53mm)
        translate([1, 47, 1])
            rotate([-90, 0, 0])
                    cylinder(h = 8, d = 4);

        // Ring 2: Rear end (Y = 61 to 67mm)
        translate([1, 59, 1])
            rotate([-90, 0, 0])
                    cylinder(h = 8, d = 4);  
    
}}


translate([10,220,0])
rotate([0,0,-90])
hinge_plate();

hole_pitch_y = 43.0;  
pin_diameter   = 2.85; 
cap_outer_dia = 5.5;   
cap_height = 3.0;

off_y = hole_pitch_y / 2;

module zero_tolerance_caps() {
    for (i = [0:3]) {
        translate([ (i % 2) * (cap_outer_dia + 3), floor(i / 2) * (cap_outer_dia + 3) - off_y, 0 ]) {
            difference() {
                cylinder(h = cap_height, d = cap_outer_dia);
                translate([0, 0, -0.5])
                    cylinder(h = cap_height + 1, d = pin_diameter);
            }
        }
    }
}

translate([140,70,0])
zero_tolerance_caps();


translate([130,100,0]){
difference(){

cube([30,54,2]);
    
    
union(){
        translate([8,22,1.2])
cube([16,12,1.8]);
translate([20,22,-1])
cube([5,12,3.2]);
}

}
}