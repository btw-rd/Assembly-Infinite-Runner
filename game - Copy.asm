; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
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
include game.inc
include fighter_000.asm
include asteroid_000.asm
include platSpriteS.asm
include platSpriteM.asm
include platSpriteL.asm
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

;; Has keycodes
include keys.inc

	
.DATA

;; If you need to, you can place global variables here
	
platform1 platformObject <300, OFFSET platSpriteS, 125, 440>
platform2 platformObject <300, OFFSET platSpriteS, 445, 440>
platform3 platformObject <300, OFFSET platSpriteS, 765, 440>
player playerObject <OFFSET fighter_000,100,240,0,6,0>
colStr BYTE "Collision Detected!", 0

.CODE
	

;; Note: You will need to implement CheckIntersect!!!

GameInit PROC
	
	invoke DrawPlayer
	
	invoke DrawPlatform1
	invoke DrawPlatform2
	invoke DrawPlatform3

	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC

	invoke ClearScreen

	;invoke PlatformCycle
	invoke DrawPlatform1
	invoke DrawPlatform2
	invoke DrawPlatform3

	invoke UpdatePlayer
	invoke DrawPlayer


	ret         ;; Do not delete this line!!!
GamePlay ENDP

ClearScreen PROC USES eax ecx edi
	cld
	mov eax, 000h
	mov ecx, 480*640
	mov edi, ScreenBitsPtr
	rep stosb
	ret
ClearScreen ENDP

UpdatePlayer PROC USES eax
	mov eax, [KeyPress]
pjmp:
	cmp eax, VK_W
	jne pjp
	cmp player.jumpcd, 0
	jl pjp
	cmp player.jumpstate, 0
	jne pjs1
	invoke DrawPixel, 15,10,000FFF000h
	mov player.v, -30
	mov player.jumpstate, 1
	jmp pup
pjs1:
	invoke DrawPixel, 10,10,000000FFFh
	mov eax, player.jumpcd
	add player.v, eax
	jmp pup
pjp:
	mov player.jumpstate, 2
	invoke CheckIntersect, player.xpos, player.ypos, player.sprite, platform1.xpos, platform1.ypos, platform1.spritePTR
	cmp eax, 0
	jne p1nt
	invoke CheckIntersect, player.xpos, player.ypos, player.sprite, platform2.xpos, platform2.ypos, platform2.spritePTR
	cmp eax, 0
	jne p2nt
	invoke CheckIntersect, player.xpos, player.ypos, player.sprite, platform3.xpos, platform3.ypos, platform3.spritePTR
	cmp eax, 0
	jne p3nt
pup:
	add player.v, 2
	mov eax, player.v
	add player.ypos, eax
	dec player.jumpcd
	jmp pps
p1nt:
	mov player.jumpcd, 5
	mov player.v, 0
	mov eax, platform1.ypos
	sub eax, 135
	mov player.ypos, eax
	mov player.jumpstate, 0
	jmp pps
p2nt:
	mov player.jumpcd, 5
	mov player.v, 0
	mov eax, platform2.ypos
	sub eax, 135
	mov player.ypos, eax
	mov player.jumpstate, 0
	jmp pps
p3nt:
	mov player.jumpcd, 5
	mov player.v, 0
	mov eax, platform3.ypos
	sub eax, 135
	mov player.ypos, eax
	mov player.jumpstate, 0
pps:
	ret
UpdatePlayer ENDP

IntersectText PROC USES eax
	;invoke CheckIntersect, player.xpos, player.ypos, player.sprite, reticle.xpos, reticle.ypos, reticle.sprite
	;cmp eax, 0
	;je intp
	;invoke DrawStr, OFFSET colStr, 20, 20, 0ffh
intp:
	ret
IntersectText ENDP

DrawPlayer PROC
	invoke BasicBlit, player.sprite, player.xpos, player.ypos
	ret
DrawPlayer ENDP

DrawPlatform1 PROC
	invoke BasicBlit, platform1.spritePTR, platform1.xpos, platform1.ypos
	ret
DrawPlatform1 ENDP

DrawPlatform2 PROC
	invoke BasicBlit, platform2.spritePTR, platform2.xpos, platform2.ypos
	ret
DrawPlatform2 ENDP

DrawPlatform3 PROC
	invoke BasicBlit, platform3.spritePTR, platform3.xpos, platform3.ypos
	ret
DrawPlatform3 ENDP

PlatformCycle PROC USES eax edx ebx ecx edi esi
	
	;;;PLATFORM 1
	mov esi, platform1.xpos
	mov edi, platform1.horiz

	;if (xpos < neg(horiz/2))
	sar edi, 1
	neg edi
	cmp esi, edi
	jge p1ps
	
	;mask last 2 bits of cycle count for random platform width 1-3
	rdtsc
	and eax, 011b
	cmp eax, 000b
	je p1hs
	cmp eax, 001b
	jne p1hm
	;on smallest 2: set horiz and sprite to smallest preset
p1hs:	mov ebx, 250
	mov ecx, OFFSET platSpriteS
	mov platform1.horiz, ebx
	mov platform1.spritePTR, ecx
	jmp p1xp
p1hm:	cmp eax, 010b
	jne p1hl
	mov ebx, 350
	mov ecx, OFFSET platSpriteM
	mov platform1.horiz, ebx
	mov platform1.spritePTR, ecx
	jmp p1xp
p1hl:	mov ebx, 450
	mov ecx, OFFSET platSpriteL
	mov platform1.horiz, ebx
	mov platform1.spritePTR, ecx

	;Xpos = preceding_plat.xpos + preceding_plat.horiz/2 + horiz/2 + gap
p1xp:	sar ebx, 1	;horiz/2
	mov ecx, platform3.horiz
	sar ecx, 1	; preceding_plat.horiz/2
	mov edi, platform3.xpos
	add edi, ecx
	add edi, ebx
	add edi, 70
	mov platform1.xpos, edi
	
	cmp eax, 000b
	je p1ad
	cmp eax, 010b
	jne p1sb
p1ad:	sal eax, 2
	add platform1.ypos, eax
	cmp platform1.ypos, 550
	jle p1ps
	sub platform1.ypos, eax
	jmp p1ps
p1sb: sal eax, 2
	sub platform1.ypos, eax
	cmp platform1.ypos, 360
	jge p1ps
	add platform1.ypos, eax
p1ps:	sub platform1.xpos, 10

	;;;PLATFORM 2
	mov esi, platform2.xpos
	mov edi, platform2.horiz

	;if (xpos < neg(horiz/2))
	sar edi, 1
	neg edi
	cmp esi, edi
	jge p2ps
	
	;mask last 2 bits of cycle count for random platform width 1-3
	rdtsc
	and eax, 011b
	cmp eax, 000b
	je p2hs
	cmp eax, 001b
	jne p2hm
	;on smallest 2: set horiz and sprite to smallest preset
p2hs:	mov ebx, 250
	mov ecx, OFFSET platSpriteS
	mov platform2.horiz, ebx
	mov platform2.spritePTR, ecx
	jmp p2xp
p2hm:	cmp eax, 010b
	jne p2hl
	mov ebx, 350
	mov ecx, OFFSET platSpriteM
	mov platform2.horiz, ebx
	mov platform2.spritePTR, ecx
	jmp p2xp
p2hl:	mov ebx, 450
	mov ecx, OFFSET platSpriteL
	mov platform2.horiz, ebx
	mov platform2.spritePTR, ecx

	;Xpos = preceding_plat.xpos + preceding_plat.horiz/2 + horiz/2 + gap
p2xp:	sar ebx, 1	;horiz/2
	mov ecx, platform1.horiz
	sar ecx, 1	; preceding_plat.horiz/2
	mov edi, platform1.xpos
	add edi, ecx
	add edi, ebx
	add edi, 70
	mov platform2.xpos, edi
	
	cmp eax, 000b
	je p2ad
	cmp eax, 010b
	jne p2sb
p2ad:	sal eax, 2
	add platform2.ypos, eax
	cmp platform2.ypos, 550
	jle p2ps
	sub platform2.ypos, eax
	jmp p2ps
p2sb: sal eax, 2
	sub platform2.ypos, eax
	cmp platform2.ypos, 360
	jge p2ps
	add platform2.ypos, eax
p2ps:	sub platform2.xpos, 10

	;;;PLATFORM 3
	mov esi, platform3.xpos
	mov edi, platform3.horiz

	;if (xpos < neg(horiz/2))
	sar edi, 1
	neg edi
	cmp esi, edi
	jge p3ps
	
	;mask last 2 bits of cycle count for random platform width 1-3
	rdtsc
	and eax, 011b
	cmp eax, 000b
	je p3hs
	cmp eax, 001b
	jne p3hm
	;on smallest 2: set horiz and sprite to smallest preset
p3hs:	mov ebx, 250
	mov ecx, OFFSET platSpriteS
	mov platform3.horiz, ebx
	mov platform3.spritePTR, ecx
	jmp p3xp
p3hm:	cmp eax, 010b
	jne p3hl
	mov ebx, 350
	mov ecx, OFFSET platSpriteM
	mov platform3.horiz, ebx
	mov platform3.spritePTR, ecx
	jmp p3xp
p3hl:	mov ebx, 450
	mov ecx, OFFSET platSpriteL
	mov platform3.horiz, ebx
	mov platform3.spritePTR, ecx

	;Xpos = preceding_plat.xpos + preceding_plat.horiz/2 + horiz/2 + gap
p3xp:	sar ebx, 1	;horiz/2
	mov ecx, platform2.horiz
	sar ecx, 1	; preceding_plat.horiz/2
	mov edi, platform2.xpos
	add edi, ecx
	add edi, ebx
	add edi, 70
	mov platform3.xpos, edi
	
	cmp eax, 000b
	je p3ad
	cmp eax, 010b
	jne p3sb
p3ad:	sal eax, 2
	add platform3.ypos, eax
	cmp platform3.ypos, 550
	jle p3ps
	sub platform3.ypos, eax
	jmp p3ps
p3sb: sal eax, 2
	sub platform3.ypos, eax
	cmp platform3.ypos, 360
	jge p3ps
	add platform3.ypos, eax
p3ps:	sub platform3.xpos, 10

	ret

PlatformCycle ENDP

CheckIntersect PROC USES esi edi ebx ecx edx, oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP

	LOCAL t1, t2, b1, b2, r1, r2, l1, l2

	xor esi, esi
	mov esi, oneBitmap
	
	;setup top/bottom/left/right 1
	xor ebx, ebx
	mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
	shr ebx, 1

	mov eax, oneY
	add eax, ebx
	mov b1, eax

	mov eax, oneY
	sub eax, ebx
    	mov t1, eax
	
	mov ebx, (EECS205BITMAP PTR [esi]).dwWidth
	shr ebx, 1

	mov eax, oneX
	add eax, ebx
	mov r1, eax

	mov eax, oneX
	sub eax, ebx
	mov l1, eax

	;load twoBitmap
	mov esi, twoBitmap
	
	;setup top/bottom/left/right 2
	xor ebx, ebx
	mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
	shr ebx, 1

	mov eax, twoY
	add eax, ebx
	mov b2, eax

	mov eax, twoY
	sub eax, ebx
    	mov t2, eax
	
	mov ebx, (EECS205BITMAP PTR [esi]).dwWidth
	shr ebx, 1

	mov eax, twoX
	add eax, ebx
	mov r2, eax

	mov eax, twoX
	sub eax, ebx
	mov l2, eax

	
	;comparison logic
	xor eax, eax

	;check top1 past bot2
	mov ecx, t1
	cmp ecx, b2
	jge colp
	;check top2 past bot1
	mov ecx, b1
	cmp ecx, t2
	jle colp
	;check left1 past right2
	mov ecx, l1
	cmp ecx, r2
	jge colp
	;check left2 past right1
	mov ecx, r1
	cmp ecx, l2
	jle colp
	
	;if all failed, bitmaps must intersect
	mov eax, 1b

colp:

	ret		;; Do not delete this line!!!
CheckIntersect ENDP

END























