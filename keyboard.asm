; keyboard routines

; add events to the event queue if a key was pressed or released
; this should only be called by system_vsync_handler
keyboard_update:
    ; pop a key from the keyboard queue
    in r0, 0x80000500
    cmp r0, 0
    ifz jmp keyboard_update_end

    ; invoke the debug monitor if F12 was pressed
    cmp r0, 0x58
    ifz call invoke_monitor

    ; check if this is a make or break scancode
    bts r0, 7
    ifnz jmp keyboard_update_break_scancode

    mov r1, r0
    mov r0, EVENT_TYPE_KEY_DOWN
    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    call new_event
    jmp keyboard_update_end
keyboard_update_break_scancode:
    and r0, 0x7F
    mov r1, r0
    mov r0, EVENT_TYPE_KEY_UP
    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    call new_event
keyboard_update_end:
    ret
