; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;   BRENDAN WART - BTW4293 - BRENDAN WARD - BTW4293
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES eax edx ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
        LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD, curr_x:DWORD, curr_y:DWORD, prev_error:DWORD
	
	;; Place your code here
        xor edx, edx
        xor eax, eax
        mov eax, x1             ;;delta_x = abs(x1-x0)
        sub eax, x0
        cmp eax, 0
        jge mdX
        neg eax
   mdX: mov delta_x, eax
   
        xor ebx, ebx            ;;delta_y = abs(y1-y0)
        mov ebx, y1
        sub ebx, y0
        cmp ebx, 0
        jge mdY
        neg ebx
   mdY: mov delta_y, ebx

  xcmp: xor eax, eax
        mov eax, x0
        cmp eax, x1             ;;if (x0 < x1)
        jge inxn
        mov inc_x, 1            ;;inc_x = 1
        jmp ycmp
  inxn: mov inc_x, -1           ;;else inc_x = -1
  
  ycmp: xor ebx, ebx
        mov ebx, y0
        cmp ebx, y1             ;;if (y0 < y1)
        jge inyn
        mov inc_y, 1            ;;inc_y = 1
        jmp dlta
  inyn: mov inc_y, -1           ;;else inc_y = -1
  
  dlta: xor ebx, ebx
        mov ebx, 2
        xor eax, eax
        mov eax, delta_x        ;;if (delta_x > delta_y)
        cmp eax, delta_y
        jle edY
        xor edx, edx
        idiv ebx                ;;eax = delta_x/2
        mov error, eax          ;;error = eax
        jmp curr
   edY: xor eax, eax
        xor edx, edx
        mov eax, delta_y
        idiv ebx                ;;eax = - delta_y/2
        neg eax
        mov error, eax          ;;error = eax
        
  curr: xor eax, eax
        mov eax, x0
        mov curr_x, eax         ;;curr_x = x0
        xor eax, eax
        mov eax, y0
        mov curr_y, eax         ;;curr_y = y0
        
        invoke DrawPixel, curr_x, curr_y, color



  eval: xor eax, eax            ;;logic of while condition
        mov eax, curr_x         ;;curr_x != x1
        cmp eax, x1
        jne bod
        xor eax, eax            ;;curr_y != y1
        mov eax, curr_y
        cmp eax, y1
        je pass
        
   bod: invoke DrawPixel, curr_x, curr_y, color
        xor eax, eax            ;;prev_error = error
        mov eax, error
        mov prev_error, eax
        
        xor ebx, ebx            ;;if (prev_error > - delta_x)
        mov ebx, delta_x
        neg ebx
        cmp eax, ebx
        jle next
        
        sub eax, delta_y        ;;error = error - delta_y
        mov error, eax
        xor eax, eax            ;;curr_x = curr_x + inc_x
        mov eax, curr_x
        add eax, inc_x
        mov curr_x, eax
        
  next: xor eax, eax            ;;if (prev_error < delta_y)
        mov eax, prev_error
        xor ebx, ebx
        mov ebx, delta_y
        cmp eax, ebx
        jge eval
        
        xor eax, eax            ;;error = error + delta_x
        mov eax, error
        add eax, delta_x
        mov error, eax
        xor eax, eax            ;;curr_y = curr_y + inc_y
        mov eax, curr_y
        add eax, inc_y
        mov curr_y, eax
        jmp eval
        
  pass:


	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
