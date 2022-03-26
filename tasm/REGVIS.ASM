.model tiny
.code
org 100h

start:		mov ax, 3508h
                int 21h                 ; get old 08h handler's vector
                mov old08_seg, es
                mov old08_ofs, bx

                mov ax, cs
                mov ds, ax
                mov ax, 2509h
		mov dx, offset new09h
		int 21h			; set new 09h handler's vector

		mov codseg, cs

		mov ax, 3100h
		mov dx, offset EOP
		shr dx, 4
		inc dx
		int 21h

indic		db 0
codseg		dw 0

;--------------------------------------------------------------

new08h		proc
		push ax es

		mov ax, 0b800h
		mov es, ax

		mov ah, 04eh
                mov al, dl
                mov es:[(8*80 + 40) * 2], ax
		
		pop es ax

                db 0eah                 ; jmp far to old handler addr
		endp
old08_ofs       dw 0
old08_seg       dw 0

;--------------------------------------------------------------

new09h		proc
		push ax es
		
		in al, 60h
		cmp al, 12h
		jne iend
		
		xor ax, ax
		mov es, ax

		test indic, 0ffh
		jz tonew

		mov ax, old08_ofs
		cli
		mov es:[08h*4], ax
		mov ax, old08_seg
		mov es:[08h*4 + 2], ax
		sti
		not indic
		jmp iend

tonew:		mov ax, codseg
		cli
		mov es:[08h*4], offset new08h
		mov es:[08h*4 + 2], ax
		sti
		not indic

iend:		in al, 61h
		mov ah, al
		or al, 80h
		out 61h, al
		mov al, ah
		out 61h, al

		mov al, 20h
		out 20h, al

		pop es ax
		iret
		endp

;--------------------------------------------------------------

EOP:	

end		start
