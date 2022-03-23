    ; entry point
    ; fox32 starts here on reset
    org 0xF0000000

const FOX32ROM_VERSION_MAJOR: 0
const FOX32ROM_VERSION_MINOR: 1
const FOX32ROM_VERSION_PATCH: 0

const SYSTEM_STACK:     0x01FFF800
const BACKGROUND_COLOR: 0xFF674764
const TEXT_COLOR:       0xFFFFFFFF

    ; initialization code
entry:
    mov rsp, SYSTEM_STACK

    mov [0x000003FC], system_vsync_handler

    ; disable all overlays
    mov r31, 0x1F
    mov r0, 0x80000300
disable_all_overlays_loop:
    out r0, 0
    inc r0
    loop disable_all_overlays_loop

    ; write the cursor bitmap to the overlay framebuffer
    mov r0, [overlay_31_framebuffer_ptr]
    mov r1, mouse_cursor
    mov r31, 96 ; 8x12
cursor_overlay_loop:
    mov [r0], [r1]
    add r0, 4
    add r1, 4
    loop cursor_overlay_loop

cursor_enable:
    ; set properties of overlay 31
    mov r0, 0x8000011F ; overlay 31: size
    mov.16 r1, [overlay_31_height]
    sla r1, 16
    mov.16 r1, [overlay_31_width]
    out r0, r1
    mov r0, 0x8000021F ; overlay 31: framebuffer pointer
    mov r1, [overlay_31_framebuffer_ptr]
    out r0, r1

    ; enable overlay 31 (cursor)
    mov r0, 0x8000031F
    out r0, 1

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

    ise
event_loop:
    call get_next_event

    ; was the mouse clicked?
    cmp r0, MOUSE_CLICK_EVENT_TYPE
    ;ifz call mouse_click_event

    ; did the user click the menu bar?
    cmp r0, MENU_BAR_CLICK_EVENT_TYPE
    ifz mov r0, menu_items_root
    ifz call menu_bar_click_event

    ; is the user in a menu?
    cmp r0, MENU_UPDATE_EVENT_TYPE
    ifz call menu_update_event

    ; did the user click a menu item?
    cmp r0, MENU_CLICK_EVENT_TYPE
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
    #include "background.asm"
    #include "boot.asm"
    #include "debug.asm"
    #include "draw_rectangle.asm"
    #include "draw_text.asm"
    #include "event.asm"
    #include "memory.asm"
    #include "menu.asm"
    #include "menu_bar.asm"
    #include "mouse.asm"
    #include "overlay.asm"
    #include "panic.asm"
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
    data.32 draw_font_tile_generic
    data.32 draw_filled_rectangle_generic

    ; background jump table
    org.pad 0xF0042000
    data.32 fill_background
    data.32 draw_str_to_background
    data.32 draw_format_str_to_background
    data.32 draw_decimal_to_background
    data.32 draw_font_tile_to_background
    data.32 draw_filled_rectangle_to_background

    ; overlay jump table
    org.pad 0xF0043000
    data.32 fill_overlay
    data.32 draw_str_to_overlay
    data.32 draw_format_str_to_overlay
    data.32 draw_decimal_to_overlay
    data.32 draw_font_tile_to_overlay
    data.32 draw_filled_rectangle_to_overlay
    data.32 find_overlay_covering_position
    data.32 check_if_overlay_covers_position
    data.32 check_if_enabled_overlay_covers_position

    ; menu bar jump table
    org.pad 0xF0044000
    data.32 enable_menu_bar
    data.32 disable_menu_bar
    data.32 menu_bar_click_event
    data.32 clear_menu_bar
    data.32 draw_menu_bar_root_items
    data.32 draw_menu_items
    data.32 close_menu

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
overlay_31_width:           data.16 8
overlay_31_height:          data.16 12
overlay_31_position_x:      data.16 0
overlay_31_position_y:      data.16 0
overlay_31_framebuffer_ptr: data.32 0x0212D000

; menu bar overlay struct:
overlay_30_width:           data.16 640
overlay_30_height:          data.16 16
overlay_30_position_x:      data.16 0
overlay_30_position_y:      data.16 0
overlay_30_framebuffer_ptr: data.32 0x0212D180

; menu overlay struct:
; this struct must be writable, so these are hard-coded addresses in ram
const OVERLAY_29_WIDTH:           0x02137180 ; 2 bytes
const OVERLAY_29_HEIGHT:          0x02137182 ; 2 bytes
const OVERLAY_29_POSITION_X:      0x02137184 ; 2 bytes
const OVERLAY_29_POSITION_Y:      0x02137186 ; 2 bytes
const OVERLAY_29_FRAMEBUFFER_PTR: 0x0213718A ; 4 bytes
const OVERLAY_29_FRAMEBUFFER:     0x0213718E

startup_str: data.str "fox32 - ROM version %u.%u.%u - insert boot disk" data.8 0

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
