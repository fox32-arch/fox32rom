; background routines

const BACKGROUND_FRAMEBUFFER: 0x80000000 ; pointer to background framebuffer

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
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6

    ; calculate pointer to the framebuffer
    mul r1, 2560             ; y * 2560 (640 * 4 = 2560)
    mul r0, 4                ; x * 4
    add r0, r1               ; y * 2560 + (x * 4)
    add r0, BACKGROUND_FRAMEBUFFER ; r0: pointer to framebuffer

    mov r6, r2
    mul r6, 4                ; multiply the X size by 4, since 4 bytes per pixel

draw_filled_rectangle_to_background_y_loop:
    mov r5, r2               ; x counter
draw_filled_rectangle_to_background_x_loop:
    mov [r0], r4
    add r0, 4                ; increment framebuffer pointer
    dec r5
    ifnz jmp draw_filled_rectangle_to_background_x_loop ; loop if there are still more X pixels to draw

    sub r0, r6               ; return to the beginning of this line
    add r0, 2560             ; 640*4, increment to the next line
    dec r3
    ifnz jmp draw_filled_rectangle_to_background_y_loop ; loop if there are still more Y pixels to draw

    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
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

    mov r5, standard_font_data
    movz.16 r6, [standard_font_width]
    movz.16 r7, [standard_font_height]
    mov r8, BACKGROUND_FRAMEBUFFER
    mov r9, 640
    call draw_font_tile_generic

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
    mov r5, r0
draw_str_to_background_loop:
    movz.8 r0, [r5]
    call draw_font_tile_to_background
    inc r5
    add r1, 8
    cmp.8 [r5], 0x00
    ifnz jmp draw_str_to_background_loop
    pop r5
    pop r0
    ret
