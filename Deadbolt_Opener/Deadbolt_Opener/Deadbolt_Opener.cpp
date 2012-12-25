/*
 * _447RFID.cpp
 *
 * Created: 12/5/2012 7:15:56 PM
 *  Author: Ben Cannon
 */ 

#define F_CPU		16000000UL
#define BAUD		9600			// Baudrate for RFID Reader
#define MS20_0H		0x4e			// Some constants for timers  
#define MS20_0L		0x20			// and pulse widths
#define MS2_0H		0x07
#define MS2_0L		0xd0
#define MS1_5H		0x05
#define MS1_5L		0xdc
#define MS1_0H		0x03
#define MS1_0L		0xe8
#define START		';'
#define END			')'
#define RFID_LEN	12
#define PACK_LEN	14
#define STATION_ID	'1'
#define RFID_ID		'1'
#define DRBLL_ID	'2'
#define VALID_ID	'3'

#include <avr/io.h>
#include <util/delay.h>
#include <avr/sfr_defs.h>
#include <avr/interrupt.h>
#include <util/setbaud.h>
#include <string.h>
#include <stdint.h>

// Set Up Pin Direction and Pullups
void pinSetUp();

// Set Up PWM for servo
void servoSetup();

/////////////////
// Some Useful Variables
////////////////
volatile char receiveRFID[RFID_LEN];
volatile char send[PACK_LEN];
volatile char packRecieve[PACK_LEN];
static char doorPack[14] = {';', STATION_ID , DRBLL_ID, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', END};
int doorBell = 0;

int main(void)
{
	// Set BAUD value for UART0 for the xbee (9600)
	UBRR0H = UBRRH_VALUE;
	UBRR0L = UBRRL_VALUE;
	UCSR0A = UCSR0A & 0xFD; // Clear the U2X0 bit with mask (not 2x fast)
	UCSR0B |=  (1 << TXEN0) | (1 << RXEN0) | (1 << RXCIE0); // Enable Transmitter and receiver
													   // and Receive interrupt
	// Undefine the BAUD
	#undef BAUD
	#define BAUD 2400
	
	// Set BAUD for UART1 for reader (2400)
	UBRR1H = UBRRH_VALUE;
	UBRR1L = UBRRL_VALUE;
	UCSR1A = UCSR1A & 0xFD;	// Clear the U2X0 bit with mask (not 2x fast)
	UCSR1B |= (1 << RXEN1) | (1 << RXCIE1); // Enable receiver and receive interrupt 
	
	servoSetup();	// Set up Servo
	pinSetUp();		// Set up some pins to use
	
	sei();			// Enable some interrupts
//////////////////////////////
// MAIN LOOP
/////////////////////////////
    while(1)
    {
		doorBell = PIND & 0x80; // Read the "DoorBell"
		// If the Door bell has a high state	
		if(doorBell)
		{
			_delay_ms(20); // Wait for switch to settle
			// IF the state is still the same
			if(doorBell == (PIND & 0x80))
			{
				for(int i=0; i < PACK_LEN; i++)
				{	
					// Wait until Data Register is empty
					loop_until_bit_is_set(UCSR0A, UDRE0);
					UDR0 = doorPack[i];
				}
				PORTA |= (1 << PORTA0);
				while(PIND & 0x80){;} // While the button is pressed, do nothing
				PORTA &= ~(1 << PORTA0);
			}
		}
	}

}
// Set up pins or various states
void pinSetUp(){
	DDRA |= (1 << PINA0) | (1 << PINA2);	// Set up A0 as an output
	DDRD |= (1 << PIND6);	// Set PD6 as output to pull low the enable for the reader
	PORTD &= (1 << PIND6);	// Pull RIFD low to read cards
	DDRD &= ~(1 << PIND7);	// Set up PD7 for "doorbell" input
}

// Set put registers for 16bit timer
void servoSetup(){
	TCCR1A |= (1 << COM1A1) | (1 << WGM11 );
	TCCR1B |= (1 << WGM13) | (1 << WGM11) | (1 << CS11);
	// Set Top for 20 ms Period
	ICR1H = 0x4e;
	ICR1L = 0x20;
	// Load Output Compare for 2ms
	OCR1AH = 0x07;
	OCR1AL = 0xd0;
	// Turn pin PD5 to output
	DDRD |= (1 << PIND5); // Turns on PWM out 
}

// ISR for UART0 (From Main Station)
// Should lead with a ';'
ISR(USART0__RX_vect){
	cli(); // Turn off interrupts so we don't get interrupt
	UDR0 = '!';
	// Read the first byte and check it
	packRecieve[0] = UDR0;
	if(packRecieve[0] == START)
	{
		// Read in all the bytes.
		for(int i = 1; i < PACK_LEN; i++)
		{
			loop_until_bit_is_set(UCSR0A, RXC0);
			packRecieve[i] = UDR0;
		}
		
		// IF the id is for me (this station)
		if(packRecieve[1] == STATION_ID && packRecieve[13] == END)
		{
			// Handle the right Action for device id
			if(packRecieve[2] == VALID_ID && packRecieve[12] == '1')
			{ // RFID
				PORTA |= (1 << PORTA0); // Turn on indication
				// Open Door
				OCR1AH = MS1_0H;
				OCR1AL = MS1_0L;
				_delay_ms(3500); // Wait 3.5 sec
				// Turn off Light and shut door
				PORTA &= ~(1 << PORTA0);
				OCR1AH = MS2_0H;
				OCR1AL = MS2_0L;
			}
			// Invalid Id
			else if(packRecieve[2] == VALID_ID && packRecieve[12] == '0')
			{
				PORTA |= (1 << PORTA2); // Turn on the sorry light
				_delay_ms(3500);
				PORTA &= ~(1 << PORTA2);
			}
		}
	}
	sei(); // Turn Back on interrupts
}

// ISR for UART1 (RFID) to transmit
// Interrupt triggers when we receive a byte
ISR(USART1_RX_vect){
	cli(); // Turn off interrupts so we can act slightly atomically
	receiveRFID[0] = UDR1;
	
	// If the byte we just received is our start...
	if(receiveRFID[0] == '\n'){
		for(int i = 1; i < RFID_LEN; i++)
		{
			loop_until_bit_is_set(UCSR1A,RXC1); // Wait till we get a byte
			receiveRFID[i] = UDR1;				// Put it in
		}
		// Check if RFID is framed correct
		if(receiveRFID[11] == '\r')
		{
			// Send start
			loop_until_bit_is_set(UCSR0A, UDRE0);
			UDR0 = START;
			// Send Station ID
			loop_until_bit_is_set(UCSR0A, UDRE0);
			UDR0 = STATION_ID;
			// Send Device ID
			loop_until_bit_is_set(UCSR0A, UDRE0);
			UDR0 = RFID_ID;
			// If framed right pack it up and send it off
			for(int i = 1; i < 11; i++)
			{
				loop_until_bit_is_set(UCSR0A, UDRE0); // Wait until the Data Register is empty
				UDR0 = receiveRFID[i];
			}
			loop_until_bit_is_set(UCSR0A, UDRE0);
			UDR0 = END;
		}
	}
	sei();// Enable interrupts on the way out
}