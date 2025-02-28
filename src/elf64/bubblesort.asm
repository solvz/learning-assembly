global _start

section .text
    _start:
        mov rcx, len
        dec rcx         ; len-1

    outer_loop:
        xor rsi, rsi    ; array index (using xor to zero register)
        mov rdx, rcx    ; len-1

    inner_loop:
        mov eax, dword [array + rsi*4]     ; Load current element (4-byte)
        mov ebx, dword [array + rsi*4 + 4] ; Load next element (4-byte)
        cmp eax, ebx
        jle no_swap     ; if eax <= ebx then jump to no_swap
        ; swap
        mov dword [array + rsi*4], ebx
        mov dword [array + rsi*4 + 4], eax

    no_swap:
        inc rsi
        dec rdx
        jnz inner_loop
        dec rcx
        jnz outer_loop
    ; Convert array to printable characters
        mov rsi, 0          ; Reset array index
        mov rdi, 0          ; Output buffer index

    convert_loop:
        cmp rsi, len
        jge display_array   ; If done with all numbers, go to display
        ; Convert number to ASCII
        mov eax, [array + rsi*4]  ; Get the current number
        add eax, '0'              ; Convert to ASCII (only works for single digits 0-9)
        mov [output_buf + rdi], al ; Store in output buffer
        
        ; Add a space after each number
        mov byte [output_buf + rdi + 1], ' '
        
        add rdi, 2          ; Move output buffer pointer (1 for digit, 1 for space)
        inc rsi             ; Move to next array element
        jmp convert_loop
        
    display_array:
        ; Write the buffer to stdout using 64-bit syscalls
        mov rax, 1          ; syscall number for write in 64-bit
        mov rdi, 1          ; file descriptor 1 is stdout
        mov rsi, output_buf ; buffer to write
        mov rdx, len*2      ; buffer length (2 chars per number: digit + space)
        syscall
        ; Exit syscall for Linux 64-bit
        mov rax, 60         ; syscall number for exit in 64-bit
        xor rdi, rdi        ; exit code 0
        syscall

section .data
    array dd 5, 3, 4, 2, 6, 1  ; Array of double words (4-byte integers)
    len equ 6  
                    ; Length of array
section .bss
    output_buf resb 20  ; Buffer for output (enough for 6 numbers and spaces)