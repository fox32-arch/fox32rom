; submenu routines

; draw submenu items
; inputs:
; r0: pointer to menu bar root struct
; r1: selected root menu item
; r2: hovering submenu item (or 0xFFFFFFFF for none)
; outputs:
; none
draw_submenu_items:
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

    ; calculate the X position of the submenu
    mov r31, r1                   ; load number of the selected item into r31 for looping
    mov r30, 16                   ; X counter
    cmp r31, 0                    ; we don't need to loop if this is submenu 0
    ifz jmp draw_submenu_items_calculate_x_skip
    mov r4, r0
    add r4, 5                     ; point to start of root menu items text pointer
draw_submenu_items_calculate_x_loop:
    mov r3, [r4]                  ; get pointer to text
    movz.8 r3, [r3]               ; get text length byte
    add r3, 2                     ; add 2 for the spaces on each side of the text
    mul r3, 8                     ; characters are 8 pixels wide
    add r30, r3                   ; add length to X counter
    add r4, 8                     ; point to next text pointer
    loop draw_submenu_items_calculate_x_loop
draw_submenu_items_calculate_x_skip:
    sub r30, 8                    ; move the submenu to the left by 8 pixels
    mov.16 [overlay_29_position_x], r30

    mov r31, r0
    inc r31                       ; point to submenu list pointer
    mul r1, 8                     ; point to the selected submenu
    add r31, r1
    mov r0, [r31]                 ; load submenu list pointer
    movz.8 r31, [r0]              ; load number of submenu items
    mov r30, r2                   ; r30: number of the hovered item
    mov r29, 0                    ; counter of how many submenu items drawn so far

    ; calculate the required height for the submenu overlay
    ; multiply the number of submenu items by 16 (the font is 16 pixels tall)
    mov r1, r31
    mul r1, 16
    mov.16 [overlay_29_height], r1

    ; calculate the required width for the submenu overlay
    ; multiply the width by 8 (the font is 8 pixels wide)
    mov r1, r0
    inc r1
    movz.8 r1, [r1]               ; load width of submenu
    mov r8, r1                    ; save the width in characters in r8 for later
    mul r1, 8
    mov.16 [overlay_29_width], r1

    push r0

    ; set properties of overlay 29
    mov.16 [overlay_29_position_y], 16
    mov [overlay_29_framebuffer_ptr], overlay_29_framebuffer
    mov r0, 0x0200001D ; overlay 29: position
    mov.16 r1, [overlay_29_position_y]
    sla r1, 16
    mov.16 r1, [overlay_29_position_x]
    out r0, r1
    mov r0, 0x0200011D ; overlay 29: size
    mov.16 r1, [overlay_29_height]
    sla r1, 16
    mov.16 r1, [overlay_29_width]
    out r0, r1
    mov r0, 0x0200021D ; overlay 29: framebuffer pointer
    mov r1, [overlay_29_framebuffer_ptr]
    out r0, r1
    mov r0, 0x0200031D
    out r0, 1

    ; draw empty submenu
    mov r6, r31                   ; outer loop counter
    movz.8 r0, ' '
    mov r1, 0
    mov r2, 0
    mov r3, 0xFF000000
    mov r4, 0xFFFFFFFF
    mov r5, 29
draw_empty_submenu_loop:
    mov r7, r8                    ; inner loop counter
    cmp r30, r29
    ifz mov r3, 0xFFFFFFFF        ; foreground color: white
    ifz mov r4, 0xFF000000        ; background color: black
    ifnz mov r3, 0xFF000000       ; foreground color: black
    ifnz mov r4, 0xFFFFFFFF       ; background color: white
draw_empty_submenu_line_loop:
    call draw_font_tile_to_overlay
    add r1, 8
    dec r7
    ifnz jmp draw_empty_submenu_line_loop
    mov r1, 0
    add r2, 16
    inc r29
    dec r6
    ifnz jmp draw_empty_submenu_loop
    mov r29, 0                    ; counter of how many submenu items drawn so far
    pop r0

    ; draw submenu text
    add r0, 3                     ; point to start of submenu items text
    mov r2, 0                     ; Y = 0
draw_submenu_text_loop:
    cmp r30, r29
    ifz mov r3, 0xFFFFFFFF        ; foreground color: white
    ifz mov r4, 0xFF000000        ; background color: black
    ifnz mov r3, 0xFF000000       ; foreground color: black
    ifnz mov r4, 0xFFFFFFFF       ; background color: white

    mov r1, 0                     ; X = 0
    call draw_str_to_overlay      ; draw submenu item text

    mov r1, r0
    dec r1                        ; point to length byte of this menu item
    movz.8 r1, [r1]               ; load length byte
    inc r1                        ; add one to count the null-terminator
    add r0, r1                    ; add length to menu item text pointer
    inc r0                        ; increment past length byte
    add r2, 16                    ; add 16 to Y
    inc r29
    loop draw_submenu_text_loop

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

; hide the submenu
; inputs:
; r0: pointer to menu bar root struct
; outputs:
; none
close_submenu:
    push r1

    ; disable overlay 29
    mov r1, 0x0200031D
    out r1, 0

    mov r1, 0xFFFFFFFF
    call draw_menu_bar_root_items

    pop r1
    ret

; update the currently open submenu
; detects mouse movements over the submenu and handles clicks
; this should only be called if a submenu_update_event_type event is received
; inputs:
; *** these inputs should already be in the required registers from the event parameters ***
; r1: pointer to menu bar root struct
; r2: selected root menu item
; r3: hovering submenu item (or 0xFFFFFFFF for none)
; outputs:
; none
; the event is pushed back onto the event stack if the submenu is still open
submenu_update_event:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r8
    push r9

    mov r8, r1                    ; r8: pointer to menu bar root struct
    mov r9, r2                    ; r9: selected root menu item
    mov r10, r3                   ; r10: hovering submenu item (or 0xFFFFFFFF for none)

    ; get the current mouse position and check if the submenu overlay covers that position
    ; if the mouse is not in the submenu, then there is nothing to do
    call get_mouse_position
    mov r2, 29
    call check_if_enabled_overlay_covers_position
    ifnz jmp submenu_update_event_end_push

    ; make the mouse position relative to the submenu overlay
    mov r2, 29
    call make_coordinates_relative_to_overlay

    ; if the currently hovered item is different than the hovered item in the event parameters,
    ; then redraw the submenu with correct hovered item
    div r1, 16                    ; mouse Y / 16
    cmp r1, r10                   ; compare the currently hovered item to the hovered item in event parameter 2
    ifz jmp submenu_update_event_no_redraw
    mov r10, r1                   ; set the hovering item to the currently hovering item
    mov r2, r1
    mov r1, r9
    mov r0, r8
    call draw_submenu_items
submenu_update_event_no_redraw:
    ; check the mouse held bit
    ; this is kinda hacky but it works
    call get_mouse_button
    bts r0, 1
    ifnz jmp submenu_update_event_clicked

    jmp submenu_update_event_end_push
submenu_update_event_clicked:
    ;div r2, 16                    ; mouse Y / 16
    mov r1, r8                    ; event parameter 0: pointer to menu bar root struct
    mov r2, r9                    ; event parameter 1: selected root menu item
    mov r3, r10                   ; event parameter 2: selected submenu item
    mov r4, 0
    mov r5, 0
    mov r0, submenu_click_event_type
    call push_event
    mov r0, r1
    call close_submenu
    jmp submenu_update_event_end_no_push
submenu_update_event_end_push:
    ; repush the submenu_update_event_type event to the event stack
    mov r1, r8                    ; event parameter 0: pointer to menu bar root struct
    mov r2, r9                    ; event parameter 1: selected root menu item
    mov r3, r10                   ; event parameter 2: hovering submenu item (or 0xFFFFFFFF for none)
    mov r4, 0
    mov r5, 0
    mov r0, submenu_update_event_type
    call push_event
submenu_update_event_end_no_push:
    pop r9
    pop r8
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret