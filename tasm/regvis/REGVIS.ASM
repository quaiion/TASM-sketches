.model tiny
.code
org 100h
locals @@

; Box params:

CLR             = 4eh
LTC             = 0d6h
RTC             = 0b7h
LBC             = 0d3h
RBC             = 0bdh
HL              = 0c4h
VL              = 0bah
WID             = 24
HEI             = 11
NLIN            = 4

VIDEOSEG        = 0b800h
MIDLINNUM       = BOX_START + (80d*(HEI/2) + (WID/2 + 5/2)) * 2

start:          mov ax, 3508h
                int 21h                 ; get old 08h handler's vector
                mov old08_seg, es
                mov old08_ofs, bx

                mov ax, cs
                mov ds, ax
                mov ax, 2509h
                mov dx, offset new09h
                int 21h                 ; set new 09h handler's vector
                
                mov al, 08h
                mov dx, offset new08h
                int 21h                 ; set new 08h handler's vector
                
                mov codseg1, cs
                mov codseg2, cs
                
                mov ax, cs
                mov es, ax
                mov ax, VIDEOSEG        ; bufferize videomem behind the box
                mov ds, ax
                mov si, BOX_START + 80d*2 * 2 ; 2 lines lower - bc of console scrolling
                mov di, offset boxbuf
buf:            mov cx, WID
buflin:         lodsw
                stosw
                loop buflin
                add si, (80d - WID) * 2
                cmp si, BOX_START + 80d * HEI * 2
                jne buf

                mov ax, 3100h
                mov dx, offset EOP
                shr dx, 4
                inc dx
                int 21h

indic           db 00h
boxbuf          dw WID * HEI * 2 dup (0)
numstr          db 4 dup (0)
TXT             db "Reg AX: 0000h$Reg BX: 0000h$Reg CX: 0000h$Reg DX: 0000h$"

;--------------------------------------------------------------

include STRlib.ASM
include BOXlib.ASM

new08h          proc
                push ax es

                db 0b8h                 ; perform 'mov ax, <codseg1>'
codseg1         dw 0
                mov es, ax

                test es:indic, 0ffh
                jnz unoff
                jmp off

unoff:          push cx dx di ds bp

                mov ax, VIDEOSEG
                mov ds, ax
                
                                        ; 4 different str bufs are not used below to avoid using strlen

                mov di, offset numstr
                call itoa_16
                dec cl                  ; exclude '$' symb
                mov ch, 4
                sub ch, cl              ; ch = num of prec zeros, cl = ndig

                mov di, MIDLINNUM + 80d * 2 * 3
zerd:           test ch, 0ffh
                jz ezerd
                mov byte ptr ds:[di], '0'
                add di, 2
                dec ch
                jmp zerd

ezerd:          mov si, offset numstr
digd:           mov al, es:[si]
                inc si
                mov ds:[di], al
                add di, 2
                loop digd               ; ch was zeroed anyway
                
                mov dx, bx
                mov di, offset numstr
                call itoa_16
                dec cl                  ; exclude '$' symb
                mov ch, 4
                sub ch, cl              ; ch = num of prec zeros, cl = ndig

                mov di, MIDLINNUM - 80d * 2
zerb:           test ch, 0ffh
                jz ezerb
                mov byte ptr ds:[di], '0'
                add di, 2
                dec ch
                jmp zerb

ezerb:          mov si, offset numstr
digb:           mov al, es:[si]
                inc si
                mov ds:[di], al
                add di, 2
                loop digb               ; ch was zeroed anyway
                
                mov bp, sp              ; to pull stuff from the stack

                mov dx, ss:[bp+10]
                mov di, offset numstr
                call itoa_16
                dec cl                  ; exclude '$' symb
                mov ch, 4
                sub ch, cl              ; ch = num of prec zeros, cl = ndig

                mov di, MIDLINNUM + 80d * 2
zerc:           test ch, 0ffh
                jz ezerc
                mov byte ptr ds:[di], '0'
                add di, 2
                dec ch
                jmp zerc

ezerc:          mov si, offset numstr
digc:           mov al, es:[si]
                inc si
                mov ds:[di], al
                add di, 2
                loop digc               ; ch was zeroed anyway

                mov dx, ss:[bp+12]
                mov di, offset numstr
                call itoa_16
                dec cl                  ; exclude '$' symb
                mov ch, 4
                sub ch, cl              ; ch = num of prec zeros, cl = ndig

                mov di, MIDLINNUM - 80d * 2 * 3
zera:           test ch, 0ffh
                jz ezera
                mov byte ptr ds:[di], '0'
                add di, 2
                dec ch
                jmp zera

ezera:          mov si, offset numstr
diga:           mov al, es:[si]
                inc si
                mov ds:[di], al
                add di, 2
                loop diga               ; ch was zeroed anyway

                pop bp ds di dx cx

off:            pop es ax

                db 0eah                 ; jmp far to old handler addr
                endp
old08_ofs       dw 0
old08_seg       dw 0

;--------------------------------------------------------------

new09h          proc
                push ax

                in al, 60h
                cmp al, 12h
                jne earlend

                push cx si di es ds
                
                db 0b8h                 ; perform 'mov ax, <codseg2>'
codseg2         dw 0
                mov ds, ax
                mov ax, VIDEOSEG
                mov es, ax

                test ds:indic, 0ffh
                jz turnon

                mov si, offset boxbuf
                mov di, BOX_START

debuf:          mov cx, WID
deblin:         lodsw
                stosw
                loop deblin
                add di, (80d - WID) * 2
                cmp di, BOX_START + 80d * HEI * 2
                jne debuf               ; may be safer to use jae

                not ds:indic
                jmp iend

turnon:         push bx dx

                call draw_box

                pop dx bx
                not ds:indic

iend:           pop ds es di si cx

earlend:        in al, 61h
                mov ah, al
                or al, 80h
                out 61h, al
                mov al, ah
                out 61h, al

                mov al, 20h
                out 20h, al

                pop ax
                iret
                endp

;--------------------------------------------------------------

EOP:

end             start
