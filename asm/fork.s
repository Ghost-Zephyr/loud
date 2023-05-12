.intel_syntax noprefix
.file "fork.s"
.text

.data
.section .rodata
child_msg:
    .string "Made a child!\n"
child_wait:
    .string "Child attach!\n"
fuck:
    .string "Fuck you!\n"
.text
.globl main
    .type main, @function
main:
    # fork
    mov rax, 57
    syscall
    cmp rax, 0
    jl no_fork
    jg ctrl

child:
    # trace me
    mov rax, 101
    mov rdi, 0
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    # print
    mov rax, 1
    mov rdi, 1
    lea rsi, [rip + child_wait]
    mov rdx, 14
    syscall
    # wait!
    mov rax, 110
    syscall
    mov rdi, rax
    mov rax, 61
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    cmp rax, 0
    jge print
.rept 42069
    nop
.endr
print:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rip + child_msg]
    mov rdx, 14
    syscall
    ret

.data
pid:
    .quad 0
regsptr:
    .quad 0
.section .rodata
ctrl_msg:
    .string "Parent is watching!\n"
.text
ctrl:
    # store ptrs
    mov [rip + pid], rax
    mov rdi, 216
    call malloc
    mov [rip + regsptr], rax
    # wait and set ptrace option
    call wait
    mov rax, 101
    mov rdi, 0x4200
    mov rsi, [rip + pid]
    xor rdx, rdx
    mov r10, 0x100000
    syscall
    mov rax, 1
    mov rdi, 2
    lea rsi, [rip + ctrl_msg]
    mov rdx, 20
    syscall
loop:
    # ptrace enter syscall
    mov rax, 101
    mov rdi, 24
    mov rsi, [rip + pid]
    xor rdx, rdx
    xor r10, r10
    syscall
    cmp rax, 0
    jl ctrl_err
    call wait
    cmp rax, 0
    jl ctrl_err
    # fetch child regs
    mov rax, 101
    mov rdi, 12
    mov rsi, [rip + pid]
    xor rdx, rdx
    lea r10, [rip + regsptr]
    syscall
    cmp rax, 0
    jl ctrl_err
    # skip non write syscalls
    cmp rax, 1
    jne skip
    cmp rdi, 2
    jg skip

    mov rax, 1
    mov rdi, 2
    lea rsi, [rip + ctrl_err_msg]
    mov rdx, 9
    syscall

skip:
    mov rax, 101
    mov rdi, 24
    mov rsi, [rip + pid]
    xor rdx, rdx
    xor r10, r10
    syscall
    cmp rax, 0
    jl ctrl_err
    jmp loop

.data
.section .rodata
parent_wait:
    .string "Parent waiting!\n"
.text
wait:
    mov rax, 1
    mov rdi, 2
    mov rsi, [rip + parent_wait]
    mov rdx, 16
    syscall
    mov rax, 61
    mov rdi, [rip + pid]
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    cmp rax, 0
    jl ctrl_err
    ret

.data
.section .rodata
ctrl_err_msg:
    .string "Fuck you!\n"
.text
ctrl_err:
    mov rax, 1
    mov rdi, 2
    mov rsi, [rip + ctrl_err_msg]
    mov rdx, 10
    syscall
    mov rax, 60
    mov rdi, 69
    syscall

.data
.section .rodata
no_fork_msg:
    .string "Unable to fork!\n"
.text
no_fork:
    mov rax, 1
    mov rdi, 2
    mov rsi, [rip + no_fork_msg]
    mov rdx, 15
    syscall
    mov rax, 60
    mov rdi, 420
    syscall
