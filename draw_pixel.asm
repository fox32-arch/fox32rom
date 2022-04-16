; generic pixel drawing routines

; draw a pixel to a framebuffer
; inputs:
; r0: X coordinate
; r1: Y coordinate
; r2: color
; r3: pointer to framebuffer
; r4: framebuffer width (pixels)
; outputs:
; none
draw_pixel_generic:
    push r0
    push r1
    push r3
    push r4

    ; calculate pointer to the framebuffer
    mul r4, 4                ; 4 bytes per pixel
    mul r1, r4               ; y * width * 4
    mul r0, 4                ; x * 4
    add r0, r1               ; y * width * 4 + (x * 4)
    add r3, r0
    mov r0, r3               ; r0: pointer to framebuffer

    mov [r0], r2

    pop r4
    pop r3
    pop r1
    pop r0
    ret
