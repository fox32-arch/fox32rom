; exception handling routines

; called if a divide by zero occurs
; does not return, calls panic
system_div_zero_handler:
    push r0

    mov r0, system_div_zero_str
    call debug_print
    call print_string_to_monitor

    pop r0
    jmp system_breakpoint_handler
system_div_zero_str: data.str "Divide by zero" data.8 10 data.8 0

; called if an invalid opcode is executed
; does not return, calls panic
system_invalid_op_handler:
    push r0

    mov r0, system_invalid_op_str
    call debug_print
    call print_string_to_monitor

    pop r0
    jmp system_breakpoint_handler
system_invalid_op_str: data.str "Invalid opcode" data.8 10 data.8 0

; called if a bus error or page fault occurs
; does not return, calls panic
system_bus_error_handler:
    push r0

    mov r0, system_bus_error_str_0
    call debug_print

    mov r0, system_bus_error_str_1
    call print_string_to_monitor
    mov r0, [rsp+4]
    call print_hex_word_to_monitor
    mov r0, 10
    call print_character_to_monitor

    pop r0
    pop r1
    jmp system_breakpoint_handler
system_bus_error_str_0: data.str "Bus error" data.8 10 data.8 0
system_bus_error_str_1: data.strz "Bus error while accessing address "

; called upon execution of a `brk` instruction
; ensure the stack has at least 128 bytes of free space before triggering this exception!!
system_breakpoint_handler:
    add rsp, 4

    ; push all registers once to save them
    push rfp
    push resp
    push rsp
    push r31
    push r30
    push r29
    push r28
    push r27
    push r26
    push r25
    push r24
    push r23
    push r22
    push r21
    push r20
    push r19
    push r18
    push r17
    push r16
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push r7
    push r6
    push r5
    push r4
    push r3
    push r2
    push r1
    push r0

    ; modify the saved rsp value to reflect the value of rsp before the
    ; interrupt occurred
    ; resp (4) + rfp (4) + flags (1) + return address (4) = 13 bytes
    add [rsp+128], 13

    ; print breakpoint message
    mov r0, system_breakpoint_str
    call debug_print
    call print_string_to_monitor

    call invoke_monitor

    pop r0
    pop r1
    pop r2
    pop r3
    pop r4
    pop r5
    pop r6
    pop r7
    pop r8
    pop r9
    pop r10
    pop r11
    pop r12
    pop r13
    pop r14
    pop r15
    pop r16
    pop r17
    pop r18
    pop r19
    pop r20
    pop r21
    pop r22
    pop r23
    pop r24
    pop r25
    pop r26
    pop r27
    pop r28
    pop r29
    pop r30
    pop r31
    ; don't restore rsp and resp. not sure whether restoring a potentially
    ; modified resp would break things, but changing rsp definitely would.
    add rsp, 8
    pop rfp
    reti
system_breakpoint_str:     data.str "Breakpoint reached!" data.8 10 data.8 0
