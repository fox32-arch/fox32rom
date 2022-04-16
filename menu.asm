; menu routines

const MENU_SELECTED_BACKGROUND_COLOR:   0xFFFFFFFF
const MENU_SELECTED_TEXT_COLOR:         0xFF000000
const MENU_UNSELECTED_BACKGROUND_COLOR: 0xFF3F3F3F
const MENU_UNSELECTED_TEXT_COLOR:       0xFFFFFFFF

; draw menu items
; inputs:
; r0: pointer to menu bar root struct
; r1: selected root menu item
; r2: hovering menu item (or 0xFFFFFFFF for none)
; outputs:
; none
draw_menu_items:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8
    push r29
    push r30
    push r31

    ; calculate the X position of the menu
    mov r31, r1                   ; load number of the selected item into r31 for looping
    mov r30, 16                   ; X counter
    cmp r31, 0                    ; we don't need to loop if this is menu 0
    ifz jmp draw_menu_items_calculate_x_skip
    mov r4, r0
    add r4, 5                     ; point to start of root menu items text pointer
draw_menu_items_calculate_x_loop:
    mov r3, [r4]                  ; get pointer to text
    movz.8 r3, [r3]               ; get text length byte
    add r3, 2                     ; add 2 for the spaces on each side of the text
    mul r3, 8                     ; characters are 8 pixels wide
    add r30, r3                   ; add length to X counter
    add r4, 8                     ; point to next text pointer
    loop draw_menu_items_calculate_x_loop
draw_menu_items_calculate_x_skip:
    sub r30, 8                    ; move the menu to the left by 8 pixels
    mov.16 [OVERLAY_29_POSITION_X], r30

    mov r31, r0
    inc r31                       ; point to menu list pointer
    mul r1, 8                     ; point to the selected menu
    add r31, r1
    mov r0, [r31]                 ; load menu list pointer
    movz.8 r31, [r0]              ; load number of menu items
    mov r30, r2                   ; r30: number of the hovered item
    mov r29, 0                    ; counter of how many menu items drawn so far

    ; calculate the required height for the menu overlay
    ; multiply the number of menu items by 16 (the font is 16 pixels tall)
    mov r1, r31
    mul r1, 16
    mov.16 [OVERLAY_29_HEIGHT], r1

    ; calculate the required width for the menu overlay
    ; multiply the width by 8 (the font is 8 pixels wide)
    mov r1, r0
    inc r1
    movz.8 r1, [r1]               ; load width of menu
    mov r8, r1                    ; save the width in characters in r8 for later
    mul r1, 8
    mov.16 [OVERLAY_29_WIDTH], r1

    push r0

    ; set properties of overlay 29
    mov.16 [OVERLAY_29_POSITION_Y], 16
    mov [OVERLAY_29_FRAMEBUFFER_PTR], OVERLAY_29_FRAMEBUFFER
    mov r0, 0x8000001D ; overlay 29: position
    mov.16 r1, [OVERLAY_29_POSITION_Y]
    sla r1, 16
    mov.16 r1, [OVERLAY_29_POSITION_X]
    out r0, r1
    mov r0, 0x8000011D ; overlay 29: size
    mov.16 r1, [OVERLAY_29_HEIGHT]
    sla r1, 16
    mov.16 r1, [OVERLAY_29_WIDTH]
    out r0, r1
    mov r0, 0x8000021D ; overlay 29: framebuffer pointer
    mov r1, [OVERLAY_29_FRAMEBUFFER_PTR]
    out r0, r1
    mov r0, 0x8000031D
    out r0, 1

    ; draw empty menu
    mov r6, r31                   ; outer loop counter
    movz.8 r0, ' '
    mov r1, 0
    mov r2, 0
    mov r5, 29
draw_empty_menu_loop:
    mov r7, r8                    ; inner loop counter
    cmp r30, r29
    ;ifz mov r3, MENU_UNSELECTED_BACKGROUND_COLOR
    ifz mov r4, MENU_SELECTED_BACKGROUND_COLOR
    ;ifnz mov r3, MENU_SELECTED_BACKGROUND_COLOR
    ifnz mov r4, MENU_UNSELECTED_BACKGROUND_COLOR
draw_empty_menu_line_loop:
    call draw_font_tile_to_overlay
    add r1, 8
    dec r7
    ifnz jmp draw_empty_menu_line_loop
    mov r1, 0
    add r2, 16
    inc r29
    dec r6
    ifnz jmp draw_empty_menu_loop
    mov r29, 0                    ; counter of how many menu items drawn so far
    pop r0

    ; draw menu text
    add r0, 3                     ; point to start of menu items text
    mov r2, 0                     ; Y = 0
draw_menu_text_loop:
    cmp r30, r29
    ifz mov r3, MENU_SELECTED_TEXT_COLOR
    ifz mov r4, MENU_SELECTED_BACKGROUND_COLOR
    ifnz mov r3, MENU_UNSELECTED_TEXT_COLOR
    ifnz mov r4, MENU_UNSELECTED_BACKGROUND_COLOR

    mov r1, 0                     ; X = 0
    call draw_str_to_overlay      ; draw menu item text

    mov r1, r0
    dec r1                        ; point to length byte of this menu item
    movz.8 r1, [r1]               ; load length byte
    inc r1                        ; add one to count the null-terminator
    add r0, r1                    ; add length to menu item text pointer
    inc r0                        ; increment past length byte
    add r2, 16                    ; add 16 to Y
    inc r29
    loop draw_menu_text_loop

    pop r31
    pop r30
    pop r29
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret

; hide the menu
; inputs:
; r0: pointer to menu bar root struct
; outputs:
; none
close_menu:
    push r1

    ; disable overlay 29
    mov r1, 0x8000031D
    out r1, 0

    mov r1, 0xFFFFFFFF
    call draw_menu_bar_root_items

    pop r1
    ret

; update the currently open menu
; detects mouse movements over the menu and handles clicks
; this should only be called if a event_type_menu_update event is received
; inputs:
; *** these inputs should already be in the required registers from the event parameters ***
; r1: pointer to menu bar root struct
; r2: selected root menu item
; r3: hovering menu item (or 0xFFFFFFFF for none)
; outputs:
; none
; the event is added back into the event queue if the menu is still open
menu_update_event:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r8, r1                    ; r8: pointer to menu bar root struct
    mov r9, r2                    ; r9: selected root menu item
    mov r10, r3                   ; r10: hovering menu item (or 0xFFFFFFFF for none)

    ; check if the menu overlay is enabled
    ; if the menu was closed then exit without readding the update event to the event queue
    in r0, 0x8000031D
    cmp r0, 0
    ifz jmp menu_update_event_end_no_add

    ; get the current mouse position and check if the menu overlay covers that position
    ; if the mouse is not in the menu, then there is nothing to do
    call get_mouse_position
    mov r2, 29
    call check_if_enabled_overlay_covers_position
    ifnz jmp menu_update_event_end_add

    ; make the mouse position relative to the menu overlay
    mov r2, 29
    call make_coordinates_relative_to_overlay

    ; if the currently hovered item is different than the hovered item in the event parameters,
    ; then redraw the menu with correct hovered item
    div r1, 16                    ; mouse Y / 16
    cmp r1, r10                   ; compare the currently hovered item to the hovered item in event parameter 2
    ifz jmp menu_update_event_no_redraw
    mov r10, r1                   ; set the hovering item to the currently hovering item
    mov r2, r1
    mov r1, r9
    mov r0, r8
    call draw_menu_items
menu_update_event_no_redraw:
    ; check the mouse held bit
    ; this is kinda hacky but it works
    call get_mouse_button
    bts r0, 1
    ifnz jmp menu_update_event_clicked

    jmp menu_update_event_end_add
menu_update_event_clicked:
    ;div r2, 16                    ; mouse Y / 16
    mov r1, r8                    ; event parameter 0: pointer to menu bar root struct
    mov r2, r9                    ; event parameter 1: selected root menu item
    mov r3, r10                   ; event parameter 2: selected menu item
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    mov r0, EVENT_TYPE_MENU_CLICK
    call new_event
    mov r0, r1
    call close_menu
    jmp menu_update_event_end_no_add
menu_update_event_end_add:
    ; readd the event_type_menu_update event to the event queue
    mov r1, r8                    ; event parameter 0: pointer to menu bar root struct
    mov r2, r9                    ; event parameter 1: selected root menu item
    mov r3, r10                   ; event parameter 2: hovering menu item (or 0xFFFFFFFF for none)
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0
    mov r0, EVENT_TYPE_MENU_UPDATE
    call new_event
menu_update_event_end_no_add:
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret
