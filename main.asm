    ; entry point
    ; fox32 starts here on reset
    org 0xF0000000

const FOX32ROM_VERSION_MAJOR: 0
const FOX32ROM_VERSION_MINOR: 3
const FOX32ROM_VERSION_PATCH: 1

const SYSTEM_STACK:     0x01FFF800
const BACKGROUND_COLOR: 0xFF674764
const TEXT_COLOR:       0xFFFFFFFF

    ; initialization code
entry:
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

    ; set the stach pointer again to pop the return address and flags off the stack
    mov rsp, SYSTEM_STACK

    ; set the interrupt vector for interrupt 0xFF - vsync
    mov [0x000003FC], system_vsync_handler
    ise

    ; clear the interrupt vector for interrupt 0xFE - audio buffer switch
    mov [0x000003F8], 0x00000000

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

    call enable_menu_bar
    call clear_menu_bar
    mov r0, menu_items_root
    mov r1, 0xFFFFFFFF
    call draw_menu_bar_root_items

draw_startup_text:
    mov r0, startup_str
    mov r1, 16
    mov r2, 464
    mov r3, TEXT_COLOR
    mov r4, 0x00000000
    mov r10, FOX32ROM_VERSION_MAJOR
    mov r11, FOX32ROM_VERSION_MINOR
    mov r12, FOX32ROM_VERSION_PATCH
    call draw_format_str_to_background

event_loop:
    call get_next_event

    ; was the mouse clicked?
    cmp r0, EVENT_TYPE_MOUSE_CLICK
    ;ifz call mouse_click_event

    ; was the mouse released?
    cmp r0, EVENT_TYPE_MOUSE_RELEASE
    ;ifz call mouse_release_event

    ; did the user click the menu bar?
    cmp r0, EVENT_TYPE_MENU_BAR_CLICK
    ifz mov r0, menu_items_root
    ifz call menu_bar_click_event

    ; is the user in a menu?
    cmp r0, EVENT_TYPE_MENU_UPDATE
    ifz call menu_update_event

    ; did the user click a menu item?
    cmp r0, EVENT_TYPE_MENU_CLICK
    ifz call menu_click_event

    ; check if a disk is inserted as disk 0
    ; if port 0x8000100n returns a non-zero value, then a disk is inserted as disk n
    in r0, 0x80001000
    cmp r0, 0
    ifnz call start_boot_process

    jmp event_loop

menu_click_event:
    ; r3 contains the clicked menu item

    ; insert disk
    cmp r3, 0
    ifz jmp insert_boot_disk

    ; shutdown
    cmp r3, 1
    ifz icl
    ifz halt

    ret

insert_boot_disk:
    mov r0, 0x80001000
    out r0, 0
    ret

get_rom_version:
    mov r0, FOX32ROM_VERSION_MAJOR
    mov r1, FOX32ROM_VERSION_MINOR
    mov r2, FOX32ROM_VERSION_PATCH
    ret

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

startup_str: data.str "fox32 - ROM version %u.%u.%u - insert boot disk - F12 for monitor" data.8 0
boot_str: data.str "fox32 - ROM version %u.%u.%u - booting..." data.8 0
boot_error_str: data.str "fox32 - ROM version %u.%u.%u - system.bin not found! - F12 for monitor" data.8 0

menu_items_root:
    data.8 1                                                      ; number of menus
    data.32 menu_items_system_list data.32 menu_items_system_name ; pointer to menu list, pointer to menu name
menu_items_system_name:
    data.8 6 data.str "System" data.8 0x00       ; text length, text, null-terminator
menu_items_system_list:
    data.8 2                                     ; number of items
    data.8 13                                    ; menu width (usually longest item + 2)
    data.8 11 data.str "Insert Disk" data.8 0x00 ; text length, text, null-terminator
    data.8 9  data.str "Shut Down"   data.8 0x00 ; text length, text, null-terminator

    ; pad out to 512 KiB
    org.pad 0xF0080000
