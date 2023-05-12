.intel_syntax noprefix
.file "pt.s"
.text

# pointers in the .init_array section of shared object files are called by the dynamic linker at load
# before main and even _start of the actual excecutable
.section .init_array
.quad pre

# everything before the next comment is needed for correct linking
# and to run some arbitrary code before an excecutable
.text
.globl pre
    .type pre, @function
pre:
    pushq rbp
    movq rbp, rsp
    subq rsp, 16
    # fork and setup ptrace
    mov rax, 57
    syscall
    cmp rax, 0 # zero means we're a child
    jl err_nofork # negative means we were unable to fork
    je leave # leave to the actual executable we're fucking with
    jg ctrl # positive indicates we're the parent-/inital-process
    # and just in case (this should never run, unless jumed to by address)
    jmp err_nofork

# run some actual program this shared object unfortunately got dynamically loaded into
leave:
    # ptrace me first
    mov rax, 101
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    # then leave
    leave
    ret

# hijack and fuck with all write syscalls
ctrl:
    # store child pid
    mov [rip + pid], rax
    # malloc some mem to store captured register values from child
    mov rdi, 216 # size of user_regs_struct on x86_64 machines running Linux
    call malloc
    mov [rip + regsptr], rax
    call wait
    # ptrace set option exit kill
    mov rax, 101
    mov rdi, 0x4200
    mov rsi, [rip + pid]
    mov rdx, 0
    mov r10, 0x100000
    syscall
ctrl_loop:
    # ptrace enter syscall
    mov rax, 101
    mov rdi, 24
    mov rsi, [rip + pid]
    mov rdx, 0
    mov r10, 0
    syscall
    cmp rax, -1
    jne err_ctrl
    call wait
    cmp rax, -1
    jne err_ctrl
    # fetch register values from child about to perform a syscall
    mov rax, 101
    mov rdi, 12
    mov rsi, [rip + pid]
    mov rdx, 0
    lea r10, [rip + regsptr]
    syscall

    # don't fuck with non write syscalls
    cmp rax, 1
    jne skip
    # also skip if write destination ain't std-out/-err
    cmp rdi, 2
    jg skip
    # the syscall is a write to std-out/-err

    mov rax, 1
    mov rdi, 2
    lea rsi, [rip + msg]
    mov rdx, 10
    syscall
skip:
    # let the child complete the syscall we captured
    mov rax, 101
    mov rdi, 24
    mov rsi, [rip + pid]
    mov rdx, 0
    mov r10, 0
    syscall
    cmp rax, -1
    jne err_ctrl
    jmp ctrl_loop

# waitid syscall for parent to sync with / wait for child
wait:
    mov rax, 247
    mov rdi, [rip + pid]
    mov rsi, 0
    mov rdx, 0
    syscall
    ret

# ptrace syscall with common args for parent-/ctrl-process
ptrace:
    mov rax, 101
    mov rsi, [rip + pid]
    syscall
    ret

# exit syscall
exit:
    mov rax, 60
    syscall

err_ctrl:
    mov rax, 1
    mov rdi, 2
    lea rsi, [rip + msg]
    mov rdx, 10
    syscall
    mov rax, 60
    mov rdi, 42069
    syscall

# write no_fork to stderr and return
# hopefully to the start of some executable
err_nofork:
    mov rax, 1
    mov rdi, 2
    lea rsi, [rip + no_fork]
    mov rdx, 15
    syscall
    leave
    ret

.section .data
regsptr:
    .quad 0
pid: # store child process pid here
    .quad 0
# user_regs_struct with labels to the parts we care about
#regs:
#   .fill 27 8 0
#    .fill 10 8
#_rax:
#    .fill 1 8
#    .fill 1 8
#_rdx:
#    .fill 1 8
#_rsi:
#    .fill 1 8
#_rdi:
#    .fill 1 8
#    .fill 12 8

.section rodata
no_fork:
    .string "Unable to fork!\n"
msg:
    .string "Fuck you!\n"
