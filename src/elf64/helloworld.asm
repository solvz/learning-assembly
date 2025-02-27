global _start

section .text   ; Text section
    _start:
        ; Write(1) Syscall: params(descriptor, string, string length)
        mov rax, 1
        mov rdi, 1
        mov rsi, message
        mov rdx, len
        syscall

        ; Exit(60) Syscall
        mov rax, 60
        xor rdi, rdi
        syscall

section .data   ; Data Section
    message: db "Hello World!", 0xA
    len equ $ - message
