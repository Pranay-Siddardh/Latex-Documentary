
//Main back wall

translate([0,0,106])
rotate([90,90,90])
union(){
translate([84+20,0,2]){
difference(){
cube([2,130,88]);
rotate([0,90,0])
translate([-3,25,1])
#cylinder(d=2,h=4,center=true);

rotate([0,90,0])
translate([-3,107,1])
#cylinder(d=2,h=4,center=true);

rotate([0,90,0])
translate([-85,25,1])
#cylinder(d=2,h=4,center=true);

rotate([0,90,0])
translate([-85,107,1])
#cylinder(d=2,h=4,center=true);
}
}
}

//Main Back wall ends.

