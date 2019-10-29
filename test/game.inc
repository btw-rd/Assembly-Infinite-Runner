; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

;; User Defined Functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
ClearScreen PROTO
UpdatePlayer PROTO
DrawPlatform1 PROTO
DrawPlatform2 PROTO
DrawPlatform3 PROTO
PlatformCycle PROTO
CheckPause PROTO
CheckStart PROTO
CheckUnpause PROTO
Score PROTO
BgScroll PROTO

DrawPlayer PROTO

;; User Structures

playerObject STRUCT
 sprite	DWORD ?
 xpos		DWORD ?
 ypos		DWORD ?
 v		DWORD ?
 jumpcd	DWORD ?
 jumpstate  DWORD ?
playerObject ENDS

platformObject STRUCT
 horiz	DWORD ?
 spritePTR	DWORD ?
 xpos		DWORD ?
 ypos		DWORD ?
platformObject ENDS

bgObject STRUCT
 xpos		DWORD ?
 spritePTR	DWORD ?
bgObject ENDS

