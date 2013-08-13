/////////////////
// What is this?
/////////////////
So this is a work in progress. This is a pretty simple modular and parameterized deadbolt opener. 
The opener mounts a servo directly onto the thumbturn (the knobby thing that your turn) and
will be coupled (attached) with common things; zip ties and rubber bands. This will be ideal for apartments because it is uninvasive and doesn't require any 
modification of your current deadbolt.

/////////////////////////////
// Instructions  (So far)
////////////////////////////
Measure your deadbolt and change the values accordingly. Most important to measure is the
dimensions of the thumbturn. The measurements will be used to modify the values of the
coupling. The coupling will go over several iterations from here on out. At the moment,
I am not too happy with it. Use something like rubber bands to attach the coupling to the 
thumbturn. This will be flexible and will make a nice flex coupling. Pass the bands through
the grooves on the bottom of the coupling and over the top in their respective groove.
Measure the dimensions, hole spacing, and hole size for the servo you are choosing to use. 
These values will be used for the servo bracket. Further bracket iteration will reinforce 
the design and change the way it is mounted.

Using an RFID module and a MCU, we can read tags, and then actuate the servo. I have already
written code for barebones ATMEGA 1284 that works, but you will have to build the circuit
for the MCU and the servo. Also, I will write code for some Arduino variants if you don't 
want to spend the extra time building the microcontroller and such.

//////////////////////////////
// Notes on Code
//////////////////////////////
I would not recommend using the code provided just yet. It is pretty crappy implementation
and is only usable if in a Atmel Studio project for the AVR (which is actually quite nice).

It is possible, with some tweaking to use and upload this code directly from the Arduino IDE
to an ATMega1284P with a bootloader on it. 


/////////////////////
// To Do's
/////////////////////
+ Finish code for ATMEGA1284 and Arduino variants
+ Translate code for Arduino Variants
+ Rework coupling
	- Better method of directly connecting the servo to coupling
+ Rework servo bracket
	- Add better (stronger?) mounting method
+ Add BOM (Bill of Materials)
+ I'm sure I'll think of other things
