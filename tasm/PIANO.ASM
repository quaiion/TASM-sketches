.model tiny
.code
org 100h

NORELE          = 7fh

start:          mov ax, cs
                mov ds, ax
                mov ax, 2509h
                mov dx, offset new09h
                int 21h
		
		mov codseg, cs

                mov ax, 3100h
                mov dx, offset EOP
                shr dx, 4
                inc dx
                int 21h

;--------------------------------------------------------------

new09h          proc
                push ax

                mov al, 0b6h
                out 43h, al
                
                in al, 60h
                test al, 80h
                jz on
                
                in al, 61h              ; sound off
                and al, 0fch
                out 61h, al
                jmp stop

on:             cmp al, 13h             ; 'R' key
                jb stop
                cmp al, 26h             ; 'L' key
                ja stop

		push bx es

                xor bh, bh
                mov bl, al
                sub bx, 13h		; prepare the index
                shl bx, 1
		
		db 0b8h			; perform 'mov ax, <codseg>'
codseg		dw 0		
		mov es, ax
                mov ax, es:note[bx]

		pop es bx
                test ax, 0ffffh         ; maybe there are better solutions
                jz stop

                out 42h, al             ; set minor divisor digs
                mov al, ah
                out 42h, al             ; set major divisor digs
                
                in al, 61h              ; sound on
                or al, 3
                out 61h, al

stop:           in al, 61h              ; finish work with kybd
                mov ah, al
		or al, 80h
		out 61h, al
		mov al, ah
		out 61h, al

                mov al, 20h             ; finish the int
                out 20h, al

                pop ax
                iret
                endp

note            dw 0a00h, 0b3bh, 0000h, 0c98h, 0efdh, 10d4h, 0000h
                dw 0000h, 0000h, 0000h, 0000h, 0000h, 0000h, 096fh
                dw 0a98h, 0be4h, 0d5bh, 0e20h, 0fdah, 11cah

EOP:

end             start

;       notes' hex divisors list:
;       C       11cah
;       C#      10d4h
;       D       0fdah
;       D#      0efdh
;       E       0e20h
;       F       0d5bh
;       F#      0c98h
;       G       0be4h
;       G#      0b3bh
;       A       0a98h
;       A#      0a00h
;       B       096fh
