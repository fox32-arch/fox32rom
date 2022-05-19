; disk booting routines
; these are only used during booting, they are not exposed via the jump table

const KERNEL_FILE_STRUCT: 0x01FFF800 ; kernel.bin file struct is right above the system stack
kernel_file_name: data.str "system  bin" data.8 0

; read disk 0 and attempt to figure out what type of disk it is, and load the correct binary into memory
; inputs:
; r0: disk size (bytes)
; outputs:
; none (doesn't return)
start_boot_process:
    ; r0 contains the size of the disk in bytes
    ; divide the size by 512 and add 1 to get the size in sectors
    div r0, 512
    inc r0
    mov r31, r0

    mov r0, BACKGROUND_COLOR
    call fill_background
draw_boot_text:
    mov r0, boot_str
    mov r1, 16
    mov r2, 464
    mov r3, TEXT_COLOR
    mov r4, 0x00000000
    mov r10, FOX32ROM_VERSION_MAJOR
    mov r11, FOX32ROM_VERSION_MINOR
    mov r12, FOX32ROM_VERSION_PATCH
    call draw_format_str_to_background

    mov r0, 0          ; sector counter
    mov r2, 0x00000800 ; destination pointer
    mov r3, 0x80003000 ; command to read a sector from disk 0 into memory
    mov r4, 0x80002000 ; command to set the location of the buffer

    ; first, check to see if this is a FAT-formatted disk or RYFS-formatted disk
    out r4, r2         ; set the memory buffer location
    out r3, 0          ; read sector 0 into the buffer
    cmp.8 [r2], 0xEB   ; check for an x86 jmp instruction, indicating a possible FAT volume
    ifz jmp start_boot_process_fat
    cmp.8 [r2], 0xE9   ; check for an x86 jmp instruction, indicating a possible FAT volume
    ifz jmp start_boot_process_fat
    out r3, 1          ; read sector 1 into the buffer
    add r2, 2
    cmp.16 [r2], 0x5952 ; check for RYFS magic bytes
    ifz jmp start_boot_process_ryfs
    sub r2, 2
start_boot_process_raw_binary_sector_loop:
    out r4, r2         ; set the memory buffer location
    out r3, r0         ; read the current sector into memory
    inc r0             ; increment sector counter
    add r2, 512        ; increment the destination pointer
    loop start_boot_process_raw_binary_sector_loop
    jmp start_boot_process_done
start_boot_process_fat:
    jmp start_boot_process_fat
start_boot_process_ryfs:
    ; open kernel.bin
    mov r0, kernel_file_name
    mov r1, 0
    mov r2, KERNEL_FILE_STRUCT
    call ryfs_open
    cmp r0, 0
    ifz jmp start_boot_process_error

    mov r0, KERNEL_FILE_STRUCT
    mov r1, 0x00000800
    call ryfs_read_whole_file
start_boot_process_done:
    ; done loading !!!
    ; now clean up and jump to the loaded binary
    call boot_cleanup
    jmp 0x00000800
start_boot_process_error:
    mov r0, BACKGROUND_COLOR
    call fill_background

    mov r0, boot_error_str
    mov r1, 16
    mov r2, 464
    mov r3, TEXT_COLOR
    mov r4, 0x00000000
    mov r10, FOX32ROM_VERSION_MAJOR
    mov r11, FOX32ROM_VERSION_MINOR
    mov r12, FOX32ROM_VERSION_PATCH
    call draw_format_str_to_background

    ret

; clean up the system's state before jumping to the loaded binary
; inputs:
; none
; outputs:
; none
boot_cleanup:
    ; clear the background
    mov r0, BACKGROUND_COLOR
    call fill_background

    ; disable the menu bar
    call disable_menu_bar

    ret
