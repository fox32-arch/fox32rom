; debug monitor console routines

; print a string to the monitor
; inputs:
; r0: pointer to null-terminated string
; outputs:
print_string_to_monitor:
    push r0
    push r3
    mov r3, r0
print_string_to_monitor_loop:
    movz.8 r0, [r3]
    call print_character_to_monitor
    inc r3
    cmp.8 [r3], 0x00
    ifnz jmp print_string_to_monitor_loop
    call redraw_monitor_console_line
    pop r3
    pop r0
    ret

; print a single character to the monitor
; inputs:
; r0: character
; outputs:
; none
print_character_to_monitor:
    push r0
    push r1
    push r2

    cmp.8 r0, 0     ; null
    ifz jmp print_character_to_monitor_end
    cmp.8 r0, 8     ; backspace
    ifz jmp print_character_to_monitor_bs
    cmp.8 r0, 10    ; line feed
    ifz jmp print_character_to_monitor_lf
    cmp.8 r0, 13    ; carriage return
    ifz jmp print_character_to_monitor_cr

    ; check if we are at the end of this line
    cmp.8 [MONITOR_CONSOLE_X], MONITOR_CONSOLE_X_SIZE
    ; if so, increment to the next line
    ifgteq mov.8 [MONITOR_CONSOLE_X], 0
    ifgteq inc.8 [MONITOR_CONSOLE_Y]

    ; check if we need to scroll the display
    cmp.8 [MONITOR_CONSOLE_Y], MONITOR_CONSOLE_Y_SIZE
    ifgteq call scroll_monitor_console

    ; calculate coords for character...
    movz.8 r1, [MONITOR_CONSOLE_X]
    movz.8 r2, [MONITOR_CONSOLE_Y]
    mul r2, MONITOR_CONSOLE_X_SIZE
    add r1, r2
    add r1, MONITOR_CONSOLE_TEXT_BUF

    ; ...and print!!
    mov.8 [r1], r0
    inc.8 [MONITOR_CONSOLE_X]
    jmp print_character_to_monitor_end
print_character_to_monitor_cr:
    ; return to the beginning of the line
    mov.8 [MONITOR_CONSOLE_X], 0
    call redraw_monitor_console
    jmp print_character_to_monitor_end
print_character_to_monitor_lf:
    ; return to the beginning of the line and increment the line
    mov.8 [MONITOR_CONSOLE_X], 0
    inc.8 [MONITOR_CONSOLE_Y]
    ; scroll the display if needed
    cmp.8 [MONITOR_CONSOLE_Y], MONITOR_CONSOLE_Y_SIZE
    ifgteq call scroll_monitor_console
    call redraw_monitor_console
    jmp print_character_to_monitor_end
print_character_to_monitor_bs:
    ; go back one character
    cmp.8 [MONITOR_CONSOLE_X], 0
    ifnz dec.8 [MONITOR_CONSOLE_X]
print_character_to_monitor_end:
    pop r2
    pop r1
    pop r0
    ret

; scroll the console
; inputs:
; none
; outputs:
; none
; FIXME: this shouldnt have hard coded values
;        also this is extremely slow and bad
scroll_monitor_console:
    push r0
    push r1
    push r2
    push r31

    ; source
    mov r0, MONITOR_CONSOLE_TEXT_BUF
    add r0, MONITOR_CONSOLE_X_SIZE

    ; destination
    mov r1, MONITOR_CONSOLE_TEXT_BUF

    ; size
    mov r2, MONITOR_CONSOLE_X_SIZE
    mul r2, 28

    call copy_memory_bytes

    mov.8 [MONITOR_CONSOLE_X], 0
    mov.8 [MONITOR_CONSOLE_Y], 28

    ; clear the last line
    mov r0, MONITOR_CONSOLE_TEXT_BUF
    add r0, 2240 ; 80 * 28
    mov r31, MONITOR_CONSOLE_X_SIZE
scroll_monitor_console_clear_loop:
    mov.8 [r0], 0
    inc r0
    loop scroll_monitor_console_clear_loop

    ; redraw the screen
    call redraw_monitor_console

    pop r31
    pop r2
    pop r1
    pop r0
    ret

; redraw the whole console
; inputs:
; none
; outputs:
; none
redraw_monitor_console:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r31

    mov r0, MONITOR_CONSOLE_TEXT_BUF
    mov r1, 0
    mov r2, 16
    mov r3, TEXT_COLOR
    mov r4, MONITOR_BACKGROUND_COLOR
    mov r5, 31
    mov r31, MONITOR_CONSOLE_Y_SIZE
redraw_monitor_console_loop_y:
    push r31
    mov r1, 0
    mov r31, MONITOR_CONSOLE_X_SIZE
redraw_monitor_console_loop_x:
    push r0
    movz.8 r0, [r0]
    call draw_font_tile_to_overlay
    movz.8 r0, [standard_font_width]
    add r1, r0
    pop r0
    inc r0
    loop redraw_monitor_console_loop_x
    pop r31
    movz.8 r6, [standard_font_height]
    add r2, r6
    loop redraw_monitor_console_loop_y

    pop r31
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret

; redraw only the current line
; inputs:
; none
; outputs:
; none
redraw_monitor_console_line:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r31

    movz.8 r0, [MONITOR_CONSOLE_Y]
    mul r0, MONITOR_CONSOLE_X_SIZE
    add r0, MONITOR_CONSOLE_TEXT_BUF

    movz.8 r1, [MONITOR_CONSOLE_Y]
    mov r2, 16
    mul r2, r1
    add r2, 16

    mov r1, 0
    mov r3, TEXT_COLOR
    mov r4, MONITOR_BACKGROUND_COLOR
    mov r5, 31

    mov r1, 0
    mov r31, MONITOR_CONSOLE_X_SIZE
redraw_monitor_console_line_loop_x:
    push r0
    movz.8 r0, [r0]
    call draw_font_tile_to_overlay
    movz.8 r0, [standard_font_width]
    add r1, r0
    pop r0
    inc r0
    loop redraw_monitor_console_line_loop_x

    pop r31
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret

const MONITOR_CONSOLE_X:        0x03ED3FDB ; 1 byte
const MONITOR_CONSOLE_Y:        0x03ED3FDA ; 1 byte
const MONITOR_CONSOLE_TEXT_BUF: 0x03ED36CA ; 2320 bytes (80x29)
const MONITOR_CONSOLE_X_SIZE:   80
const MONITOR_CONSOLE_Y_SIZE:   29
