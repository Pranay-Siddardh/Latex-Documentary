$fn = 64;

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


cube([198, 114, 2]); // Base plate

// Main box structure
difference(){
    translate([0, 56, 2])
        cube([88, 2, 70]); // Left box wall
    translate([-1,55,2])
    cube([13,4,2]);
    translate([-1,55,56])
    cube([9,4,8]);
    translate([8,57,60])
    rotate([90,0,0])
    cylinder(h=4,d=8,center=true);
    translate([40,57,18])
    rotate([90,0,0])
    cylinder(h=4,d=10,center=true);
}

//important
difference(){
union(){
translate([88, 56, 2]) cube([12, 2, 34]); // Left wall extension
translate([90, 58, 2]) cube([10, 2, 32]);
}
translate([90,54,8]) cube([8,8,8]);
}

translate([0, 112, 2]) cube([0, 112, 2]); // Left box back reference fix

difference(){
translate([0, 112, 2]) cube([88, 2, 70]);
    translate([-1,111,4])
    cube([5,4,8]);
    translate([4,113,8])
    rotate([90,0,0])
    cylinder(h=4,d=8,center=true);
    
}

// Left box back
translate([86, 58, 2]) cube([2, 54, 70]); // Left box  

difference(){
translate([0, 56, 72]) cube([88, 58, 2]); // Left box ceiling
    translate([48,60,71])
    cube([6,6,10]);
    }

// Secondary box structure
translate([0, 0, 2]) cube([78, 2, 70]); // Secondary front wall

difference(){
translate([76, 2, 2]) cube([2, 54, 70]); // Secondary side wall
  translate([74,44,8]) cube([8,8,8]);
  translate([75,20,48])
cube([4,16,8]);
}

translate([0, 0, 72]) cube([78, 56, 2]); // Secondary ceiling plate
translate([0, 2, 36]) cube([76, 54, 2]); // Secondary shelf plate

// Right-side perimeter walls
translate([76, 0, 2]) cube([122, 2, 34]); // Right front wall
translate([86, 112, 2]) cube([112, 2, 34]); // Right back wall
translate([196, 2, 2]) cube([2, 110, 34]); // Right outer wall

difference(){
// 34mm high wall at X = 128
translate([128, 2, 2]) cube([2, 110, 32]); 
translate([127,8,6]) cube([4,10,8]);
}


// --- L-Shaped Compartment Inner Padding Lining (32mm height, 2mm thick, 6 non-overlapping segments) ---
difference(){
union(){
// Protrusion closing wall
translate([98, 2, 2]) cube([2, 54, 34]); // New compartment divider
translate([100, 4, 2]) cube([2, 56, 32]);
}
translate([97,8,6]) cube([6,10,8]);

}

translate([100, 2, 2]) cube([16, 2, 32]);  
translate([88, 110, 2]) cube( [28, 2, 32]);
translate([88, 58, 2]) cube([2, 52, 32]);
translate([102, 70, 2]) cube([4, 2, 32]);
translate([102, 98, 2]) cube([4, 2, 32]);


difference(){
    // 1. Your cube (Starts at X=104, ends at X=108. Width = 4)
    translate([104, 62, 2]) 
        cube([4, 10, 32]);
    
    // 2. The corrected cylinder
    translate([102, 68.5, 8.4]) // Changed X to 102 so it starts outside the cube
        rotate([0, 90, 0])       // Changed rotation to point directly along the X-axis
            cylinder(h = 8, d = 2); // Increased height to 8 so it extends past the cube
}

//Servo Holder
    


difference(){

translate([104, 98, 2]) cube([4, 12, 32]);
    
translate([102,101.5, 8.4]) // Center the cylinder and overlap the Y-axis
        rotate([0, 90, 0])  // Rotate 90 degrees around X to lie flat along Y
            cylinder(h = 8, d = 2); // Height is longer than the block to clear faces
}


module hinge(){
        difference() {
            // 1. Base Cylinder (6mm diameter, 2mm thickness)
            cylinder(h = 2, d = 6);
            
            // 2. Removes bottom half (Y < 0) to form the semi-disk
            translate([-5, -10, -1])
                cube([10, 10, 4]);
            
            // 3. Tangent hole (2mm diameter touching top edge at Y = 2)
            translate([0, 1, -1])
                cylinder(h = 4, d = 2);
        }
        }

module backhinge() {
        difference() {
            // 1. Base Cylinder (6mm diameter, 2mm thickness)
            cylinder(h = 2, d = 6);
            
            // 2. Removes one quadrant (X < 0, Y < 0) to leave 3/4 circle
            translate([-5, -5, -1])
                cube([5, 5, 4]);
            
            // 3. Tangent hole (2mm diameter touching top edge at Y = 2)
            translate([0, 1, -1])
                cylinder(h = 4, d = 2);
        }
}


// Main Object Group
translate([129, 2, 36])
    rotate([90, 0, 0])
        hinge();

translate([129, 114, 36]) 
    rotate([90, 0, 0]) hinge();

translate([0, 2, 73]) 
    rotate([90, -90, 0]) 
    backhinge();
;

translate([0, 114, 73]) 
    rotate([90, -90, 0]) backhinge();

module cube_with_center_hole() {
    difference() {
        // 1cm x 1cm x 1cm base cube (10mm x 10mm x 10mm)
        cube([8, 8, 8], center = true);
        
        // 2mm diameter through-hole centered along Z axis
        cylinder(h = 12, d = 2, center = true);
    }
}

// Call the module
translate([4,85,6])
rotate([90,0,90])
cube_with_center_hole();

translate([4,29,6])
rotate([90,0,90])
cube_with_center_hole();

translate([109,8,30])

cube_with_center_hole();


translate([102,106,30])

cube_with_center_hole();

module pulley() {
    difference() {
        union() {
            // 1. Main cylinder body: 10mm tall, 8mm diameter
            cylinder(h = 10, d = 8);
            
            // 2. Base Flange: Spreads shear strain across wall connection
            cylinder(h = 2, d = 12);
            
            // 3. Structural Support Ribs (Gussets)
            // Placed at 45-degree offsets to avoid the 0/90 degree hole exits
            for (a = [45, 135, 225, 315]) {
                rotate([0, 0, a])
                    translate([3.5, -1, 2])
                        // Triangular rib: 2mm wide, 2mm projection, 2.5mm tall
                        rotate([90, 0, 0])
                            linear_extrude(height = 2, center = true)
                                polygon(points = [[0, 0], [2, 0], [0, 2.5]]);
            }
        }
        
        // Smooth 90-degree curved hole (Unobstructed at Z = 5mm)
        translate([4, 4, 5])
            rotate([0, 0, 180])
                rotate_extrude(angle = 90)
                    translate([4, 0, 0])
                        circle(d = 2);
    }
}

translate([128, 57, 10])
    rotate([0, -90, 0])
        pulley();








translate([74,60,74])
rotate([0,0,90])

union(){

difference(){
cube([50,26,2]);
    translate([0,20,-1]) cube([6,6,4]);
}

difference(){
union(){
translate([0,-2,0]){
cube([50,2,32]);
    translate([-2,-2,0])
    cube([54,2,34]);
    }}
    //translate()
    rotate([90,90,0])
    translate([-13,11,-1])
    cylinder(h=6,d=18);
    rotate([90,90,0])
    translate([-13,39,-1])
    cylinder(h=6,d=18);
    translate([24, -5,29.2])
    cube([2.8, 6, 2.8+0.001]);
}
translate([0,26,0]){
cube([50,2,32]);
    translate([-2,+2,0])
    cube([54,2,34]);}
translate([50,-2,0]){
cube([2,30,32]);
    translate([2,-2,0])
    cube([2,34,34]);
    }
translate([-2,-2,0]){
cube([2,30,32]);
    translate([-2,-2,0])
    cube([2,34,34]);
}


rotate([90,0,0])
translate([0,2,-6])
linear_extrude(height = 2) {
    polygon(points = [
        [0, 0],   // Right-angle vertex at origin
        [4, 0],   // 4mm along X-axis
        [0, 4]    // 4mm along Y-axis
    ]);
}


rotate([90,0,0])
translate([0,2,-10])
linear_extrude(height = 2) {
    polygon(points = [
        [0, 0],   // Right-angle vertex at origin
        [4, 0],   // 4mm along X-axis
        [0, 4]    // 4mm along Y-axis
    ]);
    }
translate([120,16,-68])
rotate([90,0,180])
translate([70,70,-8])
linear_extrude(height = 2) {
    polygon(points = [
        [0, 0],   // Right-angle vertex at origin
        [4, 0],   // 4mm along X-axis
        [0, 4]    // 4mm along Y-axis
    ]);
}

translate([120,16,-68])
rotate([90,0,180])
translate([70,70,-12])
linear_extrude(height = 2) {
    polygon(points = [
        [0, 0],   // Right-angle vertex at origin
        [4, 0],   // 4mm along X-axis
        [0, 4]    // 4mm along Y-axis
    ]);
} 
}






translate([40,-10,2])
rotate([0,0,90])
union(){
hole_pitch_x = 20.5;  
hole_pitch_y = 43.0;  
pcb_hole_dia = 3.0;   

pillar_height  = 6.0;  
pin_ext_height = 6.0;  
pin_diameter   = 2.85; 
pillar_outer_dia = 5.5; 

off_x = hole_pitch_x / 2;
off_y = hole_pitch_y / 2;


translate([hole_pitch_x + 15, 0, 0]) 


    for (x = [-off_x, off_x]) {
        for (y = [-off_y, off_y]) {
            translate([x, y, 0]) {
                cylinder(h = pillar_height, d = pillar_outer_dia);
                translate([0, 0, pillar_height])
                    cylinder(h = pin_ext_height, d = pin_diameter);
            }
        }
}
}


translate([0,2,46])
cube([74,4,2]);

translate([0,2,51])
cube([74,4,2]);

translate([0,52,46])
cube([74,4,2]);

translate([0,52,51])
cube([74,4,2]);


translate([118,0,36])
hinge_plate();

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
translate([-2,0,74])
rotate([0,90,0])
backdoor();


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
translate([76,-18,34])
slider();

translate([76,112,106])
rotate([0,0,180])
difference(){
cube([30,54,2]);

union(){
        translate([8,22,1.2])
cube([16,12,1.8]);
translate([20,22,-1])
cube([5,12,3.2]);
}

}


