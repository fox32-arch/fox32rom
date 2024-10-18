; overlay routines

; enable an overlay
; inputs:
; r0: overlay number
; outputs:
; none
enable_overlay:
    push r0

    or r0, 0x80000300
    out r0, 1

    pop r0
    ret

; disable an overlay
; inputs:
; r0: overlay number
; outputs:
; none
disable_overlay:
    push r0

    or r0, 0x80000300
    out r0, 0

    pop r0
    ret

; move an overlay
; r0: X position
; r1: Y position
; r2: overlay number
move_overlay:
    push r1
    push r2

    or r2, 0x80000000
    sla r1, 16
    mov.16 r1, r0
    out r2, r1

    pop r2
    pop r1
    ret

; resize an overlay
; r0: width
; r1: height
; r2: overlay number
resize_overlay:
    push r1
    push r2

    or r2, 0x80000100
    sla r1, 16
    mov.16 r1, r0
    out r2, r1

    pop r2
    pop r1
    ret

; set an overlay's framebuffer pointer
; r0: framebuffer pointer
; r1: overlay number
set_overlay_framebuffer_pointer:
    push r1

    or r1, 0x80000200
    out r1, r0

    pop r1
    ret

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
    in r1, r1                ; r1: overlay framebuffer pointer
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

; draw a pixel to an overlay
; inputs:
; r0: X coordinate
; r1: Y coordinate
; r2: color
; r3: overlay number
; outputs:
; none
draw_pixel_to_overlay:
    push r3
    push r4

    mov r4, r3
    or r4, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r3, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r3, r3                ; r3: overlay framebuffer pointer
    in r4, r4
    and r4, 0x0000FFFF       ; r4: overlay width

    call draw_pixel_generic

    pop r4
    pop r3
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
    push r5
    push r6

    mov r6, r5
    or r6, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r5, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r5, r5                ; r5: overlay framebuffer pointer
    in r6, r6
    and r6, 0x0000FFFF       ; r6: overlay width

    call draw_filled_rectangle_generic

    pop r6
    pop r5
    ret

; draw a single tile to an overlay
; inputs:
; r0: tile number
; r1: X coordinate
; r2: Y coordinate
; r3: overlay number
; outputs:
; none
draw_tile_to_overlay:
    push r3
    push r4
    push r8
    push r9

    mov r4, r3
    or r4, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r3, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r8, r3                ; r8: overlay framebuffer pointer
    in r9, r4
    and r9, 0x0000FFFF       ; r9: overlay width

    call draw_tile_generic

    pop r9
    pop r8
    pop r4
    pop r3
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
    in r8, r5                ; r8: overlay framebuffer pointer
    in r9, r6
    and r9, 0x0000FFFF       ; r9: overlay width

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    call draw_font_tile_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret

; draw text to an overlay, using printf-style formatting
; inputs:
; r0: pointer to null-terminated string
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; r5: overlay number
; r10-r15: optional format values
; outputs:
; r1: X coordinate of end of text
draw_format_str_to_overlay:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r6, r5
    or r6, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r5, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r8, r5                ; r8: overlay framebuffer pointer
    in r9, r6
    and r9, 0x0000FFFF       ; r9: overlay width

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    call draw_format_str_generic

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

; draw a decimal value to an overlay
; inputs:
; r0: value
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; r5: overlay number
; outputs:
; r1: X coordinate of end of text
draw_decimal_to_overlay:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r6, r5
    or r6, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r5, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r8, r5                ; r8: overlay framebuffer pointer
    in r9, r6
    and r9, 0x0000FFFF       ; r9: overlay width

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    call draw_decimal_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret

; draw a hex value to an overlay
; inputs:
; r0: value
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; r5: overlay number
; outputs:
; r1: X coordinate of end of text
draw_hex_to_overlay:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r6, r5
    or r6, 0x80000100        ; bitwise or the overlay number with the command to get the overlay size
    or r5, 0x80000200        ; bitwise or the overlay number with the command to get the framebuffer pointer
    in r8, r5                ; r8: overlay framebuffer pointer
    in r9, r6
    and r9, 0x0000FFFF       ; r9: overlay width

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    call draw_hex_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret

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

; find the first disabled overlay, starting from 0
; inputs:
; none
; outputs:
; r0: overlay number, or 0xFF if all overlays are enabled
get_unused_overlay:
    push r1
    push r31

    mov r0, 0x80000300
    mov r31, 31
get_unused_overlay_loop:
    in r1, r0
    cmp r1, 0
    ifz jmp get_unused_overlay_found
    inc r0
    loop get_unused_overlay_loop
    mov r0, 0xFF

    pop r31
    pop r1
    ret
get_unused_overlay_found:
    and r0, 0x000000FF

    pop r31
    pop r1
    ret
