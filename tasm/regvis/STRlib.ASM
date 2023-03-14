;==============================================================
;                      Function section
;==============================================================

NEGAT_BIT       = 8000h

;--------------------------------------------------------------
; STRLEN
; Counts number of symbols in a string
; Enter: SI = string addr
;        ES = segment for string's addressing
; Exit:  CX = number of symbs
; Note:  Direction flag is set to UP
; Destr: CX
;--------------------------------------------------------------

strlen          proc

                cld
                mov cx, si

@@next:         cmp byte ptr es:[si], '$'
                je @@exit
                inc si
                jmp @@next

@@exit:         xchg si, cx
                sub cx, si
                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCHR
; Searches for a character in a string
; Enter: SI = string addr
;        DL = ASCII code of character searched
;        ES = segment for string's addressing
; Exit:  BX = first appearance addr (-1 if no searched char found)
; Note:  Direction flag is set to UP
; Destr: SI BX AL
;--------------------------------------------------------------

strchr          proc

                cld

@@next:         lodsb
                cmp al, '$'
                je @@stop
                cmp al, dl
                jne @@next

                mov bx, si
                dec bx
                ret

@@stop:         mov bx, -1
                ret
                
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCPY
; Copies all the string characters to another string
; Enter: SI = source string addr
;        DI = dest string addr
;        ES = segment for strings' addressing
; Exit:  None
; Note:  Be aware of dest buffer overflow, string sizes are not compared
;        Direction flag is set to UP
; Destr: SI DI AL
;--------------------------------------------------------------

strcpy          proc

                cld

@@next:         lodsb
                stosb
                cmp al, '$'
                jne @@next

                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCMP
; Compares 2 strings in lexicographic order
; Enter: SI = first string compared addr
;        DI = second string compared addr
;        ES = segment for strings' addressing
; Exit:  AL > 0 if first str is greater
;        AL < 0 if second str is greater
;        AL = 0 if strings are similar
; Note:  Direction flag is set to UP
; Destr: Destr: SI DI AX
;--------------------------------------------------------------

strcmp          proc

                cld

@@next:         lodsb
                mov ah, byte ptr es:[di]
                inc di
                sub al, ah
                test al, 0ffh
                jz @@stop
                ret
@@stop:         cmp ah, '$'
                jne @@next
                ret

                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_10
; Creates a string with an unsigned decimal number mentioned
; Enter: DX = UNSIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX BX CX
;--------------------------------------------------------------

itoa_10         proc

                cld
                mov initval, dx
                xor cx, cx
                mov ax, dx
                mov bx, 10
@@count:        test ax, 0ffffh
                jz @@stop
                inc cl
                xor dx, dx              ; clearing senior word in double register
                div bx
                jmp @@count
                
@@stop:         jcxz @@zero             ; cl == ndigits; or 0, if zero
                add di, cx
                mov byte ptr es:[di], '$'
                dec di
                std
                mov ax, initval
                mov ch, cl              ; ndigits is long-stored in cl, ch - counter
                inc cl                  ; "$" symb
@@next:         xor dx, dx              ; clearing senior word in double register
                div bx                  ; value is too small, mod is stored in dl, dh == 0
                xchg dx, ax
                add al, '0'
                stosb
                mov ax, dx
                dec ch
                test ch, 0ffh
                jnz @@next

                inc di
                mov dx, initval
                ret
                
@@zero:         mov cl, 2
                mov word ptr es:[di], '$0'
                ret                     ; dx has not changed

                endp

initval         dw ?

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_10
; Creates a string with a signed decimal number mentioned
; Enter: DX = SIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX BX CX
;--------------------------------------------------------------

sitoa_10        proc

                test dx, NEGAT_BIT
                jz @@posit

                cld
                mov al, '-'
                stosb
                neg dx
                call itoa_10
                neg dx
                inc cl
                dec di
                ret

@@posit:        call itoa_10
                ret

                endp
                
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_2
; Creates a string with an unsigned binary number mentioned
; Enter: DX = UNSIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_B   = 80h
JUNIOR_BITS_B   = 01h

itoa_2          proc

                xor cx, cx
@@find:         cmp cl, 10h
                je @@zero
                test dh, SENIOR_BITS_B
                jnz @@rdy
                inc cl                  ; resulting cl == number of preceding zeros
                shl dx, 1
                jmp @@find

@@rdy:          shr dx, cl
                mov ah, 10h
                sub ah, cl
                mov cl, ah              ; cx == number of digits
                add di, cx              ; cl == cx
                mov byte ptr es:[di], '$'
                dec di
                std
@@next:         mov al, dl
                and al, JUNIOR_BITS_B
                add al, '0'
                stosb
                ror dx, 1
                loop @@next
                
                mov cl, ah              ; cl == nbits == ndigits
                rol dx, cl              ; restoring the original value
                inc cl                  ; "$" symb
                inc di
                ret

@@zero:         mov cl, 2
                mov word ptr es:[di], '$0'
                ret

                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_2
; Creates a string with a signed binary number mentioned
; Enter: DX = SIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_2         proc

                test dx, NEGAT_BIT
                jz @@posit

                cld
                mov al, '-'
                stosb		
                neg dx
                call itoa_2
                neg dx
                inc cl
                dec di
                ret

@@posit:        call itoa_2
                ret

                endp
                
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_4
; Creates a string with an unsigned quaternery number mentioned
; Enter: DX = UNSIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_Q   = 0c0h
JUNIOR_BITS_Q   = 03h

itoa_4          proc

                xor cx, cx
@@find:         cmp cl, 10h
                je @@zero
                test dh, SENIOR_BITS_Q
                jnz @@rdy
                add cl, 2               ; resulting cl == number of preceding zero bits
                shl dx, 2
                jmp @@find

@@rdy:          shr dx, cl
                mov ah, 10h
                sub ah, cl
                mov cl, ah              ; cl (and cx) == nbits
                shr cl, 1               ; nbits --> ndigits
                add di, cx              ; cl == cx
                mov byte ptr es:[di], '$'
                dec di
                std
@@next:         mov al, dl
                and al, JUNIOR_BITS_Q
                add al, '0'
                stosb
                ror dx, 2
                loop @@next
                
                mov cl, ah
                rol dx, cl              ; restoring the original value
                shr cl, 1               ; nbits --> ndigits
                inc cl                  ; "$" symb
                inc di
                ret

@@zero:         mov cl, 2
                mov word ptr es:[di], '$0'
                ret

                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_4
; Creates a string with a signed quaternery number mentioned
; Enter: DX = SIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_4	        proc

                test dx, NEGAT_BIT
                jz @@posit

                cld
                mov al, '-'
                stosb
                neg dx
                call itoa_4
                neg dx
                inc cl
                dec di
                ret

@@posit:        call itoa_4
                ret

                endp
                
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_8
; Creates a string with an unsigned octal number mentioned
; Enter: DX = UNSIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_O   = 0e0h
JUNIOR_BITS_O   = 07h

itoa_8          proc

                xor cx, cx
@@find:         cmp cl, 12h
                je @@zero
                test dh, SENIOR_BITS_O
                jnz @@rdy
                add cl, 3               ; resulting cl == number of preceding zero bits
                shl dx, 3
                jmp @@find

@@rdy:          shr dx, cl
                mov al, 10h
                sub al, cl
                xor ah, ah
                mov cl, al              ; cl contains nbits
                mov ch, 3
                div ch                  ; nbits --> ndigits - 1 (bec mod 3)
                inc al                  ; ndigits - 1 --> ndigits
                mov ah, cl              ; ah contains nbits
                mov cl, al              ; cl contains ndigits
                xor ch, ch              ; cl == cx
                add di, cx
                mov byte ptr es:[di], '$'
                dec di

                std
@@next:         mov al, dl
                and al, JUNIOR_BITS_O
                add al, '0'
                stosb
                ror dx, 3
                loop @@next
                
                mov cl, ah
                rol dx, cl              ; restoring the original value
                mov ax, cx
                mov cl, 3
                div cl                  ; nbits --> ndigits
                mov cl, al
                inc cl                  ; "$" symb
                inc di
                ret

@@zero:         mov cl, 2
                mov word ptr es:[di], '$0'
                ret

                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_8
; Creates a string with a signed octal number mentioned
; Enter: DX = SIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_8         proc

                test dx, NEGAT_BIT
                jz @@posit

                cld
                mov al, '-'
                stosb
                neg dx
                call itoa_8
                neg dx
                inc cl
                dec di
                ret

@@posit:        call itoa_8
                ret

                endp
                
;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA_16
; Creates a string with an unsigned hex number mentioned
; Enter: DX = UNSIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked 
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

SENIOR_BITS_H   = 0f0h
JUNIOR_BITS_H   = 0fh
LETTER_SHFT     = 'a' - ('9' + 1)

itoa_16         proc

                xor cx, cx
@@find:         cmp cl, 10h
                je @@zero
                test dh, SENIOR_BITS_H
                jnz @@rdy
                add cl, 4               ; resulting cl == number of preceding zero bits
                shl dx, 4
                jmp @@find

@@rdy:          shr dx, cl
                mov ah, 10h
                sub ah, cl
                mov cl, ah              ; cl (and cx) == nbits
                shr cl, 2               ; nbits --> ndigits (div by 4)
                add di, cx              ; cl == cx
                mov byte ptr es:[di], '$'
                dec di

                std
@@next:         mov al, dl
                and al, JUNIOR_BITS_H
                cmp al, 0ah             ; decide letter/digit
                jb @@nolett
                add al, LETTER_SHFT
@@nolett:       add al, '0'
                stosb
                ror dx, 4
                loop @@next
                
                mov cl, ah
                rol dx, cl              ; restoring the original value
                shr cl, 2               ; nbits --> ndigits (div by 4)
                inc cl                  ; "$" symb
                inc di
                ret

@@zero:         mov cl, 2
                mov word ptr es:[di], '$0'
                ret

                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA_16
; Creates a string with a signed hex number mentioned
; Enter: DX = SIGNED number's value
;        DI = where-to-insert string addr
;        ES = segment for string's addressing
; Exit:  CX = CL = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked 
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
; Destr: AX CX
;--------------------------------------------------------------

sitoa_16        proc

                test dx, NEGAT_BIT
                jz @@posit

                cld
                mov al, '-'
                stosb		
                neg dx
                call itoa_16
                neg dx
                inc cl
                dec di
                ret

@@posit:        call itoa_16
                ret

                endp
                
;--------------------------------------------------------------

;--------------------------------------------------------------
; ATOI_10
; Extracts a decimal number from a string
; Enter: SI = string addr
;        ES = segment for string's addressing
; Exit:  DX = signed value extracted
; Note:  The value extracted can be a number from -32768 to 32767 inclusively
;        Direction flag is set to UP
; Destr: AX BX CX DX
;--------------------------------------------------------------

atoi_10         proc

                cld
                xor ch, ch              ; ch will be 0 if val is pos and nonnull if val is neg
                mov bx, si
                cmp byte ptr es:[si], '-'
                jne @@begin
                inc si
                inc bx
                not ch

@@begin:        lodsb
                cmp al, '9'
                ja @@stop
                cmp al, '0'
                jb @@stop
                jmp @@begin

@@stop:         dec si
                mov dx, si
                sub dx, bx              ; dh == 0, number is too low to fill it
                mov cl, dl              ; cl == ndigits
                dec si

                mov bx, 1
@@next:         test cl, 0ffh
                jz @@exit
                mov al, byte ptr es:[si]
                dec si
                sub al, '0'
                dec cl
                xor ah, ah
                mul bx
                add resval, ax
                mov ax, 10
                mul bx
                mov bx, ax
                jmp @@next
                
@@exit:         mov dx, resval
                jcxz @@nonneg           ; cl == 0 (end of loop) checking ch
                neg dx
                ret

@@nonneg:       inc si
                ret

                endp

resval          dw 0

;--------------------------------------------------------------

;==============================================================
;                   End of function section
;==============================================================

;==============================================================
;                 Stack frame wrapper section
;==============================================================
; cdecl is used!

;--------------------------------------------------------------
; STRLEN
; Counts number of symbols in a string
; Enter: [SP]   = string addr
;        [SP+2] = segment for string's addressing
; Exit:  CX = number of symbs
; Note:  Direction flag is set to UP
; Destr: CX
;--------------------------------------------------------------

strlen_s        proc
                push bp
                mov bp, sp

                mov si, word ptr ss:[bp+4]
                mov es, word ptr ss:[bp+6]
                call strlen

                pop bp
                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCHR
; Searches for a character in a string
; Enter: [SP]   = string addr
;        [SP+2] = ASCII code of character searched
;        [SP+4] = segment for string's addressing
; Exit:  BX = first appearance addr (-1 if no searched char found)
; Note:  Direction flag is set to UP
; Destr: SI BX AL
;--------------------------------------------------------------

strchr_s        proc
                push bp
                mov bp, sp
                
                mov si, word ptr ss:[bp+4]
                mov dl, byte ptr ss:[bp+6]
                mov es, word ptr ss:[bp+8]
                call strchr
                
                pop bp
                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCPY
; Copies all the string characters to another string
; Enter: [SP]   = dest string addr
;        [SP+2] = source string addr
;        [SP+4] = segment for strings' addressing
; Exit:  None
; Note:  Be aware of dest buffer overflow, string sizes are not compared
;        Direction flag is set to UP
; Destr: SI DI AL
;--------------------------------------------------------------

strcpy_s        proc
                push bp
                mov bp, sp
                
                mov di, word ptr ss:[bp+4]
                mov si, word ptr ss:[bp+6]
                mov es, word ptr ss:[bp+8]
                call strcpy

                pop bp
                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; STRCMP
; Compares 2 strings in lexicographic order
; Enter: [SP]   = first string compared addr
;        [SP+2] = second string compared addr
;        [SP+4] = segment for strings' addressing
; Exit:  AL > 0 if first str is greater
;        AL < 0 if second str is greater
;        AL = 0 if strings are similar
; Note:  Direction flag is set to UP
; Destr: SI DI AX
;--------------------------------------------------------------

strcmp_s        proc
                push bp
                mov bp, sp
                
                mov si, word ptr ss:[bp+4]
                mov di, word ptr ss:[bp+6]
                mov es, word ptr ss:[bp+8]
                call strcmp

                pop bp
                ret
                endp

;--------------------------------------------------------------

;--------------------------------------------------------------
; ITOA
; Creates a string with an unsigned number mentioned
; Enter: [SP]   = UNSIGNED number's value
;        [SP+2] = where-to-insert string addr
;        [SP+4] = radix, can be 2, 4, 8, 16 or 10
;        [SP+6] = segment for string's addressing
; Exit:  CX = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
;        If radix does not match any of the values listed above UB is performed
; Destr: AX BX CX
;--------------------------------------------------------------

itoa_s          proc
                push bp
                mov bp, sp
                
                mov dx, word ptr ss:[bp+4]
                mov di, word ptr ss:[bp+6]
                mov bx, word ptr ss:[bp+8]
                mov es, word ptr ss:[bp+10]
                call itoa_jt[bx]

                pop bp
                ret
                endp

itoa_jt         dw 0, itoa_2, itoa_4, 0, itoa_8
                dw itoa_10, 0, 0, itoa_16

;--------------------------------------------------------------

;--------------------------------------------------------------
; SITOA
; Creates a string with a signed number mentioned
; Enter: [SP]   = SIGNED number's value
;        [SP+2] = where-to-insert string addr
;        [SP+4] = radix, can be 2, 4, 8, 16 or 10
;        [SP+6] = segment for string's addressing
; Exit:  CX = size of string inserted
; Note:  The string should have enough free/unused space to store the digits;
;        limits are not checked
;        No preceding zeros inserted (excluding the printing-zero case)
;        Direction flag is set to DN
;        If radix does not match any of the values listed above UB is performed
; Destr: AX BX CX
;--------------------------------------------------------------

sitoa_s         proc
                push bp
                mov bp, sp
                
                mov dx, word ptr ss:[bp+4]
                mov di, word ptr ss:[bp+6]
                mov bx, word ptr ss:[bp+8]
                mov es, word ptr ss:[bp+10]
                call sitoa_jt[bx]

                pop bp
                ret
                endp
                
sitoa_jt        dw 0, sitoa_2, sitoa_4, 0, sitoa_8
                dw sitoa_10, 0, 0, sitoa_16

;--------------------------------------------------------------

;--------------------------------------------------------------
; ATOI_10
; Extracts a decimal number from a string
; Enter: [SP]   = string addr
;        [SP+2] = segment for string's addressing
; Exit:  DX = signed value extracted
; Note:  The value extracted can be a number from -32768 to 32767 inclusively
;        Direction flag is set to UP
; Destr: AX BX CX DX
;--------------------------------------------------------------

atoi_10_s       proc
                push bp
                mov bp, sp
                
                mov si, word ptr ss:[bp+4]
                mov es, word ptr ss:[bp+6]
                call atoi_10

                pop bp
                ret
                endp

;--------------------------------------------------------------

;==============================================================
;                    End of wrapper section
;==============================================================
