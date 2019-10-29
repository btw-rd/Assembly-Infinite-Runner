; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSin PROC USES edx ebx ecx, angle:FXPT

	;brings angles into 0-2pi if outside that
	
	xor ecx, ecx
	xor eax, eax
	mov eax, angle
tpic:	cmp eax, TWO_PI
	jl npic
	sub eax, TWO_PI
	jmp tpic

npic: cmp eax, 0
	jg pic
	add eax, TWO_PI
	jmp npic

	;brings angles into 0-pi if outside that, store flag for negation at end
	
pic:	cmp eax, PI
	jl pihc
	xor ecx, ecx
	inc ecx
	sub eax, PI

	;performs swaps for angles between pi/2 and pi

pihc:	cmp eax, PI_HALF
	jne phcp
	inc eax
phcp:	jl sin
	xor edx, edx
	mov edx, eax
	mov eax, PI
	sub eax, edx

	;only focused on 0-pi/2
	;return value at index of SINTAB
	;where index = angle * 256/pi

sin:	xor edx, edx
	mov ebx, PI_INC_RECIP
	imul ebx					;eax = angle*256*1/pi
	xor eax, eax
	mov ax, WORD PTR [ SINTAB + 2 * edx ]		;move WORD at SINTAB[eax WORDS] to eax to retrun
	cmp ecx, 0					;follow up on negation flag from before
	je bot
	neg eax	

bot:	ret			; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC angle:FXPT

	;cos (x) = sin (x + Pi/2)
	;add PI_HALF to angle and call FixedSin on that value

	mov eax, angle
	add eax, PI_HALF
	invoke FixedSin, eax

	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
