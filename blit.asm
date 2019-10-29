; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES eax edx ecx, x:DWORD, y:DWORD, color:DWORD

	xor edx, edx
	xor eax, eax
	mov eax, x
	cmp eax, 639
	jge dpo
	cmp eax, 0
	jl dpo
	xor eax, eax
	mov eax, y
	cmp eax, 479
	jge dpo
	cmp eax, 0
	jl dpo
	imul eax, 640
	add eax, x
	xor edx, edx
	mov edx, color
	mov ecx, [ScreenBitsPtr]
	mov [ecx + eax], edx 	;;; Mem[Addr of ScreenBitsPtr + eax] <- edx
					;;; Want:  Mem[Mem[ScreenBitsPtr]+eax] <- edx

dpo:	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD

	invoke RotateBlit, ptrBitmap, xcenter, ycenter, 0

	ret 			; Don't delete this line!!!	
BasicBlit ENDP


RotateBlit PROC USES eax edx ecx ebx esi edi, lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT

	LOCAL cosa, sina, shiftX, shiftY, dstWidth, dstHeight, dstX, dstY, srcX, srcY

	;initialize cos/sin values
	mov eax, angle
	invoke FixedCos, angle
	mov cosa, eax
	invoke FixedSin, angle
	mov sina, eax

	;initialize bitmap address in esi
	mov esi, lpBmp



	;setup for shiftX equation
	mov ecx, (EECS205BITMAP PTR [esi]).dwWidth
	shl ecx, 16							;shift to FXPT
	mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
	shl ebx, 16

	;(dwWidth * cosa / 2) -> edi
	mov eax, ecx
	imul cosa
	sar edx, 1
	mov edi, edx

	;edi - (dwHeight * sina / 2) - > shiftX
	mov eax, ebx
	imul sina
	sar edx, 1
	sub edi, edx
	mov shiftX, edi
	

	;(dwHeight * cosa / 2) -> edi
	mov eax, ebx
	imul cosa
	sar edx, 1
	mov edi, edx

	;edi + (dwWidth * sina / 2) -> shiftY
	mov eax, ecx
	imul sina
	sar edx, 1
	add edi, edx
	mov shiftY, edi


	
	;dstWidth = dwWidth + dwHeight, dstWidth = dstHeight
	shr ecx, 16
	shr ebx, 16
	mov eax, ecx
	add eax, ebx
	mov dstWidth, eax
	mov dstHeight, eax



	;for (dstX = -dstWidth; dstX < dstWidth; dstX++)
	;	dstX is edi
	mov edi, dstWidth
	neg edi
	mov dstX, edi

	;conditional1: edi < dstWidth
con1:	mov edi, dstX
	cmp edi, dstWidth
	jge bot1


		;for (dstY = -dstHeight; dstY < dstHeight; dstY++)
		;	dstY is edi
		mov edi, dstHeight
		neg edi
		mov dstY, edi

		;conditional2: edi < dstHeight
	con2:	mov edi, dstY
		cmp edi, dstWidth
		jge bot2

		;srcX = dstX*cosa + dstY*sina
		mov eax, dstX
		shl eax, 16
		imul cosa
		mov ecx, edx
		mov eax, dstY
		shl eax, 16
		imul sina
		add ecx, edx
		mov srcX, ecx

		;srcY = dstY*cosa - dstX*sina
		mov eax, dstY
		shl eax, 16
		imul cosa
		mov ecx, edx
		mov eax, dstX
		shl eax, 16
		imul sina
		sub ecx, edx
		mov srcY, ecx

		;;;;;
		;Monster IF block
		;;;;;;;;;;

		;if srcX >= 0
		mov eax, srcX
		cmp eax, 0
		jl pass

		;if srcX < dwWidth
		mov ecx, (EECS205BITMAP PTR [esi]).dwWidth
		cmp eax, ecx
		jge pass

		;if srcY >= 0
		mov eax, srcY
		cmp eax, 0
		jl pass

		;if srcY < dwHeight
		mov ecx, (EECS205BITMAP PTR [esi]).dwHeight
		cmp eax, ecx
		jge pass

		;if bitmap pixel (srcX,srcY) is not transparent)
		;	first: load .lpBytes then index based on x,y
		;	then compare the value to .bTransparent
		;	keep pixel around for DrawPixel call later
		mov eax, srcY
		imul (EECS205BITMAP PTR [esi]).dwWidth
		add eax, srcX
		xor edx, edx
		mov edi, (EECS205BITMAP PTR [esi]).lpBytes
		mov dl, [edi + eax]

		;compare to .bTransparent
		xor eax, eax
		mov al, (EECS205BITMAP PTR [esi]).bTransparent
		cmp al, dl
		je pass

		;;;
		;DrawPixel(xcenter+dstX-shiftX, ycenter+dstY-shiftY,bitmap pixel)
		;	the pixel is already stored in edi
		;;;;;;
		mov ecx, xcenter
		add ecx, dstX
		sub ecx, shiftX

		mov ebx, ycenter
		add ebx, dstY
		sub ebx, shiftY

		

		invoke DrawPixel, ecx, ebx, edx



		;dstY++
	pass:	inc dstY
		jmp con2

	bot2:

	;dstX++
	inc dstX
	jmp con1

bot1:	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END





























