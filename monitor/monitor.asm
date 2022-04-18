; debug monitor

invoke_monitor:
    ; set the vsync handler to our own and reenable interrupts
    ; TODO: save the old vsync handler for when the monitor exits!!!
    mov [0x000003FC], monitor_vsync_handler
    ise

    ; set text buffer poinrer to the start of the text buffer
    mov [MONITOR_TEXT_BUF_PTR], MONITOR_TEXT_BUF_BOTTOM

    ; set the X and Y coords of the console text
    mov.8 [MONITOR_CONSOLE_X], 0
    mov.8 [MONITOR_CONSOLE_Y], MONITOR_CONSOLE_Y_SIZE
    dec.8 [MONITOR_CONSOLE_Y]

    ; set properties of overlay 31
    mov r0, 0x8000001F ; overlay 31: position
    mov.16 r1, MONITOR_POSITION_Y
    sla r1, 16
    mov.16 r1, MONITOR_POSITION_X
    out r0, r1
    mov r0, 0x8000011F ; overlay 31: size
    mov.16 r1, MONITOR_HEIGHT
    sla r1, 16
    mov.16 r1, MONITOR_WIDTH
    out r0, r1
    mov r0, 0x8000021F ; overlay 31: framebuffer pointer
    mov r1, MONITOR_FRAMEBUFFER_PTR
    out r0, r1

    mov r0, MONITOR_BACKGROUND_COLOR
    mov r1, 31
    call fill_overlay

    mov r0, info_str
    mov r1, 256
    mov r2, 0
    mov r3, TEXT_COLOR
    mov r4, 0x00000000
    mov r5, 31
    call draw_str_to_overlay

    mov r0, 0
    mov r1, 15
    mov r2, 640
    mov r3, 1
    mov r4, TEXT_COLOR
    mov r5, 31
    call draw_filled_rectangle_to_overlay

monitor_event_loop:
    call get_next_event

    ; was a key pressed?
    cmp r0, EVENT_TYPE_KEY_DOWN
    ifz call key_down_event

    jmp monitor_event_loop

key_down_event:
    mov r0, r1
    call scancode_to_ascii
    mov r1, TEXT_COLOR
    mov r2, 0x00000000
    call print_character_to_monitor
    call redraw_monitor_console_line
    ret

info_str: data.str "fox32rom monitor" data.8 0x00

    #include "monitor/console.asm"
    #include "monitor/keyboard.asm"
    #include "monitor/vsync.asm"

const MONITOR_TEXT_BUF_BOTTOM: 0x03ED3FE0 ; 32 characters
const MONITOR_TEXT_BUF_PTR:    0x03ED3FDC ; 4 bytes

const MONITOR_BACKGROUND_COLOR: 0xFF282828

const MONITOR_WIDTH:           640
const MONITOR_HEIGHT:          480
const MONITOR_POSITION_X:      0
const MONITOR_POSITION_Y:      0
const MONITOR_FRAMEBUFFER_PTR: 0x03ED4000
