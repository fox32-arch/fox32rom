; data that needs to exist in ram

const MONITOR_USER_CMD_PTR:          0x00000008 ; 4 bytes (points to "CMD",0,<command table (see commands.asm)>)
const FONT_PTR:                      0x0000000C ; 4 bytes, actual address
const MENU_BAR_FRAMEBUFFER_PTR:      0x00000010 ; 4 bytes (pointer to 640x16x4)
const MENU_FRAMEBUFFER:              0x00000014 ; 4 bytes (pointer to 640x480x4)
const MONITOR_FRAMEBUFFER_PTR:       0x00000014 ; reuses menu framebuffer
const MENU_WIDTH:                    0x00000018 ; 2 bytes, actual address
const MENU_HEIGHT:                   0x0000001A ; 2 bytes, actual address
const MENU_POSITION_X:               0x0000001C ; 2 bytes, actual address
const MENU_POSITION_Y:               0x0000001E ; 2 bytes, actual address
const CURSOR_FRAMEBUFFER_PTR:        0x00000020 ; 4 bytes (pointer to 8x12x4)
const RAM_SIZE:                      0x00000024 ; 4 bytes (ram size in bytes)
const RESERVED_START:                0x00000028 ; 4 bytes (contains address of start of reserved memory)
const EVENT_TEMP:                    0x0000002C ; 4 bytes (pointer to EVENT_SIZE bytes of temp event data)
const EVENT_QUEUE_POINTER:           0x00000030 ; 4 bytes, actual address
const EVENT_QUEUE_BOTTOM:            0x00000034 ; 4 bytes (pointer to 32*64)
const RAMDISK_START:                 0x00000038 ; 4 bytes (pointer to RAMDISK_SIZE_BYTES bytes)
const TEMP_SECTOR_BUF:               0x0000003C ; 512 bytes, actual address
const MONITOR_SHELL_TEXT_BUF_BOTTOM: 0x00000240 ; 32 bytes, actual address
const MONITOR_SHELL_TEXT_BUF_TOP:    0x00000260 ; actual address
const MONITOR_SHELL_TEXT_BUF_PTR:    0x00000264 ; 4 bytes (pointer to current input character)
const MONITOR_SHELL_ARGS_PTR:        0x00000268 ; 4 bytes (pointer to the beginning of command arguments)
const MONITOR_CONSOLE_X:             0x0000026C ; 1 byte, actual address
const MONITOR_CONSOLE_Y:             0x0000026D ; 1 byte, actual address
const MONITOR_CONSOLE_TEXT_BUF_PTR:  0x00000270 ; 4 bytes (pointer to 2320 bytes (80x29))
const MONITOR_BREAKPOINT_TABLE:      0x00000274 ; 128 bytes, actual address (contains the addresses of breakpoints)
const MONITOR_SAVED_INSTR_TABLE:     0x000002F4 ; 64 bytes, actual address
const MODIFIER_BITMAP:               0x00000334 ; 1 byte, actual address (contains keyboard modifiers)
const MONITOR_OLD_RSP:               0x00000338 ; 4 bytes, actual address
const MONITOR_OLD_VSYNC_HANDLER:     0x0000033C ; 4 bytes, actual address
const TILEMAP_POINTER:               0x00000340 ; 4 bytes, actual address
const TILEMAP_WIDTH:                 0x00000344 ; 4 bytes, actual address
const TILEMAP_HEIGHT:                0x00000348 ; 4 bytes, actual address
const RANDOM_STATE:                  0x0000034C ; 4 bytes, actual address
const WARMBOOT_STATE:                0x00000350 ; 4 bytes, actual address ("warm" in little endian if memory already initialized)

data_table:
    ; data.32 <address> data.32 <size of data it points to>
    data.32 MENU_BAR_FRAMEBUFFER_PTR     data.32 0x0000A000
    data.32 MENU_FRAMEBUFFER             data.32 0x0012C000
    data.32 CURSOR_FRAMEBUFFER_PTR       data.32 0x00000180
    data.32 EVENT_TEMP                   data.32 EVENT_SIZE
    data.32 EVENT_QUEUE_BOTTOM           data.32 0x00000800
    data.32 MONITOR_CONSOLE_TEXT_BUF_PTR data.32 2320
    data.32 0 data.32 0

data_table_ramdisk:
    data.32 RAMDISK_START                data.32 RAMDISK_SIZE_BYTES
    data.32 0 data.32 0

; reserve memory needed for fox32rom from a table of pointers
; inputs:
; r0: pointer to table
reserve_space_from_table:
    push r0
    push r1
    push r2

    mov r2, r0
reserve_space_from_table_loop:
    mov r0, [r2+4]
    mov r1, [r2]
    call reserve_space
    inc r2, 8
    cmp [r2], 0
    ifnz jmp reserve_space_from_table_loop

    pop r2
    pop r1
    pop r0
    ret

; return a block of memory to use for writable storage
; inputs:
; r0: size in bytes
; r1: address to store final pointer in
reserve_space:
    push r3

    mov r3, [RESERVED_START]
    sub r3, r0
    sub r3, 16 ; 16 byte buffer between blocks
    mov [RESERVED_START], r3
    mov [r1], r3

    pop r3
    ret
