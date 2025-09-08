; generic tile drawing routines

; set the current tilemap
; inputs:
; r0: pointer to tilemap data
; r1: tile width
; r2: tile height
; outputs:
; none
set_tilemap:
    mov [TILEMAP_POINTER], r0
    mov [TILEMAP_WIDTH], r1
    mov [TILEMAP_HEIGHT], r2

    ret

; get the current tilemap
; inputs:
; none
; outputs:
; r0: pointer to tilemap data
; r1: tile width
; r2: tile height
get_tilemap:
    mov r0, [TILEMAP_POINTER]
    mov r1, [TILEMAP_WIDTH]
    mov r2, [TILEMAP_HEIGHT]

    ret

; draw a single tile to a framebuffer
; inputs:
; r0: tile number
; r1: X coordinate
; r2: Y coordinate
; r8: pointer to framebuffer
; r9: framebuffer width (pixels)
; outputs:
; none
draw_tile_generic:
    push r0
    push r1
    push r2
    push r5
    push r6
    push r7
    push r8
    push r9

    ; calculate pointer to the tile data
    mov r6, [TILEMAP_WIDTH]
    mov r7, [TILEMAP_HEIGHT]
    push r6
    mul r6, r7
    mul r0, r6
    mul r0, 4                 ; 4 bytes per pixel
    add r0, [TILEMAP_POINTER] ; r0: pointer to tile data
    pop r6

    ; calculate pointer to the framebuffer
    mul r9, 4                ; 4 bytes per pixel
    mul r2, r9               ; y * width * 4
    mul r1, 4                ; x * 4
    add r1, r2               ; y * width * 4 + (x * 4)
    add r1, r8               ; r1: pointer to framebuffer

    ; r8: tile width in bytes
    mov r8, r6
    mul r8, 4

draw_tile_generic_y_loop:
    mov r5, r6               ; x counter
draw_tile_generic_x_loop:
    mov [r1], [r0]           ; draw pixel
    add r0, 4                ; increment tile pointer
    add r1, 4                ; increment framebuffer pointer
    dec r5
    ifnz jmp draw_tile_generic_x_loop ; loop if there are still more X pixels to draw
    sub r1, r8               ; return to the beginning of this line
    add r1, r9               ; increment to the next line by adding the framebuffer width in bytes
    dec r7                   ; decrement height counter
    ifnz jmp draw_tile_generic_y_loop ; loop if there are still more Y pixels to draw

    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r2
    pop r1
    pop r0
    ret
