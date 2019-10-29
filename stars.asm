; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;   BRENDAN WARD BTW4293
;   BRENDAN WARD BTW4293
;   BRENDAN WARD BTW4293
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here
      invoke DrawStar, 170, 120; creates a star at x=170, y=120
      invoke DrawStar, 200, 100
      invoke DrawStar, 220, 115
      invoke DrawStar, 280, 80
      invoke DrawStar, 60, 150
      invoke DrawStar, 360, 100
      invoke DrawStar, 490, 30
      invoke DrawStar, 600, 150
      invoke DrawStar, 620, 240
      invoke DrawStar, 530, 30
      invoke DrawStar, 490, 120
      invoke DrawStar, 370, 200
      invoke DrawStar, 100, 50
      invoke DrawStar, 640, 170
      invoke DrawStar, 130, 180
      invoke DrawStar, 550, 100
      invoke DrawStar, 300, 70

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
