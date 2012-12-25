/*
 * This is the back mounting plate for Dead Bolt opener
*/
// Back Plate variables
plate_width = 89;
plate_height = 153;
plate_thickness = 4.5;
groove_diameter = 16.5;
groove_width = 60;
groove_width_offset = 1;
groove_position = 60;

// Back plate slot settings
slot_diameter = 4;
slot_length = 60;
slot_spacing = 10;
slot_width_offset = plate_width/2;
slot_height_offset = -10;

// Trap slot settings
trap_diameter = slot_diameter + 2;
trap_length = slot_length;
trap_spacing = slot_spacing;
trap_width_offset = slot_width_offset;
trap_height_offset = slot_height_offset;
trap_depth = plate_thickness - 1.5;

// Servo Bracket settings
bracket_height = 30; // The overall height of the bracket.
bracket_reach = 25;
bracket_base_length = 20;
bracket_width = 30;
bracket_thickness = 4;
bracket_base_slot_length = bracket_base_length / 2;
bracket_reach_slot_length = bracket_reach / 2;
servo_hole_diameter = 3.5;
servo_hole_spacing = 15;
servo_hole_offset = -8;


module backplate(){
	difference(){
		// Set up the basic back plate
		union(){
			cube(size = [plate_width, plate_height, plate_thickness]);
			// Move to cylinders to round the top and bottom (make it pretty)
			translate([plate_width/2, 0,0])
			cylinder(r = plate_width/2, h = plate_thickness, center= false);
			translate([plate_width/2, plate_height,0])
			cylinder(r = plate_width/2, h = plate_thickness, center= false);
		}
		translate([groove_width_offset,groove_position, 0]){
				union(){
					// The groove
					cube(size = [groove_width, groove_diameter, plate_thickness]);
					translate([groove_width,groove_diameter/2,0])
					cylinder(r = groove_diameter/2, h = plate_thickness, center= false);
					translate([0,groove_diameter/2,0])
					cylinder(r = groove_diameter/2, h = plate_thickness, center= false);
				}
		}
	}
}

module slots(slot_diameter, slot_length, slot_spacing, plate_thickness){
echo (slot_length);
	for(x = [(-slot_spacing/2), (slot_spacing/2)]){
		echo (x);
		translate([x, 0, 0]){
			union(){
				#cube([slot_diameter, slot_length, plate_thickness]);
				translate([slot_diameter/2, slot_length,0])
				cylinder(r = slot_diameter/2, h = plate_thickness);
				translate([slot_diameter/2, 0,0])
				cylinder(r = slot_diameter/2, h = plate_thickness);
			}
		}
	}
}

module servoBracket(){
difference(){
	difference(){ // Difference for base slots
		union(){ // Create the general bracket
			// Bracket Base
			cube([bracket_base_length, bracket_thickness, bracket_width]);
			translate([bracket_base_length,0,0])
			// Bracket stem
			cube([bracket_thickness, bracket_height - (2*bracket_thickness), bracket_width]);
			translate([bracket_base_length, bracket_height - (2*bracket_thickness),0])
			cube([bracket_reach, bracket_thickness, bracket_width]);
		}
		rotate(a = [90,90,0]){ // Place and rotate the lower slots
			// For some reason I needed to add one...
			translate([-bracket_width/2 - slot_spacing/2 + slot_diameter - 1, bracket_base_length/3, -bracket_thickness-.1]){
				#slots(slot_diameter, bracket_base_slot_length, slot_spacing,bracket_thickness+1);
			}
		}
	}
	rotate(a = 90, v =[1,0,0] ){
		for(y = [-servo_hole_spacing/2, servo_hole_spacing/2]){
			translate([bracket_base_length + bracket_thickness + bracket_reach + servo_hole_offset, y + bracket_width/2,-bracket_height + bracket_thickness])
			#cylinder(r = servo_hole_diameter/2, h = bracket_thickness + .1);
		}
	}
}
}

// Make a plate
difference(){ // Create groove/trap behind plate so it will sit flush against door
			  // when there is fasteners through the plate
	difference(){ // subtract slots from backplate
		backplate();
		translate([slot_width_offset, slot_height_offset, 0])
		#slots(slot_diameter, slot_length, slot_spacing, plate_thickness);
	}
	translate([slot_width_offset + (slot_diameter/2 - trap_diameter/2) ,slot_height_offset ,0])
	#slots(trap_diameter, trap_length, trap_spacing, trap_depth);
}
translate([-20, 0, 0])
rotate(a = [0,0,90])
servoBracket();
//slots(slot_diameter, slot_length, slot_spacing, plate_thickness);
//slots(trap_diameter, trap_length, trap_spacing, trap_depth);
	
	
	
	
	
	
	
	
	