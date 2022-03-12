.model tiny
.code
org 100h
locals @@

VIDEOSEG	= 0b800h

start:		

		push VIDEOSEG
		pop es

		mov si, offset string
		call atoi
		
		mov ah, 2
		mov di, 

		mov ax, 4c00h
		int 21h

string		db '112'

;==============================================================
;		      Function section
;==============================================================

;--------------------------------------------------------------
; STRLEN
; Counts number of symbols in a string
; Enter: SI = string addr
; Exit:  BX = number of symbs
; Note:	 None
; Destr: SI BX AL
;--------------------------------------------------------------

strlen		proc

		cld

		mov bx, si

@@next:		lodsb		; can be done without loading to register
		cmp al, 0
		jne @@next

		sub si, bx
		dec si
		mov bx, si	; idk how ABI works but this looks safer

		ret
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCHR
; Searches for a character in a string
; Enter: SI = string addr
;	 DL = ASCII code of character searched
; Exit:  BX = first appearance addr (-1 if no searched char found)
; Note:  None
; Destr: SI BX AL
;--------------------------------------------------------------

		; not sure if it works with memory in a correct way or not

strchr		proc

		cld

@@next:		lodsb
		cmp al, 0
		je @@stop
		cmp al, dl
		jne @@next

		mov bx, si
		dec bx
		ret

@@stop:		mov bx, -1
		ret
		
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCPY
; Copies all the string characters to another string
; Enter: SI = source string addr
;	 DI = dest string addr
; Exit:  None
; Note:  Be aware of dest buffer overflow, string sizes are not compared
; Destr: SI DI AL
;--------------------------------------------------------------

strcpy		proc

		cld

@@next:		lodsb
		stosw
		cmp al, 0
		jne @@next

		ret
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCMP
; Compares 2 strings in lexicographic order
; Enter: SI = first string compared addr
;	 DI = second string compared addr
; Exit:  AL > 0 if first str is greater
;	 AL < 0 if second str is greater
;	 AL = 0 if strings are similar
; Note:  None
; Destr: Destr: SI DI AX
;--------------------------------------------------------------

strcmp		proc

		cld

@@next:		lodsb
		mov ah, byte ptr ds:[di]
		inc di
		sub al, ah
		cmp al, 0
		je @@ifend
		ret

@@ifend:	cmp ah, 0
		jne @@next
		ret

		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA
; Creates a string with a number of radix mentioned
; Enter: 
; Exit: 
; Note: 
; Destr:
;--------------------------------------------------------------

itoa		proc



		ret
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; ATOI
; Extracts a decimal number from a string
; Enter: SI = string addr
; Exit:  BX = signed value extracted
; Note:  The value extracted can be a number from -2147483648 to 2147483647 inclusively
; Destr: AX BX CX DX
;--------------------------------------------------------------

atoi		proc

		cld
		xor ch, ch		; ch will be 0 if val is pos and nonnull if val is neg
		mov bx, si
		cmp byte ptr ds:[si], '-'
		jne @@begin
		inc si
		inc bx
		not ch

@@begin:	lodsb
		cmp al, '9'
		ja @@stop
		cmp al, '0'
		jb @@stop
		jmp @@begin
		
@@stop:		mov dx, si
		sub dx, bx		; dh == 0, number is too low to fill it, cl contains the num of digits
		mov cl, dl
		dec si

		mov bx, 1
@@next:		cmp cl, 0
		jb @@exit
		mov al, byte ptr ds:[si]
		dec si
		sub al, '0'
		dec cl
		xor ah, ah
		mul bx
		add offset resval, ax
		mov ax, 10
		mul bx
		mov bx, ax
		jmp @@next
		
@@exit:		mov bx, offset resval
		jcxz @@nonneg		; cl == 0 (end of loop) checking ch
		neg bx
		ret

@@nonneg:	inc si
		ret

		endp

;--------------------------------------------------------------

;==============================================================
; 			Tool section
;==============================================================

;--------------------------------------------------------------
; Counts the N power of 10
; Enter: CH = power (N)
; Exit:  AX = value counted
; Note:  N can be a number from 0 to 9 inclusively
; Destr: AX CH DX
;--------------------------------------------------------------

tenpow		proc

		mov ax, 10

@@pow:		cmp ch, 0
		je @@stop
		mov dx, 10
		mul dx
		dec ch
		jmp @@pow

@@stop:		ret
		endp

;--------------------------------------------------------------

end		start
