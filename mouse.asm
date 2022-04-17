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

; updates the cursor position and adds a event_type_mouse_click event to the event queue if the mouse button was clicked
; this should only be called by system_vsync_handler
mouse_update:
    mov r0, 0x8000001F            ; overlay 31: position
    in r2, 0x80000401             ; mouse position
    out r0, r2

    movz.16 r0, r2                ; r0: X position
    mov r1, r2
    sra r1, 16                    ; r1: Y position

    mov r2, 0x80000400            ; mouse button states
    in r3, r2

    ; check click bit
    push r2
    push r3
    bts r3, 0
    ifnz call mouse_update_clicked
    pop r3
    pop r2

    ; check release bit
    bts r3, 1
    ifnz call mouse_update_released

    jmp mouse_update_end
mouse_update_clicked:
    ; mouse was clicked, clear the click bit
    bcl r3, 0
    out r2, r3

    ; check if the mouse was clicked in the menu bar
    ;mov r2, 30
    ;call overlay_check_if_enabled_covers_position
    ;ifz jmp mouse_update_menu_was_clicked

    ; if Y <= 16, mouse was clicked in the menu bar
    ; this is less expensive than calling overlay_check_if_enabled_covers_position every frame
    ; first check if the menu bar is enabled
    in r3, 0x8000031E             ; overlay 30: enable status
    cmp r3, 0
    ifz jmp mouse_update_clicked_no_menu
    cmp r1, 17
    ifc jmp mouse_update_menu_was_clicked
mouse_update_clicked_no_menu:

    ; if a menu is open, don't push a click event
    ; this is hacky as fuck
    in r3, 0x8000031D             ; overlay 29: enable status
    cmp r3, 0
    ifnz ret

    ; otherwise, just add a standard mouse click event to the event queue
    mov r2, r1                    ; copy Y position to event parameter 1
    mov r1, r0                    ; copy X position to event parameter 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    mov r0, EVENT_TYPE_MOUSE_CLICK ; set event type to mouse click
    call new_event
    ret
mouse_update_released:
    ; mouse was released, clear the release bit
    bcl r3, 1
    out r2, r3

    mov r2, r1                    ; copy Y position to event parameter 1
    mov r1, r0                    ; copy X position to event parameter 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    mov r0, EVENT_TYPE_MOUSE_RELEASE ; set event type to mouse release
    call new_event
    ret
mouse_update_menu_was_clicked:
    mov r2, r1                    ; copy Y position to event parameter 1
    mov r1, r0                    ; copy X position to event parameter 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    mov r0, EVENT_TYPE_MENU_BAR_CLICK ; set event type to menu bar click type
    call new_event
    ret
mouse_update_end:
    ret
