; mouse routines

; gets the current position of the mouse cursor
; this gets the position of the cursor overlay, rather than actually getting the mouse position
; inputs:
; none
; outputs:
; r0: X coordinate
; r1: Y coordinate
get_mouse_position:
    in r0, 0x8000001F             ; overlay 31: position
    mov r1, r0
    and r0, 0x0000FFFF            ; r0: overlay X position
    sra r1, 16                    ; r1: overlay Y position

    ret

; gets the current state of the mouse button
; inputs:
; none
; outputs:
; r0: button state
get_mouse_button:
    in r0, 0x80000400             ; mouse button states

    ret

; updates the cursor position and adds a mouse_click_event_type event to the event queue if the mouse button was clicked
; this should only be called by system_vsync_handler
mouse_update:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    mov r0, 0x8000001F            ; overlay 31: position
    in r2, 0x80000401             ; mouse position
    out r0, r2

    movz.16 r0, r2                ; r0: X position
    mov r1, r2
    sra r1, 16                    ; r1: Y position

    mov r2, 0x80000400            ; mouse button states
    in r3, r2

    ; check click bit
    bts r3, 0
    ifz jmp mouse_update_end
    ; mouse was clicked, clear the click bit
    bcl r3, 0
    out r2, r3

    ; check if the mouse was clicked in the menu bar
    ;mov r2, 30
    ;call overlay_check_if_enabled_covers_position
    ;ifz jmp mouse_update_menu_was_clicked

    ; if Y <= 16, mouse was clicked in the menu bar
    ; this is less expensive than calling overlay_check_if_enabled_covers_position every frame
    cmp r1, 17
    ifc jmp mouse_update_menu_was_clicked

    ; if a submenu is open, don't push a click event
    ; this is hacky as fuck
    in r3, 0x8000031D             ; overlay 29: enable status
    cmp r3, 0
    ifnz jmp mouse_update_end

    ; otherwise, just add a standard mouse click event to the event queue
    mov r2, r1                    ; copy Y position to event parameter 1
    mov r1, r0                    ; copy X position to event parameter 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    mov r0, MOUSE_CLICK_EVENT_TYPE ; set event type to mouse type
    call new_event
    jmp mouse_update_end
mouse_update_menu_was_clicked:
    mov r2, r1                    ; copy Y position to event parameter 1
    mov r1, r0                    ; copy X position to event parameter 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    mov r0, MENU_BAR_CLICK_EVENT_TYPE ; set event type to menu bar click type
    call new_event
mouse_update_end:
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret