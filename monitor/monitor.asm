; debug monitor

; only call this from system_breakpoint_handler!
invoke_monitor:
    ; return if we're already in the monitor
    cmp [0x000003FC], monitor_vsync_handler
    ifz jmp invoke_monitor_aleady_in_monitor

    ; set the vsync handler to our own and reenable interrupts
    mov [MONITOR_OLD_VSYNC_HANDLER], [0x000003FC]
    mov [0x000003FC], monitor_vsync_handler
    ise

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

    call redraw_monitor_console

    mov [MONITOR_OLD_RSP], rsp
    call monitor_breakpoint_update
    jmp monitor_shell_start
exit_monitor:
    ; restore the old RSP and vsync handler, reset the cursor, and exit
    mov rsp, [MONITOR_OLD_RSP]
    mov [0x000003FC], [MONITOR_OLD_VSYNC_HANDLER]

    call enable_cursor

    ret

exit_monitor_and_jump:
    ; restore the old RSP and vsync handler
    mov rsp, [MONITOR_OLD_RSP]
    mov [0x000003FC], [MONITOR_OLD_VSYNC_HANDLER]

    ; reset the cursor
    call enable_cursor

    ; save the jump address in a temporary location
    mov [MONITOR_OLD_RSP], r0

    jmp [MONITOR_OLD_RSP]

invoke_monitor_aleady_in_monitor:
    call redraw_monitor_console
    ret

info_str: data.str "fox32rom monitor" data.8 0x00

    #include "monitor/breakpoint.asm"
    #include "monitor/commands/commands.asm"
    #include "monitor/console.asm"
    #include "monitor/keyboard.asm"
    #include "monitor/shell.asm"
    #include "monitor/vsync.asm"

const MONITOR_OLD_RSP:           0x03ED36BD ; 4 bytes
const MONITOR_OLD_VSYNC_HANDLER: 0x03ED36C1 ; 4 bytes

const MONITOR_BACKGROUND_COLOR: 0xFF000000

const MONITOR_WIDTH:           640
const MONITOR_HEIGHT:          480
const MONITOR_POSITION_X:      0
const MONITOR_POSITION_Y:      0
const MONITOR_FRAMEBUFFER_PTR: 0x03ED4000
