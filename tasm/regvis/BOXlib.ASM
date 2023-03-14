;--------------------------------------------------------------

;       'locals @@' should be set
;       'VIDEOSEG = 0b800h' should be defined
;       'TXT db "<text>$"' should be defined

;       Adjusted parameters should be defined:

;       CLR             = 1eh
;       LTC             = '1'
;       RTC             = '2'
;       LBC             = '3'
;       RBC             = '4'
;       HL              = '='
;       VL              = '|'
;       WID             = 18
;       HEI             = 10
;       NLIN            = 3

;--------------------------------------------------------------

SCR_CENT        = (80d * 12d + 40d) * 2
ODD_BIT         = 0001h
BOX_START       = SCR_CENT - 80 * (HEI/2*2) - (WID/2*2)

;--------------------------------------------------------------
; Draws a custom box
; Entry: ES = video segment addr
;        DS = initial code seg
;        Constants and a string variable mentioned above should be defined
; Exit:  None
; Note:  None
; Destr: AX BX CX DX SI DI
;--------------------------------------------------------------

draw_box        proc

                mov ah, CLR
                mov di, BOX_START

                mov dl, LTC
                mov dh, RTC
                call draw_hor_line
                
                mov dl, HEI - (2*NLIN - 1) - 2
                test dl, ODD_BIT
                jz evn
                inc dl
evn:            shr dl, 1
                add di, (80d - WID) * 2
                call draw_emp_lays
                mov si, offset TXT
                call strlends
                call draw_text_lay
                
                mov ds:txt_ctr, NLIN - 1
doublin:        mov dl, 1
                call draw_emp_lays
                call strlends
                call draw_text_lay
                dec ds:txt_ctr
                test ds:txt_ctr, 0ffh
                jnz doublin
                
                mov dl, HEI - (2*NLIN - 1) - 2
                shr dl, 1
                call draw_emp_lays

                mov dl, LBC
                mov dh, RBC
                call draw_hor_line

                ret
                endp

txt_ctr         db 0

;--------------------------------------------------------------

;--------------------------------------------------------------
; Draws a horizontal line with corner symbs
; Entry: DL = left corner symb
;        DH = right corner symb
;        DI = start addr to draw
;        AH = color byte
;        WID defined as box's width const
;        HL defined as horiz line symb const
; Exit:  DI = ptr to videoseg cell after last filled
; Note:  ES = video segment addr
; Destr: AL CX DI
;--------------------------------------------------------------
                
draw_hor_line   proc

                cld
                mov al, dl
                stosw

                mov cx, WID - 2
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
;        DI = start addr to draw
;        CX = text string length
;        AH = color byte
;        WID defined as box's width const
;        VL defined as vert line symb const
; Exit:  DI = beginning of the next layer
;        SI = a ptr to char after '$'
; Note:  ES = video segment addr
;        DS = initial code seg
; Destr: AL BX CX DX SI DI
;--------------------------------------------------------------

draw_text_lay   proc

                cld
                mov al, VL
                stosw

                cmp cx, WID - 2
                je @@next
                mov dx, WID - 2
                sub dx, cx
                mov al, ' '
                test dx, ODD_BIT
                jz @@evn
                stosw
@@evn:          shr dx, 1
                mov bx, dx
                xchg dx, cx
                rep stosw
                mov cx, dx

@@next:         lodsb
                stosw
                loop @@next
                
                mov cx, bx
                mov al, ' '
                rep stosw

                mov al, VL
                stosw

                add di, (80d - WID) * 2
                inc si
                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; Draws a number of empty horizontal box layers
; Entry: DI = start addr to draw
;        DL = number of layers to be drawn
;        AH = color byte
;        WID defined as box's width const
;        VL defined as vert line symb const
; Exit:  DI = beginning of the next layer
; Note:  ES = video segment addr
; Destr: AL DL DI CX
;--------------------------------------------------------------

draw_emp_lays   proc

                cld

@@next:         mov cx, WID - 2
                test dl, 0ffh
                jz @@exit
                mov al, VL
                stosw
                mov al, ' '
                rep stosw
                mov al, VL
                stosw
                dec dl
                add di, (80d - WID) * 2
                jmp @@next

@@exit:         ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRLENds
; Counts number of symbols in a string
; Enter: SI = string addr
; Exit:  CX = number of symbs
; Note:  Direction flag is set to UP
;        Same as strlen but uses DS fixed segment instead of ES
; Destr: CX
;--------------------------------------------------------------

strlends        proc

                cld
                mov cx, si

@@next:         cmp byte ptr ds:[si], '$'
                je @@exit
                inc si
                jmp @@next

@@exit:         xchg si, cx
                sub cx, si
                ret
                endp

;--------------------------------------------------------------
