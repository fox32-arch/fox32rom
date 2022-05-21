; panic routines

; panic and hang
; inputs:
; r0: pointer to null-terminated string, or zero for none
; outputs:
; none, does not return
panic:
    brk
    cmp r0, 0
    ifz mov r0, panic_string
    call debug_print
panic_loop:
    jmp panic_loop
    halt

panic_string: data.str "Panic occurred!" data.8 10 data.8 0
