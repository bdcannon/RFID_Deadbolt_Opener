/*
 * _447RFID.cpp
 *
 * NOTE: This method of making the servo seems only to work for digital servos
 *
 * Created: 12/5/2012 7:15:56 PM
 *  Author: Ben Cannon
 */ 

#define F_CPU		16000000UL
#define BAUD		9600			// Baudrate for RFID Reader
// Constants for timers and PWM
#define UNLOCK 18000
#define HALF_LOCK 18500
#define LOCK 18750 // 1800
#define LOCK_INACTIVE 19500	// Puts the pulse width outside of the operating
							// range for the servo
#define UNLOCK_INACTIVE 17000
#define LOCK_DELAY	10	// The number of seconds before the door locks
#define OPEN		1
#define LOCKED		2
#define REST		0
#define RFID_LEN	12

#include <avr/io.h>
#include <util/delay.h>
#include <avr/sfr_defs.h>
#include <avr/interrupt.h>
#include <util/setbaud.h>
#include <string.h>
#include <stdint.h>

// Forward Decleration for functions to be used
void pinSetUp();	// Set Up Pin Direction and Pullups
void servoSetup();	// Set Up PWM for servo
void UARTSetup();	// Set up both UARTS
void actuateLock(int position, bool delay);	// Actuates the thumbturn



/////////////////
// Some Useful Variables
////////////////
volatile char receiveRFID[RFID_LEN];
volatile char packRecieve[3];
volatile int charCount;
volatile int xbeeCount;

char tag[RFID_LEN] = {'\n', '0', '1', '0', '0', 'C', '4', 'A', 'A', '6', 'F', '\r'};
	
bool switchState = true; // Used for reading switch (Switches are pulled high)
uint8_t doorState = 0; // 0 = ? , 1 = open, 2 = locked

int main(void)
{	
	// Setup routines
	pinSetUp();		// Set up some pins to use
	servoSetup();	// Set up Servo
	UARTSetup();	// Setup UARTS
	
	PORTD &= ~(1 << PIND7); // Enable the RFID Reader.
	charCount = 0;
	xbeeCount = 0;
	sei();			// Enable interrupts
	
//////////////////////////////
// MAIN LOOP
/////////////////////////////
    while(1)
    {
		// Poll the status of the switches
		if(bit_is_clear(PIND,PIND6)){ // open Button
			_delay_ms(25);	// Wait for the switch to stop bouncing
			if(bit_is_clear(PIND,PIND6)){ // If the lock button is still low
				actuateLock(UNLOCK, false);
				doorState = OPEN;
			}
		}			
		else if(bit_is_clear(PINC,PINC6)){ // Lock
			_delay_ms(25);
			if(bit_is_clear(PINC,PINC6)){
				actuateLock(LOCK, false);
				doorState = LOCKED;
			}
		}
		else if(bit_is_clear(PINC,PINC1)){ // Delay Lock
			_delay_ms(25);
			if(bit_is_clear(PINC,PINC1)){
				actuateLock(LOCK, true);
				doorState = LOCKED;
			}
		}	
	}
}
// Set up pins or various states
void pinSetUp(){
	// Outputs
	DDRD |= (1 << PIND5);
	DDRD |= (1 << PIND7);   // Set PD7 as output to activate RFID Reader
	
	// Inputs 
	DDRD &= ~(1 << PIND6);	// Set up PB0 for "Unlock"
	DDRD &= ~(1 << PIND4);  // Set up PB1 for "Door Switch"
	DDRC &= ~(1 << PINC6);  // Set up PB1 for "Lock"
	DDRC &= ~(1 << PINC1);	// Set up PB2 for "Lock Delay Switch"
	
	// Pull Up for Inputs
	// These pins will be Logic high until pull low by a switch
	PORTD |= (1 << PIND6);	// Unlock Switch
	PORTD |= (1 << PIND4);	// Door switch (If the door is closed or not) 
	PORTC |= (1 << PINC6);	// Lock Switch
	PORTC |= (1 << PINC1);	// Delay Lock Switch
	
	// Setup before we leave
	//DDRD &= ~(1 << PIND5);	// Make sure the pin is turned off for PWM
	PORTD &= ~(1 << PIND7); // Enable the RFID Reader. // Enable reader
	
}

// Set put registers for 16bit timer
void servoSetup(){
	// phase correct
	TCCR1A |= (1 << COM1A1) | (1 << COM1A0) | (1 << WGM11 );
	TCCR1B |= (1 << WGM13) | (1 << CS11);
	TCCR1B &= ~((1 << CS11) | (1 << CS10));
	// 20 ms Period 
	ICR1 = 20000;
}

void UARTSetup(){
	// Set BAUD value for UART0 for the xbee (9600)
	UBRR0 = 103;
	UCSR0A = UCSR0A & 0xFD; // Clear the U2X0 bit with mask (not 2x fast)
	UCSR0B |=  (1 << TXEN0) | (1 << RXEN0) | (1 << RXCIE0); // Enable Transmitter and receiver
	// and Receive interrupt
	// Undefine the BAUD
	#undef BAUD
	#define BAUD 2400
	
	// Set BAUD for UART1 for reader (2400)
	UBRR1 = 416;
	UCSR1A = UCSR1A & 0xFD;	// Clear the U2X0 bit with mask (not 2x fast)
	UCSR1B |= (1 << RXEN1) | (1 << RXCIE1); // Enable receiver and receive interrupt
}

/*
*	This function updates the output compare register for the PWM.
*	The positions are defined as 3 different positions. Lock, Open, and
*	inactive. Lock = 2 ms pulse, Open = 1 ms pulse, and Inactive is a 
*	pulse length outside of the active range of the servo, thus making it
*	free to turn and not set to a position.
*/
void actuateLock(int position, bool delay){
	if(delay)
		_delay_ms(LOCK_DELAY * 1000);
	TCCR1B |= (1 << CS11);
	OCR1A = position;		// Write the position to the timer
	_delay_ms(1750);		// Wait for the servo to move
	TCCR1B &= ~((1 << CS11) | (1 << CS10));
	
	
}

//ISR for UART0 (From R)
// Should lead with a ';'
ISR(USART0_RX_vect){
	cli(); // Turn off interrupts so we don't get interrupt
	// Read the first byte and check it
	packRecieve[xbeeCount++] = UDR0;
	
	while(!(UCSR0A & (1 << UDRE0)))
	{	;
	}
	// Echo
	UDR0 = packRecieve[0];
	
	if(packRecieve[0] != '!'){	// Not the right start byte
		xbeeCount = 0;
	}
	// A complete transmission
	else if (xbeeCount == 3){
		xbeeCount = 0;
		// Command to unlock door 
		if(packRecieve[0] == '!' && packRecieve[1] == '2' && packRecieve[2] == ';'){
			actuateLock(UNLOCK, false);
		}
		// Command to Lock door
		else if(packRecieve[0] == '!' && packRecieve[1] == '1' && packRecieve[2] == ';'){
			actuateLock(LOCK, false);
		}		
	}	
	sei(); // Turn Back on interrupts
}

// ISR for UART1 (RFID) to transmit
// Interrupt triggers when we receive a byte
ISR(USART1_RX_vect){
	cli(); // Turn off interrupts so we can act slightly atomically
	receiveRFID[charCount++] = UDR1;
	if(receiveRFID[0] != '\n'){
		charCount = 0;
	}
	else if(charCount == RFID_LEN){	// If we got a full transmission
		charCount = 0;				// Reset our counter
		if(receiveRFID[0] == '\n'){	// Check to see if its a match
			bool match = true;
			for(int i = 0; i < RFID_LEN; i++)
			{
				if(receiveRFID[i] != tag[i])
				match = false;
			}
			if(match) // If its a match, open the lock
				actuateLock(UNLOCK,false);
		}
	}
	sei();// Enable interrupts on the way out
}