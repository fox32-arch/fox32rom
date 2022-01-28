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

; updates the cursor position and pushes a mouse_click_event_type event to the event stack if the mouse button was clicked
; this should only be called by system_vsync_handler
mouse_update:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5

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
    ; mouse was clicked
    out r2, 0                     ; clear all button state bits

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

    ; otherwise, just push a standard mouse click event to the event stack
    mov r2, r1                    ; copy Y position to event parameter 1
    mov r1, r0                    ; copy X position to event parameter 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r0, mouse_click_event_type ; set event type to mouse type
    call push_event
    jmp mouse_update_end
mouse_update_menu_was_clicked:
    mov r2, r1                    ; copy Y position to event parameter 1
    mov r1, r0                    ; copy X position to event parameter 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r0, menu_bar_click_event_type ; set event type to menu bar click type
    call push_event
mouse_update_end:
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret