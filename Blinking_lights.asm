/* 
	Martin Hernandez
	Test Program
*/

.nolist
.include "tn2313def.inc"
.list

.def TEMP = R16
.def SHIFTreg = R17
.def UpDown = R18
.def SPEED = R19

.equ TESTvalue = $0A63
.equ LeftRight = 7

.ORG	$0000
		rjmp 	RESET
.ORG	INT0addr 													;Interrupt Vector for External Interrupt 0
		rjmp	INT0isr
.ORG	INT1addr													;Interrupt Vector for External Interrupt 1
		rjmp	INT1isr
.ORG	OVF0addr
		rjmp 	ROTATE

.ORG	INT_VECTORS_SIZE

RESET:
		ldi		TEMP, low(RAMEND)									;Load low byte of last address for SRAM into R16
		out		SPL, TEMP											;Output value in TEMP (R16) to Stack Pointer Low Byte.

		//ldi		TEMP, (1<<DDB3)|(1<<DDB2)|(1<<DDB1)|(1<<DDB0)		;PortB Data Direction
		ldi  	TEMP, $FF
		out 	DDRB, TEMP											;Output value in TEMP to Data Direfction Register for Port B

		ldi		TEMP, $00
		out 	DDRD, TEMP

		ldi		TEMP, (1<<PD3)|(1<<PD2)								;INT1 & INT0 Pins Pullup Resistors Enabled
		out 	PORTD, TEMP

		ldi 	TEMP, (1<<ISC11)|(1<<ISC10)|(1<<ISC01)|(1<<ISC00)	;Interrupt 1 & 0 Sense on Rising Edge
		out		MCUCR, TEMP

		ldi		TEMP, (1<<INT1)|(1<<INT0)							;Interrupt 1 & 0 enabled
		out		GIMSK, TEMP

		ldi 	TEMP, (1<<TOIE0)
		out		TIMSK, TEMP
		
		ldi 	TEMP, (1<<CS02)|(0<<CS01)|(1<<CS00)
		out		TCCR0B, TEMP		

		ldi 	SHIFTreg, 1 												;Clear all bits in COUNT. COUNT = 0

		clr 	UpDown												;Clears UpDown register

		sei

MAIN:
		nop
		//inc		COUNT
		//andi 	COUNT, $0F
		//out		PORTB, COUNT
		nop
		rjmp	MAIN

INT0isr:															;Inturrupt 0 routine
		sbis 	GPIOR0, LeftRight
		rjmp	Goleft
		cbi		GPIOR0,	LeftRight
		//ldi		Updown, $01
		//nop
		//reti
		//sbi 	GPIOR0, LeftRight
		reti

Goleft:
		sbi	GPIOR0, LeftRight
		reti

INT1isr:															;Interrupt 1 routine
		//ldi		UpDown, $FF
		//nop
		//reti
		//cbi		GPIOR0, LeftRight
		//reti
		ldi		TEMP, $20
		add		SPEED, TEMP
		reti
ROTATE:
		out		TCNT0, SPEED
		sbis	GPIOR0, LeftRight
		rjmp	LEFT
		bst		SHIFTreg, 0
		lsr		SHIFTreg
		bld		SHIFTreg, 7
		out		PORTB, SHIFTreg
		reti

LEFT:
		bst		SHIFTreg, 7
		lsl		SHIFTreg
		bld		SHIFTreg, 0
		out 	PORTB, SHIFTreg
		reti
			
/*CountUpDown:														;Count routine
		add		COUNT, UpDown 										;Adds two regesters together
		out		PORTB, COUNT
		reti
*/

