/////////////////
// What is this?
/////////////////
So this is a work in progress. This is a pretty simple modular and parameterized deadbolt opener. 
The opener mounts a servo directly onto the thumbturn (the knobby thing that your turn). 
This will be ideal for apartments because it is uninvasive and doesn't require any 
modification of your current deadbolt.

/////////////////
// How Does it work?
///////////////// 
Using an RFID module and a MCU, we can read tags, and then actuate the servo. I have already
written code for barebones ATMEGA 1284 that works, but you will have to build the circuit
for the MCU and the servo. Also, I will write code for some Arduino variants if you don't 
want to spend the extra time building the microcontroller and such.

/////////////////////
// To Do's
/////////////////////
+ Finish OpenSCAD drawings and make sure they aren't broken when you change parameterized
+ Finish code for ATMEGA1284 and Arduino variants
+ Create PCB and schematic for those who want to make their own MCU
+ I'm sure I'll think of other things