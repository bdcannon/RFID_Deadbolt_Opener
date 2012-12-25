/*
 * This is the back mounting plate for Dead Bolt opener
*/
// Back Plate variables
plate_width = 89;
plate_height = 153;
plate_thickness = 3;
groove_diameter = 16.5;
groove_width = 60;
groove_width_offset = 1;
groove_position = 60;

// Slot settings
slot_diameter = 4;
slot_length = 60;
slot_spacing = 10;
slot_width_offset = plate_width/2;
slot_height_offset = -5;

// Servo Bracket settings
bracket_height = 31;
bracket_reach = 25;
bracket_base_length = 20;
bracket_width = 20;
bracket_thickness = 4;
bracket_base_slot_length = bracket_base_length / 2;
bracket_reach_slot_length = bracket_reach / 2;

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

module slots(slot_diameter, slot_length, slot_spacing, slot_width_offset, slot_height_offset, plate_thickness){
	for(x = [(slot_width_offset - slot_spacing/2), (slot_width_offset + slot_spacing/2)]){
		translate([x, slot_height_offset, 0])
		union(){
			cube([slot_diameter, slot_length, plate_thickness]);
			translate([slot_diameter/2, slot_length,0])
			cylinder(r = slot_diameter/2, h = plate_thickness);
			translate([slot_diameter/2, 0,0])
			cylinder(r = slot_diameter/2, h = plate_thickness);
		}
	}
}

module servoBracket(){
	difference(){
		union(){
			// Bracket Base
			cube([bracket_base_length, bracket_thickness, bracket_width]);
			translate([bracket_base_length,0,0])
			// Bracket stem
			cube([bracket_thickness, bracket_height - (2*bracket_thickness), bracket_width]);
			translate([bracket_base_length, bracket_height - (2*bracket_thickness),0])
			cube([bracket_reach, bracket_thickness, bracket_width]);
		}
		rotate(a = [90, 0, 0])
		rotate(a = [0, 0, -90])
		translate([0, 0, -bracket_thickness - .1])
		#slots(slot_diameter, bracket_base_slot_length, slot_spacing, -(bracket_width/2 + slot_diameter/2),bracket_base_length/3,bracket_thickness + 1);
	}
}

// Make a plate
/*
difference(){
	backplate(); 
	slots();
}*/
servoBracket();
	
	
	
	
	
	
	
	
	