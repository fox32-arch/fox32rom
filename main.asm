    ; entry point
    ; fox32 starts here on reset
    org 0xF0000000

const FOX32ROM_VERSION_MAJOR: 0
const FOX32ROM_VERSION_MINOR: 7
const FOX32ROM_VERSION_PATCH: 0

const FOX32ROM_API_VERSION: 1

const SYSTEM_STACK:     0x01FFF800
const BACKGROUND_COLOR: 0xFF674764
const TEXT_COLOR:       0xFFFFFFFF

    ; initialization code
entry:
    ; disable the MMU
    mcl

    ; set the stack pointer
    mov rsp, SYSTEM_STACK

    ; disable audio playback
    mov r0, 0x80000600
    out r0, 0

    ; seed the random number generator
entry_seed:
    mov [0x000003FC], entry_seed_done
    ise
    mov r0, 2166136261
entry_seed_loop:
    mul r0, 16777619
    rjmp entry_seed_loop
entry_seed_done:
    mov [RANDOM_STATE], r0

    ; set the stack pointer again to pop the return address and flags off the stack
    mov rsp, SYSTEM_STACK

    ; set the interrupt vector for interrupt 0xFF - vsync
    mov [0x000003FC], system_vsync_handler

    ; set the exception vector for exception 0x00 - divide by zero
    mov [0x00000400], system_div_zero_handler

    ; set the exception vector for exception 0x01 - invalid opcode
    mov [0x00000404], system_invalid_op_handler

    ; set the exception vector for exception 0x02 - page fault read
    mov [0x00000408], system_page_fault_handler

    ; set the exception vector for exception 0x03 - page fault write
    mov [0x0000040C], system_page_fault_handler

    ; set the exception vector for exception 0x04 - breakpoint
    mov [0x00000410], system_breakpoint_handler

    ; ensure the event queue gets initialized properly
    mov [EVENT_QUEUE_POINTER], 0

    ; initialize the monitor X and Y coordinates
    mov.8 [MONITOR_CONSOLE_X], 0
    mov.8 [MONITOR_CONSOLE_Y], 28
    ; initialize the breakpoint table
    call monitor_breakpoint_init

    ; enable interrupts
    ise

    ; disable all overlays
    mov r31, 0x1F
    mov r0, 0x80000300
disable_all_overlays_loop:
    out r0, 0
    inc r0
    loop disable_all_overlays_loop

    call enable_cursor

    mov r0, BACKGROUND_COLOR
    call fill_background

    ; draw the bottom bar
    mov r0, bottom_bar_str_0
    mov r1, 8
    mov r2, 448
    mov r3, TEXT_COLOR
    mov r4, 0x00000000
    call draw_str_to_background
    mov r0, bottom_bar_patterns
    mov r1, 1
    mov r2, 16
    call set_tilemap
    mov r1, 0
    mov r2, 464
    mov r31, 640
draw_bottom_bar_loop:
    mov r4, r31
    rem r4, 2
    cmp r4, 0
    ifz mov r0, 0
    ifnz mov r0, 1
    call draw_tile_to_background
    inc r1
    loop draw_bottom_bar_loop
    mov r0, 10
    mov r1, 464
    mov r2, 20
    mov r3, 16
    mov r4, 0xFFFFFFFF
    call draw_filled_rectangle_to_background
    mov r0, bottom_bar_str_1
    mov r1, 12
    mov r2, 464
    mov r3, 0xFF000000
    mov r4, 0xFFFFFFFF
    call draw_str_to_background
    mov r0, bottom_bar_str_2
    mov r1, 480
    mov r2, 464
    mov r3, 0xFF000000
    mov r4, 0xFFFFFFFF
    mov r10, FOX32ROM_VERSION_MAJOR
    mov r11, FOX32ROM_VERSION_MINOR
    mov r12, FOX32ROM_VERSION_PATCH
    call draw_format_str_to_background

    mov r0, disk_icon_q
    call change_icon
    call setup_icon

event_loop:
    call get_next_event

    ; no event handling here

    ; check if a disk is inserted as disk 0
    ; if port 0x8000100n returns a non-zero value, then a disk is inserted as disk n
    in r0, 0x80001000
    cmp r0, 0
    ifnz call start_boot_process

    call is_romdisk_available
    ifz call start_boot_process_from_romdisk

    jmp event_loop

get_rom_version:
    mov r0, FOX32ROM_VERSION_MAJOR
    mov r1, FOX32ROM_VERSION_MINOR
    mov r2, FOX32ROM_VERSION_PATCH
    ret

get_rom_api_version:
    mov r0, FOX32ROM_API_VERSION
    ret

poweroff:
    mov r0, 0x80010000
    mov r1, 0
    out r0, r1
poweroff_wait:
    jmp poweroff_wait

    ; code
    #include "audio.asm"
    #include "background.asm"
    #include "boot.asm"
    #include "cursor.asm"
    #include "debug.asm"
    #include "disk.asm"
    #include "draw_pixel.asm"
    #include "draw_rectangle.asm"
    #include "draw_text.asm"
    #include "draw_tile.asm"
    #include "event.asm"
    #include "exception.asm"
    #include "icon.asm"
    #include "integer.asm"
    #include "keyboard.asm"
    #include "memory.asm"
    #include "menu.asm"
    #include "menu_bar.asm"
    #include "monitor/monitor.asm"
    #include "mouse.asm"
    #include "overlay.asm"
    #include "panic.asm"
    #include "random.asm"
    #include "ryfs.asm"
    #include "string.asm"
    #include "vsync.asm"


; TODO: convert these icons to 1 bit bitmaps and move
;       them down to the data section at 0xF004F000,
;       once 1 bit drawing routines are implemented
disk_icon:
    #include_bin "font/disk1.raw"
disk_icon_q:
    #include_bin "font/disk2.raw"


    ; data

    ; system jump table
    org.pad 0xF0040000
    data.32 get_rom_version
    data.32 system_vsync_handler
    data.32 get_mouse_position
    data.32 new_event
    data.32 wait_for_event
    data.32 get_next_event
    data.32 panic
    data.32 get_mouse_button
    data.32 scancode_to_ascii
    data.32 shift_pressed
    data.32 shift_released
    data.32 caps_pressed
    data.32 poweroff
    data.32 get_rom_api_version

    ; generic drawing jump table
    org.pad 0xF0041000
    data.32 draw_str_generic
    data.32 draw_format_str_generic
    data.32 draw_decimal_generic
    data.32 draw_hex_generic
    data.32 draw_font_tile_generic
    data.32 draw_tile_generic
    data.32 set_tilemap
    data.32 draw_pixel_generic
    data.32 draw_filled_rectangle_generic
    data.32 get_tilemap

    ; background jump table
    org.pad 0xF0042000
    data.32 fill_background
    data.32 draw_str_to_background
    data.32 draw_format_str_to_background
    data.32 draw_decimal_to_background
    data.32 draw_hex_to_background
    data.32 draw_font_tile_to_background
    data.32 draw_tile_to_background
    data.32 draw_pixel_to_background
    data.32 draw_filled_rectangle_to_background

    ; overlay jump table
    org.pad 0xF0043000
    data.32 fill_overlay
    data.32 draw_str_to_overlay
    data.32 draw_format_str_to_overlay
    data.32 draw_decimal_to_overlay
    data.32 draw_hex_to_overlay
    data.32 draw_font_tile_to_overlay
    data.32 draw_tile_to_overlay
    data.32 draw_pixel_to_overlay
    data.32 draw_filled_rectangle_to_overlay
    data.32 check_if_overlay_covers_position
    data.32 check_if_enabled_overlay_covers_position
    data.32 enable_overlay
    data.32 disable_overlay
    data.32 move_overlay
    data.32 resize_overlay
    data.32 set_overlay_framebuffer_pointer
    data.32 get_unused_overlay
    data.32 make_coordinates_relative_to_overlay

    ; menu bar jump table
    org.pad 0xF0044000
    data.32 enable_menu_bar
    data.32 disable_menu_bar
    data.32 menu_bar_click_event
    data.32 clear_menu_bar
    data.32 draw_menu_bar_root_items
    data.32 draw_menu_items
    data.32 close_menu
    data.32 menu_update_event

    ; disk jump table
    org.pad 0xF0045000
    data.32 read_sector
    data.32 write_sector
    data.32 ryfs_open
    data.32 ryfs_seek
    data.32 ryfs_read
    data.32 ryfs_read_whole_file
    data.32 ryfs_get_size
    data.32 ryfs_get_file_list
    data.32 ryfs_tell
    data.32 ryfs_write
    data.32 is_romdisk_available

    ; memory copy/compare jump table
    org.pad 0xF0046000
    data.32 copy_memory_bytes
    data.32 copy_memory_words
    data.32 copy_string
    data.32 compare_memory_bytes
    data.32 compare_memory_words
    data.32 compare_string
    data.32 string_length

    ; integer jump table
    org.pad 0xF0047000
    data.32 string_to_int

    ; audio jump table
    org.pad 0xF0048000
    data.32 play_audio
    data.32 stop_audio

    ; random number jump table
    org.pad 0xF0049000
    data.32 random
    data.32 random_range

    org.pad 0xF004F000
standard_font_width:
    data.16 8
standard_font_height:
    data.16 16
standard_font_data:
    #include_bin "font/unifont-thin.raw"

mouse_cursor:
    #include_bin "font/cursor2.raw"

; icon overlay struct:
const ICON_WIDTH:           32
const ICON_HEIGHT:          32
const ICON_POSITION_X:      304
const ICON_POSITION_Y:      224
const ICON_FRAMEBUFFER_PTR: 0x0212C000

; cursor overlay struct:
const CURSOR_WIDTH:           8
const CURSOR_HEIGHT:          12
const CURSOR_FRAMEBUFFER_PTR: 0x0214C000

; menu bar overlay struct:
const MENU_BAR_WIDTH:           640
const MENU_BAR_HEIGHT:          16
const MENU_BAR_POSITION_X:      0
const MENU_BAR_POSITION_Y:      0
const MENU_BAR_FRAMEBUFFER_PTR: 0x0214C180

; menu overlay struct:
; this struct must be writable, so these are hard-coded addresses in ram
const MENU_WIDTH:           0x02156180 ; 2 bytes
const MENU_HEIGHT:          0x02156182 ; 2 bytes
const MENU_POSITION_X:      0x02156184 ; 2 bytes
const MENU_POSITION_Y:      0x02156186 ; 2 bytes
const MENU_FRAMEBUFFER_PTR: 0x0215618A ; 4 bytes
const MENU_FRAMEBUFFER:     0x0215618E ; max 640x480x4 = end address at 0x0228218E

bottom_bar_str_0: data.strz "FOX"
bottom_bar_str_1: data.strz "32"
bottom_bar_str_2: data.strz " ROM version %u.%u.%u "
bottom_bar_patterns:
    ; 1x16 tile
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF

    ; 1x16 tile
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764
    data.32 0xFFFFFFFF
    data.32 0xFF674764

romdisk_image:
    #include_bin_optional "romdisk.img"
romdisk_image_end:

    ; pad out to 512 KiB
    org.pad 0xF0080000
