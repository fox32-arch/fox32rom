    ; entry point
    ; fox32 starts here on reset
    org 0xF0000000

const FOX32ROM_VERSION_MAJOR: 0
const FOX32ROM_VERSION_MINOR: 10
const FOX32ROM_VERSION_PATCH: 0

const FOX32ROM_API_VERSION: 4

const BACKGROUND_COLOR: 0xFF674764
const TEXT_COLOR:       0xFFFFFFFF

    ; initialization code
entry:
    ; disable interrupts and the MMU
    icl
    mcl

    ; disable all audio channels
    mov r0, 0x80000605
    mov r31, 8
audio_disable_loop:
    out r0, 0
    add r0, 0x10
    loop audio_disable_loop

    ; disable all overlays
    mov r0, 0x80000300
    mov r31, 0x1F
disable_all_overlays_loop:
    out r0, 0
    inc r0
    loop disable_all_overlays_loop

    ; find top of memory
    mov rsp, 0x00001000
    mov [0x00000408], memory_top_ex
    mov [0x0000040C], memory_top_ex
    mov r0, 0
    mov r1, 0xDEADBEEF
memory_top_loop:
    mov [r0], r1
    cmp [r0], r1
    ifnz jmp memory_top_ex
    not r1
    add r0, 0x0100
    jmp memory_top_loop
memory_top_ex:
    sub r0, 0x0100
    mov [RAM_SIZE], r0
    mov [RESERVED_START], r0

    ; initialize reserved memory
    mov rsp, 0x00001000
    mov r0, data_table
    call reserve_space_from_table

    ; if total memory is greater than 8 MiB, reserve space for the ramdisk
    cmp [RAM_SIZE], 0x00800000
    ifgt mov r0, data_table_ramdisk
    ifgt call reserve_space_from_table

    ; set the default font
    mov r0, standard_font
    call set_font

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

    ; stack starts right below reserved memory
    mov rsp, [RESERVED_START]

    ; poke two `nop.8`s and a `brk` at address 0 to catch jmps/calls to 0.
    ;   there is currently a known issue with certain fox32os programs (Fetcher in particular?) where any
    ;   32-bit value other than 0 at address 0 will cause strange issues. the cause of this is currently unknown.
    mov [0x00000000], 0x00000000
    mov.16 [0x00000004], 0xA000

    ; ensure any previous user monitor commands are invalidated
    mov [MONITOR_USER_CMD_PTR], 0x00000000 ; (addr 0 doesn't contain "CMD",0)

    ; set the interrupt vector for interrupt 0xFF - vsync
    mov [0x000003FC], system_vsync_handler

    ; set the exception vector for exception 0x00 - divide by zero
    mov [0x00000400], system_div_zero_handler

    ; set the exception vector for exception 0x01 - invalid opcode
    mov [0x00000404], system_invalid_op_handler

    ; set the exception vector for exception 0x02 - bus error (read)
    mov [0x00000408], system_bus_error_handler

    ; set the exception vector for exception 0x03 - bus error (write)
    mov [0x0000040C], system_bus_error_handler

    ; set the exception vector for exception 0x04 - breakpoint
    mov [0x00000410], system_breakpoint_handler

    ; ensure the event queue gets initialized properly
    mov [EVENT_QUEUE_POINTER], 0

    ; initialize the monitor X and Y coordinates
    mov.8 [MONITOR_CONSOLE_X], 0
    mov.8 [MONITOR_CONSOLE_Y], 28
    ; initialize the breakpoint table
    call monitor_breakpoint_init
    ; clear the console text buffer
    call clear_monitor_console

    ; enable interrupts
    ise

    call enable_cursor

    mov r0, BACKGROUND_COLOR
    call fill_background

    mov r0, bottom_bar_str
    mov r1, 16
    mov r2, 464
    mov r3, TEXT_COLOR
    mov r4, BACKGROUND_COLOR
    mov r10, FOX32ROM_VERSION_MAJOR
    mov r11, FOX32ROM_VERSION_MINOR
    mov r12, FOX32ROM_VERSION_PATCH
    call draw_format_str_to_background

    ; if the ramdisk memory wasn't reserved, don't format
    cmp [RAMDISK_START], 0
    ifz jmp event_loop
    ; otherwise, format if not already formatted
    call is_ramdisk_formatted
    ifnz mov r0, 5
    ifnz mov r1, RAMDISK_SIZE_SECTORS
    ifnz mov r2, ramdisk_name
    ifnz call ryfs_format

event_loop:
    call get_next_event

    ; no event handling here

    ; check if a bootable disk is inserted
    mov r31, 4
    mov r1, 0x80001000
check_boot:
    in r0, r1
    inc r1
    cmp r0, 0
    ifz loop check_boot
    mov r0, r1
    dec r0
    and r0, 0xFF
    push r1
    call start_boot_process
    pop r1
    cmp r31, 0
    ifnz loop check_boot
    call is_romdisk_available
    push r1
    ifz mov r0, 4
    ifz call start_boot_process
    call is_ramdisk_formatted
    ifz mov r0, 5
    ifz call start_boot_process
    pop r1

    mov r0, bottom_bar_str_no_disk
    mov r1, 16
    mov r2, 464
    mov r3, TEXT_COLOR
    mov r4, BACKGROUND_COLOR
    mov r10, FOX32ROM_VERSION_MAJOR
    mov r11, FOX32ROM_VERSION_MINOR
    mov r12, FOX32ROM_VERSION_PATCH
    call draw_format_str_to_background

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

    #include "background.asm"
    #include "boot.asm"
    #include "cursor.asm"
    #include "data.asm"
    #include "debug.asm"
    #include "disk.asm"
    #include "draw_pixel.asm"
    #include "draw_rectangle.asm"
    #include "draw_text.asm"
    #include "draw_tile.asm"
    #include "event.asm"
    #include "exception.asm"
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
    #include "string.asm"
    #include "vsync.asm"

    #include "okameron.asm"

    org.pad 0xF000F000
romdisk_image:
    #include_bin_optional "romdisk.img"
romdisk_image_end:

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
    data.32 print_string_to_monitor
    data.32 print_character_to_monitor
    data.32 print_hex_byte_to_monitor
    data.32 print_hex_word_to_monitor

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
    data.32 set_font

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
    data.32 ryfs_create
    data.32 ryfs_delete
    data.32 ryfs_format
    data.32 is_ramdisk_formatted
    data.32 ryfs_get_dir_name
    data.32 ryfs_get_parent_dir
    data.32 ryfs_create_dir

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
    ; TODO: updated audio code

    ; random number jump table
    org.pad 0xF0049000
    data.32 random
    data.32 random_range

    org.pad 0xF004F000
standard_font:
standard_font_width:
    data.16 8
standard_font_height:
    data.16 16
standard_font_data:
    #include_bin "font/unifont-thin.raw"

mouse_cursor:
    #include_bin "font/cursor2.raw"

const CURSOR_WIDTH:  8
const CURSOR_HEIGHT: 12

const MENU_BAR_WIDTH:  640
const MENU_BAR_HEIGHT: 16

ramdisk_name: data.strz "ramdisk"

bottom_bar_str: data.strz "fox32 - ROM version %u.%u.%u - F12 for monitor"
bottom_bar_str_no_disk: data.strz "fox32 - ROM version %u.%u.%u - no bootable disk found - F12 for monitor"

    ; pad out to 512 KiB
    org.pad 0xF0080000
