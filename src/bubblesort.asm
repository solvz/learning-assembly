global _main

section .text

_main:
    mov ecx, len
    dec ecx ; len-1


outer_loop:
    mov esi, 0  ; array pointer
    mov edx ecx ; len-1

inner_loop:
    mov eax, [array + esi*4]
    mov ebx, [array + esi * 4+ 4]
    cmp eax, ebx
    jle no_swap ; if eax<ebx then jump to no_swap

    ;swap
    mov [array + esi*4], ebx
    mov [array + esi*4+4], eax

no_swap:
    inc esi
    dec edx
    jnz inner_loop

    dec ecx
    jnz outer_loop

    mov eax, 60
    xor edi, edi
    syscall


section .data
    array: db 5,3,4,2,6,1
    len equ 6