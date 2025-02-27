section .text
    global _start

_start:
    mov ecx, len
    dec ecx         ; len-1

outer_loop:
    xor esi, esi    ; array index (using xor to zero register)
    mov edx, ecx    ; len-1

inner_loop:
    mov eax, dword [array + esi*4]     ; Load current element (4-byte)
    mov ebx, dword [array + esi*4 + 4] ; Load next element (4-byte)
    cmp eax, ebx
    jle no_swap     ; if eax <= ebx then jump to no_swap

    ; swap
    mov dword [array + esi*4], ebx
    mov dword [array + esi*4 + 4], eax

no_swap:
    inc esi
    dec edx
    jnz inner_loop

    dec ecx
    jnz outer_loop

; Convert array to printable characters
    mov esi, 0          ; Reset array index
    mov edi, 0          ; Output buffer index

convert_loop:
    cmp esi, len
    jge display_array   ; If done with all numbers, go to display

    ; Convert number to ASCII
    mov eax, [array + esi*4]  ; Get the current number
    add eax, '0'              ; Convert to ASCII (only works for single digits 0-9)
    mov [output_buf + edi], al ; Store in output buffer
    
    ; Add a space after each number
    mov byte [output_buf + edi + 1], ' '
    
    add edi, 2          ; Move output buffer pointer (1 for digit, 1 for space)
    inc esi             ; Move to next array element
    jmp convert_loop

display_array:
    ; Write the buffer to stdout
    mov eax, 4          ; syscall number for write
    mov ebx, 1          ; file descriptor 1 is stdout
    mov ecx, output_buf ; buffer to write
    mov edx, len*2      ; buffer length (2 chars per number: digit + space)
    int 0x80

    ; Exit syscall for Linux
    mov eax, 1          ; syscall number for exit in 32-bit
    xor ebx, ebx        ; exit code 0
    int 0x80            ; 32-bit syscall interrupt

section .data
    array dd 5, 3, 4, 2, 6, 1  ; Array of double words (4-byte integers)
    len equ 6                  ; Length of array

section .bss
    output_buf resb 20  ; Buffer for output (enough for 6 numbers and spaces)