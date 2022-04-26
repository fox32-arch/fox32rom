; mouse cursor routines

enable_cursor:
    push r0
    push r1
    push r31

    ; write the cursor bitmap to the overlay framebuffer
    mov r0, CURSOR_FRAMEBUFFER_PTR
    mov r1, mouse_cursor
    mov r31, 96 ; 8x12
enable_cursor_loop:
    mov [r0], [r1]
    add r0, 4
    add r1, 4
    loop enable_cursor_loop

    ; set properties of overlay 31
    mov r0, 0x8000011F ; overlay 31: size
    mov.16 r1, CURSOR_HEIGHT
    sla r1, 16
    mov.16 r1, CURSOR_WIDTH
    out r0, r1
    mov r0, 0x8000021F ; overlay 31: framebuffer pointer
    mov r1, CURSOR_FRAMEBUFFER_PTR
    out r0, r1

    ; enable overlay 31 (cursor)
    mov r0, 0x8000031F
    out r0, 1

    pop r31
    pop r1
    pop r0
    ret
