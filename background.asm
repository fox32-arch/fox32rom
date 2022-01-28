; background routines

const background: 0x80000000 ; pointer to background framebuffer

; fill the whole background with a color
; inputs:
; r0: color
; outputs:
; none
fill_background:
    push r1
    push r31

    mov r1, background
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
    add r0, background       ; r0: pointer to framebuffer

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
    push r0
    push r1
    push r2
    push r5
    push r6

    ;movz.8 r0, r0            ; ensure the tile number is a single byte

    ; calculate pointer to the tile data
    push r1
    push r2
    mov r1, 8                ; tile width
    mov r2, 16               ; tile height
    mul r1, r2
    mul r0, r1
    mul r0, 4                ; 4 bytes per pixel
    add r0, font             ; r0: pointer to tile data
    pop r2
    pop r1

    ; calculate pointer to the framebuffer
    mul r2, 2560             ; y * 2560 (640 * 4 = 2560)
    mul r1, 4                ; x * 4
    add r1, r2               ; y * 2560 + (x * 4)
    add r1, background       ; r1: pointer to framebuffer

    mov r6, 16               ; y counter
draw_font_tile_to_background_y_loop:
    mov r5, 8                ; x counter
draw_font_tile_to_background_x_loop:
    mov r2, [r0]
    cmp r2, 0xFF000000
    ifz jmp draw_font_tile_to_background_x_loop_background
    ; drawing foreground pixel
    cmp r3, 0x00000000       ; is the foreground color supposed to be transparent?
    ifz jmp draw_font_tile_to_background_x_loop_end
    mov [r1], r3             ; draw foreground color
    jmp draw_font_tile_to_background_x_loop_end
draw_font_tile_to_background_x_loop_background:
    ; drawing background pixel
    cmp r4, 0x00000000       ; is the background color supposed to be transparent?
    ifz jmp draw_font_tile_to_background_x_loop_end
    mov [r1], r4             ; draw background color
draw_font_tile_to_background_x_loop_end:
    add r0, 4                ; increment tile pointer
    add r1, 4                ; increment framebuffer pointer
    dec r5
    ifnz jmp draw_font_tile_to_background_x_loop ; loop if there are still more X pixels to draw
    sub r1, 32               ; 8*4, return to the beginning of this line
    add r1, 2560             ; 640*4, increment to the next line
    dec r6
    ifnz jmp draw_font_tile_to_background_y_loop ; loop if there are still more Y pixels to draw

    pop r6
    pop r5
    pop r2
    pop r1
    pop r0
    ret

; draw text on the background
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
