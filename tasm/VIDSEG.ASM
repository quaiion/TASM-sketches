.model tiny
.code
org 100h

VIDEOSEG	equ 0b800h

_getch		macro
		xor ah, ah
		int 16h
		endm

start:		mov ax, VIDEOSEG
		mov es, ax

		_getch
		mov bx, (5 * 80d + 40d) * 2
		_getch
		mov byte ptr es:[bx], 'A'
		_getch
		mov byte ptr es:[bx+1], 0ceh
		_getch

		mov ax, 4c00h
		int 21h
		
end		start
