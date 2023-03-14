.model tiny
.code
org 100h
locals @@

; These constants can be adjusted
;--------------------------------------------------------------
LT_CORNER_SYM   = 0d6h
RT_CORNER_SYM   = 0b7h
LB_CORNER_SYM   = 0d3h
RB_CORNER_SYM   = 0bdh
VERT_SYM        = 0bah
HOR_SYM	        = 0c4h

FRAM_LT_Y       = 6d
FRAM_LT_X       = 24d
FRAM_HEI        = 4d
FRAM_WID        = 24d

COLOR_BYTE      = 04eh
;--------------------------------------------------------------

VIDEOSEG        = 0b800h
FRAM_START      = ((FRAM_LT_Y - 1) * 80d + FRAM_LT_X - 1) * 2

start:          mov ax, VIDEOSEG
                mov es, ax

                mov si, offset up_hor_edge
                mov di, FRAM_START
                mov cx, FRAM_WID - 2
                call draw_hor_line

                mov di, FRAM_START + 2 * 80d
                mov cx, FRAM_HEI - 2
                call draw_ver_line

                mov di, FRAM_START + 2 * (80d + FRAM_WID - 1)
                mov cx, FRAM_HEI - 2
                call draw_ver_line

                mov si, offset dn_hor_edge
                mov di, FRAM_START + (FRAM_HEI - 1) * 80d * 2
                mov cx, FRAM_WID - 2
                call draw_hor_line

                mov ax, 4c00h
                int 21h

up_hor_edge     db LT_CORNER_SYM, HOR_SYM, RT_CORNER_SYM
dn_hor_edge     db LB_CORNER_SYM, HOR_SYM, RB_CORNER_SYM

;--------------------------------------------------------------
; Draws a horizontal line with corner symbs
; Entry: SI = addr of array containing frame symbols: [lft_cor][lin][rgt_cor]
;        DI = start addr to draw
;        CX = line length (without corners)
; Exit:  None
; Note:  ES = video segment addr
;        Color byte constant (COLOR_BYTE) should be defined
; Destr: AX CX SI DI
;--------------------------------------------------------------

draw_hor_line	proc
                
                cld                     ; Just playing safe

                mov ah, COLOR_BYTE

                lodsb
                stosw
                lodsb
                rep stosw
                lodsb
                stosw

                ret
                endp

;--------------------------------------------------------------
; Draws a vertical line (without corner symbs)
; Entry: DI = start addr to draw
;        CX = line length
; Exit:  None
; Note:  ES = video segment addr
;        Color byte constant (COLOR_BYTE) should be defined
;        Vertical edge symb constant (VERT_SYM) should be defined
; Destr: AX CX DI
;--------------------------------------------------------------

draw_ver_line   proc

                cld

                mov al, VERT_SYM
                mov ah, COLOR_BYTE

@@next:         cmp cx, 0
                jbe @@exit 
                stosw
                add di, 158d
                dec cx
                jmp @@next
                
@@exit:         ret
                endp

end             start
