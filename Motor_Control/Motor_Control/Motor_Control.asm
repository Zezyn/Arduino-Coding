.nolist
.include "tn2313def.inc"
.include "DBmacro.inc"
.list

.equ 			DBcount = 200
.equ			PERIOD = 33333
.equ			PWMstep = 3000
.equ 			PWMmax = 27000

.def 			TEMP = R16
.def 			COUNTER = R20
.def			PWML = R18
.def 			PWMH = R19

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

	ldi 		TEMP,(1<<COM1A1)|(1<<WGM11)
	out			TCCR1A, TEMP

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
	rjmp		PWMdec

PWMdec:
	ldi 		TEMP, low(PWMstep)
	add 		PWML, TEMP
	ldi			TEMP, high(PWMstep)
	adc			PWMH, TEMP
	ldi 		TEMP, low(PWMmax)

	ldi 		TEMP, low(PWMstep)
	sub 		PWML, TEMP
	ldi			TEMP, high(PWMstep)
	sbc			PWMH, TEMP

	ldi			TEMP, low(PWMmax)
	cp			TEMP, PWML
	ldi			TEMP, high(PWMmax)
	cpc			TEMP, PWMH
	//brge		PWMnotMAX
	ldi			PWMH, high(PWMmax)
	ldi			PWML, low(PWMmax)

	/*
	rjmp 		COUNTdown
	inc			COUNTER 
	ori 		COUNTER, (1<<PB7)|(1<<PB6)
	out 		PORTB, COUNTER
	*/

	pop			TEMP, SREG

COUNTdown:
	dec 		COUNTER
	ori 		COUNTER, (1<<PB7)|(1<<PB6)
	out 		PORTB, COUNTER
	reti
