; background routines

const BACKGROUND_FRAMEBUFFER: 0x02000000 ; base address of background framebuffer

; fill the whole background with a color
; inputs:
; r0: color
; outputs:
; none
fill_background:
    push r1
    push r31

    mov r1, BACKGROUND_FRAMEBUFFER
    mov r31, 0x0004B000 ; 640*480
fill_background_loop:
    mov [r1], r0
    add r1, 4
    loop fill_background_loop

    pop r31
    pop r1
    ret

; draw a pixel to the background
; inputs:
; r0: X coordinate
; r1: Y coordinate
; r2: color
; outputs:
; none
draw_pixel_to_background:
    push r5
    push r6

    mov r3, BACKGROUND_FRAMEBUFFER
    mov r4, 640
    call draw_pixel_generic

    pop r6
    pop r5
    ret

; draw a filled rectangle to the background
; inputs:
; r0: X coordinate of top-left
; r1: Y coordinate of top-left
; r2: X size
; r3: Y size
; r4: color
; outputs:
; none
draw_filled_rectangle_to_background:
    push r5
    push r6

    mov r5, BACKGROUND_FRAMEBUFFER
    mov r6, 640
    call draw_filled_rectangle_generic

    pop r6
    pop r5
    ret

; draw a single tile to the background
; inputs:
; r0: tile number
; r1: X coordinate
; r2: Y coordinate
; outputs:
; none
draw_tile_to_background:
    push r8
    push r9

    mov r8, BACKGROUND_FRAMEBUFFER
    mov r9, 640
    call draw_tile_generic

    pop r9
    pop r8
    ret

; draw a single font tile to the background
; inputs:
; r0: tile number
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; outputs:
; none
draw_font_tile_to_background:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    mov r8, BACKGROUND_FRAMEBUFFER
    mov r9, 640
    call draw_font_tile_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret

; draw text to the background, using printf-style formatting
; inputs:
; r0: pointer to null-terminated string
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; r10-r15: optional format values
; outputs:
; r1: X coordinate of end of text
draw_format_str_to_background:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    mov r8, BACKGROUND_FRAMEBUFFER
    mov r9, 640
    call draw_format_str_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret

; draw text to the background
; inputs:
; r0: pointer to null-terminated string
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; outputs:
; r1: X coordinate of end of text
draw_str_to_background:
    push r0
    push r5
    push r6
    mov r5, r0
    mov r6, [FONT_PTR]
    movz.16 r6, [r6] ; font width
draw_str_to_background_loop:
    movz.8 r0, [r5]
    call draw_font_tile_to_background
    inc r5
    add r1, r6
    cmp.8 [r5], 0x00
    ifnz jmp draw_str_to_background_loop
    pop r6
    pop r5
    pop r0
    ret

; draw a decimal value to the background
; inputs:
; r0: value
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; outputs:
; r1: X coordinate of end of text
draw_decimal_to_background:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    mov r8, BACKGROUND_FRAMEBUFFER
    mov r9, 640
    call draw_decimal_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret

; draw a hex value to the background
; inputs:
; r0: value
; r1: X coordinate
; r2: Y coordinate
; r3: foreground color
; r4: background color
; outputs:
; r1: X coordinate of end of text
draw_hex_to_background:
    push r5
    push r6
    push r7
    push r8
    push r9

    mov r5, [FONT_PTR]
    movz.16 r6, [r5]
    movz.16 r7, [r5+2]
    inc r5, 4
    mov r8, BACKGROUND_FRAMEBUFFER
    mov r9, 640
    call draw_hex_generic

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    ret
