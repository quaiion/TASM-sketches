.model tiny
.code
org 100h
locals @@

; Parameters taken from the command prompt:

HEI		equ byte ptr cs:[92h]
WID		equ byte ptr cs:[90h]
LTC		equ byte ptr cs:[84h]
LBC		equ byte ptr cs:[88h]
RTC		equ byte ptr cs:[86h]
RBC		equ byte ptr cs:[8ah]
HL		equ byte ptr cs:[8ch]
VL		equ byte ptr cs:[8eh]
CLR		equ byte ptr cs:[82h]
TXT		equ byte ptr cs:[94h]

; PSP-stored parameter string format:
;--------------------------------------------------------------
; [CLR][ ][LTC][ ][RTC][ ][LBC][ ][RBC][ ][HL][ ][VL][ ][WID][ ][HEI][ ][TXT...]
;   |       |       |       |       |      |      |       |       |       |    
; cs:82h  cs:84h  cs:86h  cs:88h  cs:8Ah cs:8Ch cs:8Eh  cs:90h  cs:92h  cs:94h
;--------------------------------------------------------------

VIDEOSEG	= 0b800h
SCR_CENT	= (80d * 12d + 40d) * 2
; Box starts at 2 * ((12d - HEI/2) * 80d + 40d - WID/2)

start:		mov ax, VIDEOSEG
		mov es, ax

		mov al, 80d
		mul HEI
		mov start_addr, SCR_CENT
		sub start_addr, ax
		mov bl, WID
		xor bh, bh
		sub start_addr, bx
		shr start_addr, 1
		shl start_addr, 1
		sub bx, 2		; now WID-2 can be reached through bx

		mov dl, LTC
		mov dh, RTC
		mov di, start_addr
		mov cx, bx
		call draw_hor_line
		
		mov dl, HEI
		sub dl, 2
		mov cx, bx
		mov di, start_addr
		add di, 80d * 2
		call draw_emp_lays

		mov dl, LTC
		mov dh, RTC
		mov di, start_addr
		mov cx, bx
		mov bh, HEI
		sub bh, 1
		mov al, 80d * 2
		mul bh
		add di, ax
		call draw_hor_line

		mov ax, 4c00h
		int 21h

start_addr	dw ?

;--------------------------------------------------------------
; Draws a horizontal line with corner symbs
; Entry: DL = left corner symb
;	 DH = right corner symb
;	 DI = start addr to draw
;	 CX = line length (excl corners)
; Exit:  None
; Note:  ES = video segment addr
;	 Color byte ptr constant (CLR) should be defined
;	 Right and left top corners byte ptr constants (LTC, RTC)
;	 should be defined
; Destr: AX CX DI
;--------------------------------------------------------------
		
draw_hor_line	proc

		cld

		mov ah, CLR
		mov al, dl
		stosw

		mov al, HL
		rep stosw

		mov al, dh
		stosw

		ret
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; Draws a text layer of the box
; Entry: SI = addr of the text start
;	 DI = start addr to draw
; 	 CX = text string length
; Exit:  SI = byte ptr to a symb, following after last typed
; Note:  ES = video segment addr
;	 Color byte ptr constant (CLR) should be defined
;	 Vertical edge symb byte ptr constant (VL) should be defined
; Destr: AX CX SI DI
;--------------------------------------------------------------

draw_hor_lay	proc

		cld

		mov ah, CLR
		mov al, VL		
		stosw

		jcxz @@skip
@@next:		lodsb		
		stosw
		loop @@next

@@skip:		mov al, VL
		stosw

		ret
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; Draws a number of empty horizontal box layers
; Entry: DI = start addr to draw
;	 CX = one layer's length (excl edge symbs)
;	 DL = number of layers to be drawn
;	 BX = box's width - 2
; Exit:  None
; Note:	 ES = video segment addr
;	 Color byte ptr constant (CLR) should be defined
;	 Box width byte ptr constant (WID) should be defined
;	 Vertical edge symb byte ptr constant (VL) should be defined
; Destr: AX DL DI CX
;--------------------------------------------------------------

draw_emp_lays	proc

		cld

		mov ah, CLR
		push cx

@@next:	cmp dl, 0
		jbe @@exit

		mov al, VL
		stosw
		mov al, ' '
		rep stosw
		mov al, VL
		stosw

		dec dl
		add di, 80d * 2
		mov cx, bx
		add cx, 2
		shl cx, 1
		sub di, cx
		pop cx
		push cx
		jmp @@next

@@exit:	ret
		endp

;--------------------------------------------------------------

end		start
