.model tiny
.code
org 100h

start:		xor di, di
		mov es, di
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

new09h		proc
		push ax es

		mov ax, 0b800h
		mov es, ax

		mov ah, 4eh
		in al, 60h
		mov es:[(5*80 + 80/2) * 2], ax

		in al, 61h
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
