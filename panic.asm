; panic routines

; panic invoke the monitor
; inputs:
; r0: pointer to null-terminated string, or zero for none
; outputs:
; none, does not return
panic:
    push r0
    cmp r0, 0
    ifz mov r0, panic_string
    call debug_print
    call print_string_to_monitor
    pop r0
    brk
    rjmp 0

panic_string: data.str "Unspecified panic occurred!" data.8 10 data.8 0
