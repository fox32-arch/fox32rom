; exception handling routines

; called if a divide by zero occurs
; does not return, calls panic
system_div_zero_handler:
    mov r0, system_div_zero_str
    jmp panic
system_div_zero_str: data.str "Divide by zero" data.8 10 data.8 0

; called if an invalid opcode is executed
; does not return, calls panic
system_invalid_op_handler:
    mov r0, system_invalid_op_str
    jmp panic
system_invalid_op_str: data.str "Invalid opcode" data.8 10 data.8 0

; called if a page fault occurs
; does not return, calls panic
system_page_fault_handler:
    mov r0, system_page_fault_str
    pop r1
    jmp panic
system_page_fault_str: data.str "Page fault at virtual address r1" data.8 10 data.8 0

; called upon execution of a `brk` instruction
system_breakpoint_handler:
    add rsp, 4
    push r0

    mov r0, system_breakpoint_str
    call debug_print

    pop r0
    reti
system_breakpoint_str: data.str "Breakpoint reached!" data.8 10 data.8 0
