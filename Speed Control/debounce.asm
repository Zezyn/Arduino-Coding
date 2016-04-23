;Demonstrate using an included MACRO file to debounce 

.def	TEMP = R16
.equ	DeBounceCount = 50

.nolist
//.include	"M328Pdef.inc"
.include	"tn2313def.inc"
.include	"DBmacro.inc"
.list

.ORG	$0000
		rjmp	RESET
.ORG	INT0addr
		rjmp	INT0isr

.ORG	INT_VECTORS_SIZE
RESET:
		ldi		TEMP, low(RAMEND)
		out		SPL, TEMP

#if defined(__ATmega328__) || defined(__ATmega164P__)
		ldi		TEMP, high(RAMEND)
		out		SPH, TEMP

		ldi		TEMP, (1<<ISC01)|(1<<ISC00)	;Sense INT0 Rising Edge
		sts		EICRA, TEMP

		ldi		TEMP, (1<<INT0)	;INT0 Enabled
		out		EIMSK, TEMP

#elif defined(__ATtiny2313__)
		ldi		TEMP, (1<<ISC01)|(1<<ISC00)	;Sense INT0 Rising Edge
		out		MCUCR, TEMP

		ldi		TEMP, (1<<INT0)	;INT0 Enabled
		out		GIMSK, TEMP
#else
#error "Unsupported Device:" __PART_NAME__
#endif

		sbi		PORTD, PD2	;INT0 Pull-Up Resistor Enabled

		sei

MAIN:
		nop
		nop
		nop
		rjmp	MAIN


INT0isr: ;Include Macro to Debounce PORTD pin PD2
		nop
		DEBOUNCE PIND, PD2, DeBounceCount
		inc		R17
		reti
