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
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ;Read Input syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, buffer_size
    syscall

    ;Parse input and convert it to integer
    mov rsi, buffer
    call toint
    mov [n1], eax

    inc rsi

    call toint
    mov [n2], eax

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

toint:
    xor eax, eax
    xor ecx, ecx

    .convert
        mov cl, [rsi]
        cmp cl, '0'
        jb .done
        cmp cl, '9'
        ja .done

        sub cl, '0'
        imul eax, 10
        add eax, ecx

        inc rsi
        jmp .convert

    .done
        ret


