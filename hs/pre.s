.intel_syntax noprefix
.file "pre.s"
.text

.extern hs_init
.extern setup

.section .init_array, "aw"
.quad pre

.text
.global pre
    .type pre, @function
pre:
    pushq rbp
    movq rbp, rsp
    subq rsp, 16

    call hs_init
    call setup

    leave
    ret
