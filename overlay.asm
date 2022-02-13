; overlay routines

; fill a whole overlay with a color
; inputs:
; r0: color
; r1: overlay number
; outputs:
; none
fill_overlay:
    push r1
    push r2
    push r3
    push r31

    mov r2, r1
    or r2, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r1, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r1, r1                ; r1: overlay framebuffer poiner
    in r2, r2
    mov r3, r2
    and r2, 0x0000FFFF       ; r2: X size
    sra r3, 16               ; r3: Y size
    mul r2, r3
    mov r31, r2
fill_overlay_loop:
    mov [r1], r0
    add r1, 4
    loop fill_overlay_loop

    pop r31
    pop r3
    pop r2
    pop r1
    ret

; draw a filled rectangle to an overlay
; inputs:
; r0: X coordinate of top-left
; r1: Y coordinate of top-left
; r2: X size
; r3: Y size
; r4: color
; r5: overlay number
; outputs:
; none
draw_filled_rectangle_to_overlay:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    ; calculate pointer to the framebuffer
    mov r6, r5               ; r6: overlay number
    or r6, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    in r7, r6
    and r7, 0x0000FFFF       ; mask off the height, we only need the width
    mul r7, 4                ; r7: overlay width in bytes (width * 4)
    mul r1, r7               ; y * width * 4
    mul r0, 4                ; x * 4
    add r0, r1               ; y * width * 4 + (x * 4)
    or r5, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r5, r5
    add r0, r5               ; r0: pointer to framebuffer

    mov r6, r2
    mul r6, 4                ; multiply the X size by 4, since 4 bytes per pixel

draw_filled_rectangle_to_overlay_y_loop:
    mov r5, r2               ; x counter
draw_filled_rectangle_to_overlay_x_loop:
    mov [r0], r4
    add r0, 4                ; increment framebuffer pointer
    dec r5
    ifnz jmp draw_filled_rectangle_to_overlay_x_loop ; loop if there are still more X pixels to draw

    sub r0, r6               ; return to the beginning of this line
    add r0, r7               ; increment to the next line
    dec r3
    ifnz jmp draw_filled_rectangle_to_overlay_y_loop ; loop if there are still more Y pixels to draw

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret

; draw a single font tile to an overlay
; inputs:
; r0: tile number
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; r5: overlay number
; outputs:
; none
draw_font_tile_to_overlay:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r6, r5
    or r6, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r5, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r8, r5                ; r8: overlay framebuffer poiner
    in r9, r6
    and r9, 0x0000FFFF       ; r9: overlay width

    mov r5, standard_font_data
    movz.16 r6, [standard_font_width]
    movz.16 r7, [standard_font_height]
    call draw_font_tile_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret

; draw text to an overlay
; inputs:
; r0: pointer to null-terminated string
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; r5: overlay number
; outputs:
; r1: X coordinate of end of text
draw_str_to_overlay:
    push r0
    push r6
    mov r6, r0
draw_str_to_overlay_loop:
    movz.8 r0, [r6]
    call draw_font_tile_to_overlay
    inc r6
    add r1, 8
    cmp.8 [r6], 0x00
    ifnz jmp draw_str_to_overlay_loop
    pop r6
    pop r0
    ret

; finds the overlay with the highest priority covering the specified position
; does not check overlay 31, which is always the mouse pointer
; inputs:
; r0: X coordinate
; r1: Y coordinate
; outputs:
; r0: overlay number
find_overlay_covering_position:
    ; TODO:

; checks if the specified overlay is covering the specified position on screen
; the overlay can be enabled or disabled
; example:
;     overlay 0 is at (0,0) and is 32x32 in size
;     point (4,2) is covered by overlay 0
;     point (16,16) is covered by overlay 0
;     point (31,31) is covered by overlay 0
;     point (32,32) is NOT covered by overlay 0, because it is outside of the overlay's area
; this works for overlays of any size, at any position on screen
; inputs:
; r0: X coordinate
; r1: Y coordinate
; r2: overlay number
; outputs:
; Z flag: set if covering, clear if not covering
check_if_overlay_covers_position:
    push r0
    push r1
    push r3
    push r4
    push r5
    push r6
    push r7

    mov r3, r2
    or r3, 0x80000000        ; bitwise or the overlay number with the command to get the overlay position
    in r4, r3
    mov r5, r4
    and r4, 0x0000FFFF       ; r4: X position
    sra r5, 16               ; r5: Y position

    mov r3, r2
    or r3, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    in r6, r3
    mov r7, r6
    and r6, 0x0000FFFF       ; r6: width
    sra r7, 16               ; r7: height

    add r6, r4
    add r7, r5

    ; (r4,r5): coordinates of top-left of the overlay
    ; (r6,r7): coordinates of bottom-right of the overlay

    ; now we need to check if:
    ; - (r4,r5) is greater than or equal to (r0,r1)
    ; and
    ; - (r6,r7) is less than or equal to (r0,r1)

    ; if carry flag is set, value is less than
    ; if carry flag is clear, value is greater than or equal to
    cmp r0, r4
    ifc jmp check_if_overlay_covers_position_fail
    cmp r0, r6
    ifnc jmp check_if_overlay_covers_position_fail

    cmp r1, r5
    ifc jmp check_if_overlay_covers_position_fail
    cmp r1, r7
    ifnc jmp check_if_overlay_covers_position_fail

    ; if we reached this point then the point is within the bounds of the overlay !!!

    mov.8 r0, 0
    cmp.8 r0, 0              ; set Z flag
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r1
    pop r0
    ret
check_if_overlay_covers_position_fail:
    mov.8 r0, 1
    cmp.8 r0, 0              ; clear Z flag
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r1
    pop r0
    ret

; checks if the specified overlay is covering the specified position on screen
; the overlay must be enabled
; example:
;     overlay 0 is at (0,0) and is 32x32 in size
;     point (4,2) is covered by overlay 0
;     point (16,16) is covered by overlay 0
;     point (31,31) is covered by overlay 0
;     point (32,32) is NOT covered by overlay 0, because it is outside of the overlay's area
; this works for overlays of any size, at any position on screen
; inputs:
; r0: X coordinate
; r1: Y coordinate
; r2: overlay number
; outputs:
; Z flag: set if covering, clear if not covering
check_if_enabled_overlay_covers_position:
    push r3
    push r4

    mov r3, r2
    or r3, 0x80000300        ; bitwise or the overlay number with the command to get the overlay enable status
    in r4, r3

    cmp r4, 0
    pop r4
    pop r3
    ifnz jmp check_if_enabled_overlay_covers_position_is_enabled
    cmp r4, 1                ; r4 is known to be zero at this point, so compare it with 1 to clear the Z flag
    ret
check_if_enabled_overlay_covers_position_is_enabled:
    call check_if_overlay_covers_position
    ret

; converts coordinates to be relative to the position of the specified overlay
; the overlay can be enabled or disabled
; example:
;     overlay is at (16,16)
;     (20,20) is specified
;     (4,4) will be returned
; inputs:
; r0: X coordinate
; r1: Y coordinate
; r2: overlay number
; outputs:
; r0: relative X coordinate
; r1: relative Y coordinate
make_coordinates_relative_to_overlay:
    push r2
    push r3

    or r2, 0x80000000        ; bitwise or the overlay number with the command to get the overlay position
    in r2, r2
    mov r3, r2
    and r2, 0x0000FFFF       ; r2: overlay X position
    sra r3, 16               ; r3: overlay Y position

    sub r0, r2
    sub r1, r3

    pop r3
    pop r2
    ret
