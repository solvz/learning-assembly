global _start

section .text   ; declaring .text section

_start:
    mov eax, 0x4 ; write syscall
    mov ebx, 1   ; use stdout as the file descriptor
    mov ecx, message ; mess is buffer
    mov edx, message_length ; supplying length
    int 0x80     ; invoke syscall

    mov eax, 0x1 ; exit syscall
    mov ebx, 0   ; return
    int 0x80

section .data   ; declaring data section
    message: db "Hello World!", 0xA
    message_length equ $-message