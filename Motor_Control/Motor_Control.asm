.nolist
.include "tn2313def.inc"
.list

.equ			PERIOD = 20000		//Defines the period of loop 33000 milliseconds
.equ			PWMstep = 15		//Pulse width modulation Steps every 3000 milliseconds
.equ 			PWMmax = 2200		//Pulse Width modulation Maxes at 27000 milliseconds
.equ			PWMmin = 1000		//Min Pulse Width modulation 3000 miliseconds

.def 			TEMP = R16		
.def			PWML = R18
.def 			PWMH = R19


.ORG		$0000
			rjmp RESET

.ORG		OVF1addr			
			rjmp T1overflow			//Jump to T1overflow function

.ORG		INT_VECTORS_SIZE		//Defines Vector libraries

RESET:
	ldi		TEMP, low(RAMEND)		//Load imediate TEMP into low end of ram
	out 	SPL, TEMP				//OUT SPL to TEMP
	ldi		TEMP, $1F				//Pins 0-5 output//Load immediate temp into $1F(HEX)
	out		DDRB, TEMP				//OUT DDRB into TEMP
	ldi		TEMP, $E0				//Load immediate TEMP into $E0(HEX)
	out		PORTB, TEMP				//PORTBOUT PORTB into TEMP
	out		PCMSK, TEMP				//OUT PCMSK into TEMP
	ldi		TEMP, (1<<TOIE1)		//Load TEMP into bit shift 1 TOIE1
	out		TIMSK, TEMP				//OUT TIMSK to TEMP

	ldi		TEMP, high(PERIOD)		//Load immediate into high byte PERIOD
	out		ICR1H, TEMP				//OUT ICR1H to TEMP
	ldi		TEMP, low(PERIOD)		//Load immediate TEMP into low byte PERIOD
	out		ICR1L, TEMP				//OUT ICR1L into TEMP

	ldi		TEMP, high(PWMmin)		//Load immediate TEMP into high byte PWMmax
	out		OCR1AH, TEMP			//OUT OCR1AH into TEMP
	/*mov		PWMH, TEMP				//Move PWMH into TEMP*/
	ldi		TEMP, low(PWMmin)		//Load immediate TEMP into low byte PWMmin
	out		OCR1AL, TEMP			//OUT OCR1AH, TEMP
	mov		PWML, TEMP				//Move PWML into TEMP

	ldi		TEMP, (1<<COM1A1)|(1<<WGM11)
	out		TCCR1A, TEMP

	ldi		TEMP, (1<<WGM13)|(1<<WGM12)|(1<<CS10)
	out		TCCR1B, TEMP

	sei
	
MAIN: 
	nop								//No operation
	nop								//No operation
	nop								//No operation
	rjmp	MAIN					//Loop to MAIN

T1overflow:
	push	TEMP					//Push temp onto stack
	in		TEMP, SREG				//Load TEMP into Register
	push 	TEMP					//Push temp onto stack
	sbis	PINB, PB5				//Set bit PINB to PB5
	rjmp	SWEEP					//Jump to breathe
	sbis	PINB, PB7				//Skip bit if register is set
	rjmp	COUNTdown				//Jump to function COUNTdown
	sbic	PINB, PB6				//Skip bit if register is clear
	rjmp 	RETURN					//Jump to function Return

COUNTup:
	ldi		TEMP, low(PWMstep)		//Load immediate Temp into Low PWMstep
	add		PWML, TEMP				//Add without carry PWL into TEMP
	ldi		TEMP, high(PWMstep) 	//Load immediate Temp into High PWMstep
	adc		PWMH, TEMP				//Add with carry PWMH into TEMP
	cbi		PORTB, PB1				//Turn off MIN indicator//Clear Bit in PORTB
	ldi 	TEMP, low(PWMmax)		//Load immediate TEMP into low pdmMAX
	cp		TEMP, PWML				//Compare TEMP and PWML
	ldi		TEMP, high(PWMmax)		//Load immediate TEMP into high pdmMAX
	cpc		TEMP, PWMH				//Compare with carry TEMP to PWMH
	brcc	PWMnotMAX				//Branch >=
	ldi		PWMH, high(PWMmax) 		//Load immediate PWMH into high pwmMAX (high byte)
	ldi		PWML, low(PWMmax)		//Load immediate PWML into low pwmMAX (low byte)
	sbi		PORTB, 0				//Turn on max indicator// Set it PORTB to 0
	sbi		GPIOR0, 0				//Set down flag//Set bit GPIORO to 0

PWMnotMAX:
	out		OCR1AH, PWMH			//OUT OCR1AH, to PWMH 
	out		OCR1AL, PWML			//OUT OCR1AL,to PWML

RETURN:
	pop		TEMP					//Pop TEMP off the stack
	out		SREG, TEMP				//SREG output to TEMP
	pop		TEMP					//Pop TEMP off the stack
	reti							//RETURN

COUNTdown:
	ldi		TEMP, low(PWMstep)		//Load immediate TEMP into low byte PWMstep
	sub		PWML, TEMP				//Subtract PWML from TEMP
	ldi		TEMP, high(PWMstep)		//Load TEMP into high byte PWMstep
	sbc		PWMH, TEMP				//Subtract PWMH from TEMP with carry
	cbi		PORTB, PB0				//Turn off MAX indicator//Clear bit on PORTB
	ldi		TEMP, low(PWMmin)		//Load immediate TEMP into low byte PWMmin
	cp		TEMP, PWML				//Compare TEMP to PWML
	ldi		TEMP, high(PWMmin)		//Load immediate TEMP into high byte pwmMIN
	cpc		TEMP, PWMH				//Compare with carry TEMP to PWMH
	brcs	PWMnotMIN				//Branch if CARRY set
	ldi		PWMH, high(PWMmin)		//Load immediate PWMH into high bit pwmMIN
	ldi		PWML, low(PWMmin)		//Load immediate PWML into low bit pwmMIN
	sbi		PORTB, 1				//Turn on MIN indicator//Set bit in PORTB to 1
	cbi		GPIOR0, 0				//Clear down flag(count up)//Set bit GPIORO to 0

PWMnotMIN:
	out		OCR1AH, PWMH			//OUT OCR1AH to PWMH
	out		OCR1AL, PWML			//OUT OCR1AL to PWML
	pop		TEMP					//Pop TEMp off the stack
	out		SREG, TEMP				//OUT SREG to TEMP
	pop		TEMP					//Pop TEMP off the stack
	reti							//Return

Breathe:
	sbis	GPIOR0, 0				//Set bit GPIORO to 0
	rjmp	COUNTup					//Jump to CountUP
	rjmp	COUNTdown				//Jump to CountDown

SWEEP:
	sbis	GPIOR0, 0
	rjmp	COUNTup
	rjmp	COUNTdown
