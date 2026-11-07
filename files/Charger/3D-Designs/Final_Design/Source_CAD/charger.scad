$fn = 64; // High resolution for smooth curves

//Door Screw Socket
module sock(pos) {
    difference() {
        translate(pos)
            cube([6, 6, 6]);
        translate([pos[0] + 3, pos[1] + 3, pos[2] + 3])
            rotate([0, 90, 0]) 
                #cylinder(h = 8, d = 2, center = true); 
    }
}
//Door Screw Socket Close


module hole_tab(){
    union() {
        cube([8, 8, 4]);

        translate([4, 8, 0]) {
            difference() {
                cylinder(h = 4, r = 4);
                
                // Change Y bounds from [-9, 0] to [-9, 0.01] to overlap cleanly
                translate([-5, -9, -1])
                    cube([10, 9, 6]); 
            }
        }
    }
}

union(){

translate([-20,0,0])
cube([106,130,2]);

translate([-20,0,90])
cube([106,130,2]);


translate([-18,56,62])
cube([82,130-58,2]);

translate([-18,56,30])
cube([82,130-58,2]);

translate([-18,56,20])
cube([72,14,2]);
translate([-18,114,24])
cube([72,4,2]);
rotate([90,0,0])
translate([-18 ,22,-120])
cube([72,4,2]);
translate([-18,64,24])
cube([72,6,2]);
translate([-18,114,20])
cube([72,14,2]);
rotate([90,0,0])
translate([-18 ,22,-66])
cube([72,4,2]);


translate([54 ,64,20])
cube([2,4,6]);

translate([54 ,116,20])
cube([2,4,6]);

//Main Front Wall
translate([-20,0,0])
difference(){
translate([0,0,2])
cube([2,130,88]);

translate([2,64,0])    
rotate([0,-90,0])
 
translate([34,10,0]){
union(){
        translate([8,28,1.2])
cube([16,12,1.8]);
translate([20,28,-1])
cube([5,12,3.2]);
}

translate([0,-20,0])
union(){
        translate([8,16,1.2])
cube([16,12,1.8]);
translate([20,16,-1])
cube([5,12,3.2]);
}
}

union()
translate([1,92,56])
rotate([0,-90,0])
cylinder(h=4,d=3.2,center=true);
translate([1,92,50])
rotate([0,-90,0])
cylinder(h=4,d=3.2,center=true);

translate([-1,77,17])
cube([4,16,10]);
}

//Main Front Wall End

//PLacing the Sockets
// Positions of the 4 blocks
block_positions = [
    [78, 22, 2],
    [78, 22, 84],
    [78, 104, 2],
    [78, 104, 84]
];

// Generate all 4 blocks with X-aligned cylindrical center holes

for (p = block_positions) {
    sock(p);
}
//ends


//Right From Front Wall
translate([-20,0,0])
difference(){
translate([2,0,2])
cube([102,2,88]);
    translate([104,3,2])
    rotate([90,-90,0])
hole_tab();
 
translate([4,-128,0])
translate([2,128,2]){
translate([10,-1,50])
cube([72,4,2]);
translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}

translate([4,-128,30])
translate([2,128,2]){
translate([10,-1,50])
cube([72,4,2]);
translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}

translate([4,-128,-34])
translate([2,128,2]){

translate([10,-1,46])
cube([64,4,2]);
translate([10,-1,42])
cube([64,4,2]);
translate([10,-1,38])
cube([64,4,2]);
}   
 
}
//end

//Center Wall 
translate([-20,0,0])
difference(){
translate([2,54,2])
cube([102,2,88]);
translate([104,57,10])
    rotate([90,-90,0])
hole_tab();

translate([20,0,0]){  
translate([-20,0,0])
translate([2,54,2]){
translate([10,-1,50])
cube([72,4,2]);
translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}

translate([-20,0,30])
translate([2,54,2]){
translate([10,-1,50])
cube([72,4,2]);
translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}

translate([-20,0,-34])
translate([2,54,2]){

translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}  
}
}
//end

//Side Door left from front

difference(){
translate([-20,0,0])
translate([2,128,2]){
cube([102,2,88]);

    }

translate([-20,0,0])
translate([2,128,2]){
translate([10,-1,50])
cube([72,4,2]);
translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}

translate([-20,0,30])
translate([2,128,2]){
translate([10,-1,50])
cube([72,4,2]);
translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}

translate([-20,0,-34])
translate([2,128,2]){

translate([10,-1,46])
cube([72,4,2]);
translate([10,-1,42])
cube([72,4,2]);
translate([10,-1,38])
cube([72,4,2]);
}

}
//End

//building compartments for shelfs
union(){
translate([-18,84,32])
cube([82,2,14]);

translate([62,56,32])
cube([2,72,12]);

translate([62,56,64])
cube([2,72,12]);

translate([-18,88,64])
cube([82,2,14]);

translate([70-20,12,2])
cube([2,42,6]);

translate([82-20,2,56])
cube([2,52,8]);

translate([2-20,21,60])
cube([82,10,2]);

translate([38-20,2,60])
cube([10,52,2]);
}
}