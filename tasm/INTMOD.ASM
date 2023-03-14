.model tiny
.code
org 100h

start:          xor di, di
                mov es, di

                mov ax, es:[09h*4]
                mov old09_ofs, ax
                mov ax, es:[09h*4 + 2]
                mov old09_seg, ax

                cli
                mov es:[09h*4], offset new09h
                mov es:[09h*4 + 2], cs
                sti

                mov ax, 3100h
                mov dx, offset EOP
                shr dx, 4
                inc dx
                int 21h

;--------------------------------------------------------------

new09h          proc
                push ax es

                mov ax, 0b800h
                mov es, ax

                mov ah, 4eh
                in al, 60h
                mov es:[(5*80 + 80/2) * 2], ax
                
                pop es ax

                db 0eah                 ; jmp far to old handler addr
                endp
old09_ofs       dw 0
old09_seg       dw 0

;--------------------------------------------------------------

EOP:

end             start
