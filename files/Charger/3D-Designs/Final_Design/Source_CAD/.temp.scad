$fn = 64; 
eps = 0.1; // Margin to eliminate coplanar subtraction faces
o = 0.02;  // Small overlap for internal solid joints

module hole_tab(){
    union() {
        cube([8, 8, 4]);

        translate([4, 8, 0]) {
            difference() {
                cylinder(h = 4, r = 4);
                translate([-5, -9 - eps, -eps])
                    cube([10, 9 + eps, 4 + 2*eps]); 
            }
        }
    }
}

module sock(pos) {
    difference() {
        translate(pos)
            cube([6, 6, 6]);
        translate([pos[0] + 3, pos[1] + 3, pos[2] + 3])
            rotate([0, 90, 0]) 
                cylinder(h = 6 + 2*eps, d = 2, center = true); 
    }
}

// Wrap the entire model in a single root union
union() {

    // Base & Top Plates (slightly extended along Z to overlap wall junctions)
    translate([-20, 0, 0]) cube([106, 130, 2 + o]);
    translate([-20, 0, 90 - o]) cube([106, 130, 2 + o]);

    // Internal Horizontal Divisions
    translate([-18, 56, 62]) cube([82, 130-58, 2]);
    translate([-18, 56, 30]) cube([82, 130-58, 2]);
    translate([-18, 56, 20]) cube([72, 14, 2]);
    translate([-18, 114, 24]) cube([72, 4, 2]);

    rotate([90, 0, 0])
        translate([-18, 22, -120])
            cube([72, 4, 2]);

    translate([-18, 64, 24]) cube([72, 6, 2]);
    translate([-18, 114, 20]) cube([72, 14, 2]);

    rotate([90, 0, 0])
        translate([-18, 22, -66])
            cube([72, 4, 2]);

    translate([54, 64, 20]) cube([2, 4, 6]);
    translate([54, 116, 20]) cube([2, 4, 6]);

    // Main Front Wall
    translate([-20, 0, 0])
    difference(){
        translate([0, 0, 2 - o])
            cube([2, 130, 88 + 2*o]);

        translate([2, 64, 0])    
            rotate([0, -90, 0])
                translate([34, 10, 0]){
                    union(){
                        translate([8, 28, 1.2]) cube([16, 12, 1.8]);
                        translate([20, 28, -1 - eps]) cube([5, 12, 3.2 + 2*eps]);
                    }

                    translate([0, -20, 0])
                        union(){
                            translate([8, 16, 1.2]) cube([16, 12, 1.8]);
                            translate([20, 16, -1 - eps]) cube([5, 12, 3.2 + 2*eps]);
                        }
                }

        translate([1, 92, 56])
            rotate([0, -90, 0])
                cylinder(h = 4 + eps, d = 3.2, center = true);

        translate([1, 92, 50])
            rotate([0, -90, 0])
                cylinder(h = 4 + eps, d = 3.2, center = true);

        translate([-1 - eps, 77, 17])
            cube([4 + 2*eps, 16, 10]);
    }

    // Main Back Wall
    translate([90, 0, 106])
    rotate([90, 90, 90])
    difference(){
        translate([104, 0, 2])
            cube([2, 130, 88]);

        translate([104 - eps, 25, 5])
            rotate([0, 90, 0])
                cylinder(d = 2, h = 4 + 2*eps, center = true);

        translate([104 - eps, 107, 5])
            rotate([0, 90, 0])
                cylinder(d = 2, h = 4 + 2*eps, center = true);

        translate([104 - eps, 25, 87])
            rotate([0, 90, 0])
                cylinder(d = 2, h = 4 + 2*eps, center = true);

        translate([104 - eps, 107, 87])
            rotate([0, 90, 0])
                cylinder(d = 2, h = 4 + 2*eps, center = true);
    }

    // Screw Sockets
    block_positions = [
        [78, 22, 2],
        [78, 22, 84],
        [78, 104, 2],
        [78, 104, 84]
    ];

    for (p = block_positions) {
        sock(p);
    }

    // Right Wall
    translate([-20, 0, 0])
    difference(){
        translate([2, 0, 2 - o])
            cube([102, 2, 88 + 2*o]);
        
        translate([104, 3, 2])
            rotate([90, -90, 0])
                hole_tab();
     
        // Wall slots extended on both sides of the Y boundary (-eps to 2+eps)
        for (z = [40, 44, 48, 52, 70, 74, 78, 82])
            translate([6, -eps, z]) cube([72, 2 + 2*eps, 2]);

        for (z = [6, 10, 14])
            translate([6, -eps, z]) cube([64, 2 + 2*eps, 2]);
    }

    // Center Wall 
    translate([-20, 0, 0])
    difference(){
        translate([2, 54, 2 - o])
            cube([102, 2, 88 + 2*o]);
        
        translate([104, 57, 10])
            rotate([90, -90, 0])
                hole_tab();

        for (z = [38, 42, 46, 50, 68, 72, 76, 80, 4, 8, 12])
            translate([12, 54 - eps, z]) cube([72, 2 + 2*eps, 2]);
    }

    // Side Door Wall
    difference(){
        translate([-18, 128, 2 - o])
            cube([102, 2, 88 + 2*o]);

        for (z = [38, 42, 46, 50, 68, 72, 76, 80, 4, 8, 12])
            translate([-8, 128 - eps, z]) cube([72, 2 + 2*eps, 2]);
    }

    // Internal Compartments
    translate([-18, 84, 32]) cube([82, 2, 14]);
    translate([62, 56, 32])  cube([2, 72, 12]);
    translate([62, 56, 64])  cube([2, 72, 12]);
    translate([-18, 88, 64]) cube([82, 2, 14]);

    translate([50, 12, 2])   cube([2, 42, 6]);
    translate([62, 2, 56])   cube([2, 52, 8]);
    translate([-18, 21, 60]) cube([82, 10, 2]);
    translate([18, 2, 60])   cube([10, 52, 2]);
}