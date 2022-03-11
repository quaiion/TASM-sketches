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
; Exit:  BX = value extracted
; Note:  про количество цифор
; Destr: AX BX CX DX SI
;--------------------------------------------------------------

atoi		proc

		cld

		mov cx, si

		cmp byte ptr ds:[si], '-'
		je @@minus

@@begin:	lodsb
		cmp al, '9'
		ja @@stop_1
		cmp al, '0'
		jb @@stop_1
		jmp @@begin
		
@@stop_1:	sub cx, si
		sub si, cx
		sub cx, 1		; possibly fucks up all

		xor bx. bx
@@next:		cmp ch, 0
		je @@stop_2
		mov cl, byte ptr ds:[si]
		inc si
		sub cl, '0'
		dec ch			; possibly fucks up all
		push ch
		call tenpow		; ch == 0 and cx == cl after this
		mul cx
		add bx, ax
		pop ch
		jmp @@next

@@stop_2:	ret

@@minus:	inc si
		inc cx
		jmp @@begin
		
		endp

;--------------------------------------------------------------

;==============================================================
; 			Tool section
;==============================================================

;--------------------------------------------------------------
; Counts the n power of 10
; Enter: CH = power
; Exit:  AX = value counted
; Note:  про количество цифор
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
