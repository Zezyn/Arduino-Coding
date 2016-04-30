.nolist
.include "tn2313def.inc"
.include "DBmacro.inc"
.list

.equ 			DBcount = 200

.def 			TEMP = R16
.def 			COUNTER = R20

.ORG			$0000
					rjmp RESET

.ORG			PCIaddr
					rjmp BUTTON

.ORG 			INT_VECTORS_SIZE

RESET:
	ldi			TEMP, low(RAMEND)
	out 		SPL, TEMP

	ldi 		TEMP, $3F //pins 0-5 output
	out 		DDRB, TEMP

	ldi 		TEMP, $C0
	out 		PORTB, TEMP //PortB 7..6 Pull-Up Resistors
	out 		PCMSK, TEMP //PinChange Mask

	ldi 		TEMP, (1<<PCIE)
	out 		GIMSK, TEMP
	sei

MAIN:
	nop
	nop
	nop
	rjmp 		MAIN

BUTTON:
	push	 	TEMP
	in 	     	TEMP, SREG
	push	 	TEMP
	Debounce 	PINB, (1<<PB7)|(1<<PB6), DBCOUNT
	sbis 		PINB, PB7
	rjmp 		COUNTdown
	inc			COUNTER 
	ori 		COUNTER, (1<<PB7)|(1<<PB6)
	out 		PORTB, COUNTER

COUNTdown:
	dec 		COUNTER
	ori 		COUNTER, (1<<PB7)|(1<<PB6)
	out 		PORTB, COUNTER
	reti
