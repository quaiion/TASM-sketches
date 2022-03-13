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
;		       Function section
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
; ITOA_10
; Creates a string with an unsigned decimal number mentioned
; Enter: DX = UNSIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
; Destr: 
;--------------------------------------------------------------

itoa_10		proc



		ret
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_10
; Creates a string with a signed decimal number mentioned
; Enter: DX = SIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
; Destr: 
;--------------------------------------------------------------

sitoa_10	proc

		ret
		endp
		
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_2
; Creates a string with an unsigned binary number mentioned
; Enter: DX = UNSIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_B	= 80h
JUNIOR_BITS_B	= 01h

itoa_2		proc

		xor cx, cx
@@find:		cmp cl, 10h
		je @@zero
		test dh, SENIOR_BITS_B
		jnz @@rdy
		inc cl			; resulting ch == number of preceding zeros
		shl dx
		jmp @@find

@@rdy:		shr dx, cl
		mov ah, 10h
		sub ah, cl
		mov cl, ah		; cx == number of digits
		add di, cx		; cl == cx
		dec di

		std
		mov es, ds
@@next:		mov al, dl
		and al, JUNIOR_BITS_B
		add al, '0'
		stosb
		ror dx
		loop @@next
		
		mov cl, ah		; cl == nbits == ndigits
		rol dx, cl		; restoring the original value
		inc di
		ret

@@zero:		mov cl, 1
		mov byte ptr ds:[di], '0'
		ret

		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_2
; Creates a string with a signed binary number mentioned
; Enter: DX = SIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_2		proc

		ret
		endp
		
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_4
; Creates a string with an unsigned quaternery number mentioned
; Enter: DX = UNSIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_Q	= 0c0h
JUNIOR_BITS_Q	= 03h

itoa_4		proc

		xor cx, cx
@@find:		cmp cl, 10h
		je @@zero
		test dh, SENIOR_BITS_Q
		jnz @@rdy
		add cl, 2		; resulting ch == number of preceding zero bits
		shl dx, 2
		jmp @@find

@@rdy:		shr dx, cl
		mov ah, 10h
		sub ah, cl
		mov cl, ah		; cl (and cx) == nbits
		shr cl			; nbits --> ndigits
		add di, cx		; cl == cx
		dec di

		std
		mov es, ds
@@next:		mov al, dl
		and al, JUNIOR_BITS_Q
		add al, '0'
		stosb
		ror dx, 2
		loop @@next
		
		mov cl, ah
		rol dx, cl		; restoring the original value
		shr cl			; nbits --> ndigits
		inc di
		ret

@@zero:		mov cl, 1
		mov byte ptr ds:[di], '0'
		ret

		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_4
; Creates a string with a signed quaternery number mentioned
; Enter: DX = SIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_4		proc

		ret
		endp
		
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_8
; Creates a string with an unsigned octal number mentioned
; Enter: DX = UNSIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_O	= 0e0h
JUNIOR_BITS_O	= 07h

itoa_8		proc

		xor cx, cx
@@find:		cmp cl, 12h
		je @@zero
		test dh, SENIOR_BITS_O
		jnz @@rdy
		add cl, 3		; resulting ch == number of preceding zero bits
		shl dx, 3
		jmp @@find

@@rdy:		shr dx, cl
		mov al, 10h
		sub al, cl
		xor ah, ah
		mov cl, al		; cl contains nbits
		mov ch, 3
		div ch			; nbits --> ndigits
		mov ah, cl		; ah contains nbits
		mov cl, al		; cl contains ndigits
		xor ch, ch		; cl == cx
		add di, cx
		dec di

		std
		mov es, ds
@@next:		mov al, dl
		and al, JUNIOR_BITS_O
		add al, '0'
		stosb
		ror dx, 3
		loop @@next
		
		mov cl, ah
		rol dx, cl		; restoring the original value
		mov ax, cx
		mov cl, 3
		div cl			; nbits --> ndigits
		mov cl, al
		inc di
		ret

@@zero:		mov cl, 1
		mov byte ptr ds:[di], '0'
		ret

		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_8
; Creates a string with a signed octal number mentioned
; Enter: DX = SIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_8		proc

		ret
		endp
		
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_16
; Creates a string with an unsigned hex number mentioned
; Enter: DX = UNSIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked 
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_H	= 0f0h
JUNIOR_BITS_H	= 0fh
LETTER_SHFT	= 'a' - '9'

itoa_16		proc

		xor cx, cx
@@find:		cmp cl, 10h
		je @@zero
		test dh, SENIOR_BITS_H
		jnz @@rdy
		add cl, 4		; resulting ch == number of preceding zero bits
		shl dx, 4
		jmp @@find

@@rdy:		shr dx, cl
		mov ah, 10h
		sub ah, cl
		mov cl, ah		; cl (and cx) == nbits
		shr cl, 2		; nbits --> ndigits (div by 4)
		add di, cx		; cl == cx
		dec di

		std
		mov es, ds
@@next:		mov al, dl
		and al, JUNIOR_BITS_H
		cmp al, 0ah		; decide letter/digit
		jb @@nolett
		add al, LETTER_SHFT
@@nolett:	add al, '0'
		stosb
		ror dx, 4
		loop @@next
		
		mov cl, ah
		rol dx, cl		; restoring the original value
		shr cl, 2		; nbits --> ndigits (div by 4)
		inc di
		ret

@@zero:		mov cl, 1
		mov byte ptr ds:[di], '0'
		ret

		ret
		endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_16
; Creates a string with a signed hex number mentioned
; Enter: DX = SIGNED number's value
;	 DI = where-to-insert string addr
; Exit:  CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;	 limits are not checked 
;	 No preceding zeros inserted (excluding the printing-zero case)
;	 Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_16	proc

		ret
		endp
		
;--------------------------------------------------------------

;--------------------------------------------------------------
; ATOI_10
; Extracts a decimal number from a string
; Enter: SI = string addr
; Exit:  BX = signed value extracted
; Note:  The value extracted can be a number from -2147483648 to 2147483647 inclusively
; Destr: AX BX CX DX
;--------------------------------------------------------------

atoi_10		proc

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
		je @@exit
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
