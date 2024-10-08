; keyboard routines

; add events to the event queue if a key was pressed or released
; this should only be called by system_vsync_handler
; inputs:
; none
; outputs:
; r0: non-zero if F12 was pressed, zero otherwise
keyboard_update:
    ; pop a key from the keyboard queue
    in r1, 0x80000500

    ; no key event
    cmp r1, 0
    ifz mov r0, 0
    ifz ret

    ; invoke the debug monitor if F12 was pressed
    cmp r1, 0x58
    ifz mov r0, 1
    ifz ret

    ; check if this is a key up or key down scancode
    bts r1, 7
    ifz mov r0, EVENT_TYPE_KEY_DOWN
    ifnz mov r0, EVENT_TYPE_KEY_UP
    ifnz and r1, 0x7F
    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    call new_event
    jmp keyboard_update
