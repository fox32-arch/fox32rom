; generic rectangle drawing routines

; draw a filled rectangle to a framebuffer
; inputs:
; r0: X coordinate of top-left
; r1: Y coordinate of top-left
; r2: X size
; r3: Y size
; r4: color
; r5: pointer to framebuffer
; r6: framebuffer width (pixels)
; outputs:
; none
draw_filled_rectangle_generic:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    ; calculate pointer to the framebuffer
    mul r6, 4                ; 4 bytes per pixel
    mul r1, r6               ; y * width * 4
    mul r0, 4                ; x * 4
    add r0, r1               ; y * width * 4 + (x * 4)
    add r5, r0
    mov r0, r5               ; r0: pointer to framebuffer

    mov r7, r6
    mov r6, r2
    mul r6, 4                ; multiply the X size by 4, since 4 bytes per pixel

draw_filled_rectangle_generic_y_loop:
    mov r5, r2               ; x counter
draw_filled_rectangle_generic_x_loop:
    mov [r0], r4
    add r0, 4                ; increment framebuffer pointer
    dec r5
    ifnz jmp draw_filled_rectangle_generic_x_loop ; loop if there are still more X pixels to draw

    sub r0, r6               ; return to the beginning of this line
    add r0, r7               ; increment to the next line
    dec r3
    ifnz jmp draw_filled_rectangle_generic_y_loop ; loop if there are still more Y pixels to draw

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret
