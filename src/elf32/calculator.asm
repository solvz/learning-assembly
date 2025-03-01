section .data
    prompt db "Enter 2 integers (a b): ", 0
    prompt_len equ $ - prompt

    calcchoice db "Enter 1,2,3,4 for +,-,/,*: ", 0
    choice_len equ $ - calcchoice

    buffer db 20 dup(0)
    buffer_size equ $ - buffer

    newline db 10          ; Newline character

    n1 dd 0
    n2 dd 0
    uch dd 0

global _start

section .text
_start:
    ; Write Prompt syscall
    mov eax, 4            ; syscall: write
    mov ebx, 1            ; file descriptor: stdout
    mov ecx, prompt       ; pointer to the prompt message
    mov edx, prompt_len   ; length of the prompt
    int 0x80              ; invoke syscall

    ; Read Input syscall
    mov eax, 3            ; syscall: read
    mov ebx, 0            ; file descriptor: stdin
    mov ecx, buffer       ; buffer to store input
    mov edx, buffer_size  ; maximum number of bytes to read
    int 0x80              ; invoke syscall

    ; Parse input and convert it to integer
    mov esi, buffer       ; ESI points to the start of the buffer
    call toint            ; Convert first number to integer
    mov [n1], eax         ; Store first integer in n1

    ; Skip spaces
    inc esi               ; Move past the first space
    call skip_spaces      ; Skip any additional spaces

    call toint            ; Convert second number to integer
    mov [n2], eax         ; Store second integer in n2

    ; Write Prompt syscall
    mov eax, 4            ; syscall: write
    mov ebx, 1            ; file descriptor: stdout
    mov ecx, calcchoice   ; pointer to the prompt message
    mov edx, choice_len   ; length of the prompt
    int 0x80              ; invoke syscall

    call reset_buffer

    ; Read Input syscall
    mov eax, 3            ; syscall: read
    mov ebx, 0            ; file descriptor: stdin
    mov ecx, buffer       ; buffer to store input
    mov edx, buffer_size  ; maximum number of bytes to read
    int 0x80              ; invoke syscall

    ; Parse input and convert it to integer
    mov esi, buffer       ; ESI points to the start of the buffer
    call toint            ; Convert to integer
    mov [uch], eax        ; Store first integer in uch

    call reset_buffer
    call calculator

exit:
    ; Exit syscall
    mov eax, 1            ; syscall: exit
    xor ebx, ebx          ; exit code 0
    int 0x80              ; invoke syscall

; Function: Skipped Spaces
skip_spaces:
    mov cl, [esi]         ; Load the next character
    cmp cl, ' '           ; Check if character is a space
    jne .done             ; If not a space, exit
    inc esi               ; Move to the next character
    jmp skip_spaces       ; Repeat

.done:
    ret                   ; Return

; Reset Buffer Function
reset_buffer:
    mov ecx, buffer_size  ; Number of bytes to clear
    mov edi, buffer       ; Pointer to the buffer
    xor al, al            ; AL = 0 (byte to write)
    rep stosb             ; Repeat storing AL (0) to [EDI] for ECX bytes
    ret

; Calculator function
calculator:
    cmp dword [uch], 1
    je .add
    cmp dword [uch], 2
    je .sub
    cmp dword [uch], 3
    je .mul
    cmp dword [uch], 4
    je .div
    ret

.add:
    mov eax, [n1]          ; Load n1 into eax
    add eax, [n2]          ; Add n2 to eax
    jmp .printresult       ; Print the result

.sub:
    mov eax, [n1]          ; Load n1 into eax
    sub eax, [n2]          ; Subtract n2 from eax
    jmp .printresult       ; Print the result

.mul:
    mov eax, [n1]          ; Load n1 into eax
    imul eax, [n2]         ; Multiply n1 by n2
    jmp .printresult       ; Print the result

.div:
    mov eax, [n1]          ; Load n1 into eax
    xor edx, edx           ; Clear edx for division
    cmp dword [n2], 0      ; Check for division by zero
    je .div_error          ; If divisor is zero, handle error
    idiv dword [n2]        ; Divide n1 by n2
    jmp .printresult       ; Print the result

.div_error:
    ; Handle division by zero error
    mov eax, 4             ; syscall: write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, div_error_msg ; pointer to the error message
    mov edx, div_error_len ; length of the error message
    int 0x80               ; invoke syscall
    ret

.printresult:
    mov edi, buffer        ; Point edi to the buffer
    call toascii           ; Convert result to ASCII

    ; Write the result to stdout
    mov eax, 4             ; syscall: write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, buffer        ; pointer to the result string
    mov edx, buffer_size   ; length of the result string
    int 0x80               ; invoke syscall

    ; Write a newline
    mov eax, 4             ; syscall: write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, newline       ; pointer to the newline character
    mov edx, 1             ; length of the newline character
    int 0x80               ; invoke syscall

    ret

; Function: toint (ASCII to integer)
toint:
    xor eax, eax          ; Clear EAX (store result here)
    xor ecx, ecx          ; Clear ECX (will hold current character)
    xor edx, edx          ; Clear EDX (will hold sign flag)

    ; Check for negative sign
    mov cl, [esi]         ; Load the first character
    cmp cl, '-'           ; Check if it's a negative sign
    jne .convert          ; If not, start conversion
    inc esi               ; Skip the negative sign
    mov edx, 1            ; Set sign flag (1 = negative)

.convert:
    mov cl, [esi]         ; Load the next character
    cmp cl, '0'           ; Check if character is a digit
    jb .done              ; If below '0', exit
    cmp cl, '9'           ; Check if character is a digit
    ja .done              ; If above '9', exit

    sub cl, '0'           ; Convert ASCII to integer
    imul eax, 10          ; Multiply current result by 10
    add eax, ecx          ; Add the new digit

    inc esi               ; Move to the next character
    jmp .convert          ; Repeat

.done:
    ; Apply the sign if necessary
    test edx, edx         ; Check if the number is negative
    jz .positive          ; If not, skip negation
    neg eax               ; Negate the result

.positive:
    ret                   ; Return with the integer in EAX

; Function: toascii (Integer to ASCII)
toascii:
    mov ecx, 10            ; Divisor (10 for decimal)
    mov esi, edi           ; Save the start of the buffer
    add esi, 19            ; Point to the end of the buffer
    mov byte [esi], 0      ; Null-terminate the string

    ; Check if the number is negative
    test eax, eax          ; Check if the number is negative
    jns .convert_loop      ; If not, skip adding the negative sign
    neg eax                ; Convert to positive for conversion
    dec esi                ; Move to the previous byte
    mov byte [esi], '-'    ; Add the negative sign

.convert_loop:
    dec esi                ; Move to the previous byte
    xor edx, edx           ; Clear EDX for division
    div ecx                ; Divide EAX by 10 (EAX = quotient, EDX = remainder)
    add dl, '0'            ; Convert remainder to ASCII
    mov [esi], dl          ; Store the ASCII character
    test eax, eax          ; Check if quotient is zero
    jnz .convert_loop      ; If not, repeat

    ; Calculate the length of the string
    mov ecx, edi           ; Start of the buffer
    add ecx, 19            ; End of the buffer
    sub ecx, esi           ; Length of the string
    mov edx, ecx           ; Store the length in EDX

    ; Move the string to the start of the buffer
    mov edi, esi           ; Point EDI to the start of the string
    rep movsb              ; Copy the string to the start of the buffer

    ret

section .data
    div_error_msg db "Error: Division by zero", 0
    div_error_len equ $ - div_error_msg