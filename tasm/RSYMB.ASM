.model tiny
.code
org 100h

start:          mov ah, 2
                mov dl, 0bh
                int 21h
                mov ah, 4ch
                mov al, 00h
                int 21h

.data

string	db 12 dup (12h)

end             start
