; vsync interrupt routine

system_vsync_handler:
    add rsp, 4
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    call mouse_update
    call keyboard_update
    ; check if monitor should be started
    cmp r0, 0
    ifnz jmp system_vsync_handler_breakpoint

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    reti

system_vsync_handler_breakpoint:
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ; breakpoint handler expects that there is an extra 4 bytes on the stack
    sub rsp, 4
    jmp system_breakpoint_handler
