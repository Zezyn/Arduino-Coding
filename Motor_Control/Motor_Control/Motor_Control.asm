.nolist
.include "tn2313def.inc"
.include "DBmacro.inc"
.list

.equ 			DBcount = 200 //Debounce Count
.equ			PERIOD = 33333	//Defines the period of loop 33000 milliseconds
.equ			PWMstep = 3000	//Steps every 3000 milliseconds
.equ 			PWMmax = 27000	//Maxes at 27000 milliseconds

.def 			TEMP = R16		
.def 			COUNTER = R20
.def			PWML = R18
.def 			PWMH = R19

.ORG			$0000
					rjmp RESET

.ORG			PCIaddr
					rjmp TIMEROVERFLOW

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

TIMEROVERFLOW:
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

	pop			TEMP, SREG

COUNTdown:
	dec 		COUNTER
	ori 		COUNTER, (1<<PB7)|(1<<PB6)
	out 		PORTB, COUNTER
	reti

T1overflow:
	sbis 		PINB, 7
	rjmmp		COUNTdown
	sbic 		PINB, 6
	reti

COUNTup:
	
