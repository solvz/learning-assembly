section .data:
    prompt db "Enter 2 integers ("a b"): ", 0
    prompt_len equ $ - prompt

    buffer db 20 dup(0)
    buffer_size equ $ - buffer

    n1 dd 0
    n2 dd 0

global _start:

section .text:
_start:
    ;Write Prompt syscall
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ;Read Input syscall
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, buffer_size
    int 0x80

    ;Parse input and convert it to integer
    mov esi, buffer
    call toint
    mov [n1], eax

    inc esi

    call toint
    mov [n2], eax



exit:
    mov eax,1
    xor ebx,ebx
    int 0x80

toint:
    xor eax, eax
    xor ecx, ecx

    .convert
        mov cl, [esi]
        cmp cl, '0'
        jb .done
        cmp cl, '9'
        ja .done

        sub cl, '0'
        imul eax, 10
        add eax, ecx

        inc esi
        jmp .convert

    .done
        ret

