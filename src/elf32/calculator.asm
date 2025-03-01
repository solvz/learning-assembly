section .data
    prompt db "Enter 2 integers (a b): ", 0
    prompt_len equ $ - prompt

    calcchoice db "Enter 1,2,3,4 for +,-,/,*: "
    choice_len equ $ -  calcchoice

    buffer db 20 dup(0)
    buffer_size equ $ - buffer

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
    mov ecx, calcchoice       ; pointer to the prompt message
    mov edx, choice_len   ; length of the prompt
    int 0x80              ; invoke syscall

    call reset_buffer

    ; Read Input syscall
    mov eax, 3            ; syscall: read
    mov ebx, 0            ; file descriptor: stdin
    mov ecx, buffer       ; buffer to store input
    mov edx, buffer_size  ; maximum number of bytes to read
    int 0x80 

    ; Parse input and convert it to integer
    mov esi, buffer       ; ESI points to the start of the buffer
    call toint            ; Convert to integer
    mov [uch], eax         ; Store first integer in uch

    call calculator

exit:
    ; Exit syscall
    mov eax, 1            ; syscall: exit
    xor ebx, ebx          ; exit code 0
    int 0x80              ; invoke syscall

; Function: toint (ASCII to integer)
toint:
    xor eax, eax          ; Clear EAX (store result here)
    xor ecx, ecx          ; Clear ECX (will hold current character)

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
    ret                   ; Return with the integer in EAX

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
    