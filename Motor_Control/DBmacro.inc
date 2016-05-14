;Macro Usage:  DEBOUNCE (InputPORT), Pin(0-7)
;Example:  DEBOUNCE PORTD, PD2

.MACRO DEBOUNCE
	push	R16	;Input Port
	push	R17	;TempRead
	push	R18	;COUNT
	push	R19	;MASK
	in		R16, SREG
	push	R16
	ldi		R19, @1

DBinit:
	in		R16, @0		;Read Input Port
	and		R16, R19	;Clear Untested Bits
	ldi		R18, @2		;Load Counter
DBread:
	in		R17, @0
	and		R17, R19
	cp		R17, R16
	brne	DBinit
	dec		R18
	brne	DBread

	pop 	R16
	out 	SREG, R16
	pop 	R19
	pop 	R18
	pop 	R17
	pop 	R16
.ENDMACRO
.LISTMAC
