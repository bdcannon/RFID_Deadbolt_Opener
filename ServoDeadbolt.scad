/*
 * This is the back mounting plate for Dead Bolt opener along with a bracket to mount
 * a servo motor
*/
// Back Plate variables
plate_width = 89;
plate_height = 153;
plate_thickness = 4.5;
groove_diameter = 16.5;
groove_width_backplate = 60;
groove_width_offset = 0;
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
bracket_reach = 25;  // Adjust the top tab of the bracket to reach out farther
bracket_base_length = 20; // Makes the base of bracket longer, and the slots longer
bracket_width = 30;	// Makes the overall width of the bracket bigger. Wider = stronger
bracket_thickness = 4; // changes the cross section thickness of the bracket
bracket_base_slot_length = bracket_base_length / 2;
bracket_reach_slot_length = bracket_reach / 2;
servo_hole_diameter = 3.5;
servo_hole_spacing = 15;
servo_hole_offset = -8; // More negative number backs the holes away from the edge

// Servo coupling
// For
//	   single servo arm  = 0
//     Large Servo Horns = 1
// 	   X Horns           = 2
// 	   wheel             = 3
horn_type = 1;
coupling_width = 8.95;
coupling_depth = 18;
coupling_length = 28;
coupling_wall_thickness = 1.5;
servo_couple_offset = 5;
servo_couple_radius = (coupling_width - coupling_wall_thickness)/2;
groove_width = 2;
servo_arm_groove_width = 3;
servo_arm_recess_depth = 1.5;
servo_arm_recess_width = 2;

/*
* Still needs to be implemented
*/
module servoHorn(horn_type){
	if(horn_type == 0){ // Large Horns
		circle(r = 5);
	}
}

/*
 * Coupling for thumb knob
 *
 */
module deadBoltCoupler(coupling_width, coupling_depth, coupling_length, coupling_wall_thickness){
	difference(){ // Cutout recess for servo arm
		difference(){ // Cutout holes to zip tie the servo to this thing 
			difference(){// Cut away grooves for coupling thing
				difference(){ // Cut outs at bottom to clear thumbwheel 
					union(){ // Create the major box of the coupling
						for(x = [0, coupling_width]){ // Iterate to create two  long side walls
							translate([x, 0, 0])
							cube(size = [coupling_wall_thickness, coupling_length, coupling_depth]);
						}
						// Short side walls perpendicular to long walls
						cube(size = [coupling_width, coupling_wall_thickness, coupling_depth]);
						translate([0, coupling_length - coupling_wall_thickness, 0])
						cube(size = [coupling_width, coupling_wall_thickness, coupling_depth]);
						hull(){ // To create pretty top 
							translate([0,0,coupling_depth]) // Move cube to the top of the coupling
															// To be the other half of the hull
							cube(size = [coupling_width + coupling_wall_thickness, coupling_length, coupling_wall_thickness]);
							// Center the cylinder above coupling for the hull
							translate([(coupling_width - coupling_wall_thickness)/2 + coupling_wall_thickness, coupling_length/2, coupling_depth + coupling_wall_thickness + servo_couple_offset])
							cylinder(r = coupling_width/3, h = coupling_wall_thickness);
						}
					}
					translate([(coupling_width - coupling_wall_thickness)/2 + coupling_wall_thickness, 0,0])
					rotate([-90, 0, 0])
					cylinder(r = servo_couple_radius , h = coupling_length + 1);
				}
				// This is very ugly...
				for(i = [ [0, (coupling_length/16)    ,0],
						  [0, coupling_length/4       ,0],
						  [0, 3*(coupling_length/4) - groove_width   ,0],
						  [0, 15*(coupling_length/16) - groove_width ,0],
						  // Top
						  [0, (coupling_length/16)    ,(coupling_depth + coupling_wall_thickness/1.125) + (servo_couple_offset/(coupling_length/2 - servo_couple_radius))*coupling_length/16],
						  [0, coupling_length/4       ,(coupling_depth + coupling_wall_thickness/1.125) + (servo_couple_offset/(coupling_length/2 - servo_couple_radius))*coupling_length/4],
						  [0, 3*(coupling_length/4) - groove_width   ,(coupling_depth + coupling_wall_thickness/1.125) + (servo_couple_offset/(coupling_length/2 - servo_couple_radius))*coupling_length/4],
						  [0, 15*(coupling_length/16) - groove_width ,(coupling_depth + coupling_wall_thickness/1.125) + (servo_couple_offset/(coupling_length/2 - servo_couple_radius))*coupling_length/16]]){
					translate(i)
					cube(size = [coupling_width + coupling_wall_thickness, groove_width, 2]);
				}
			}
			translate([0, 2*(coupling_length/4) - groove_width ,(coupling_depth + coupling_wall_thickness/1.125) + (servo_couple_offset/(coupling_length/2 - servo_couple_radius))*coupling_length/4])
			cube(size = [coupling_width + coupling_wall_thickness, groove_width*2, 1]);
		}
		translate([(coupling_width - coupling_wall_thickness)/2 + coupling_wall_thickness, coupling_length/2, coupling_depth + coupling_wall_thickness + servo_couple_offset + servo_arm_recess_depth/2])
		for(x = [0 : 3]){
			rotate(a = [0, 0, 90 * x])
			#cube(size = [servo_couple_radius + 10, servo_arm_groove_width, servo_arm_recess_depth], center = true);
		}
	}
}

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
				union(){// Groove
					#cube(size = [groove_width_backplate, groove_diameter, plate_thickness]);
					translate([groove_width_backplate,groove_diameter/2,0])
					cylinder(r = groove_diameter/2, h = plate_thickness, center= false);
					translate([0,groove_diameter/2,0])
					cylinder(r = groove_diameter/2, h = plate_thickness, center= false);
				}
		}
	}
}

/*
*	Utility module for creating slots
*/
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

/*
* 	Bracket for mounting servo to backplate
*/
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

//////////////////////////////////////////////
// Place and instantiate modules for printing
// Change the translate values or comment out
// the module calls to move or remove parts for
// printing
///////////////////////////////////////////////
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
// Move rotate the servo bracket
translate([-5, 55, 0])
rotate(a = [0,0,90])
servoBracket();
// Move and rotate coupling
translate([45, 63,0])
rotate(a = [0, 0, 90])
deadBoltCoupler(coupling_width, coupling_depth, coupling_length, coupling_wall_thickness);

	
	
	
	
	
	
	
	
	