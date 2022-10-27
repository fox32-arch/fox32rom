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

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    reti
