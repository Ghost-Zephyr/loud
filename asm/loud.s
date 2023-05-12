.intel_syntax noprefix
.file "lOuD.S"
.text

.section .init_array
.quad pre

.text
.globl pre
    .type pre, @function
pre:
    # .init_array shit to prevent segv
    pushq rbp
    movq rbp, rsp
    subq rsp, 16
    # do fun stuff

    leave
    ret
