; disk booting routines
; these are only used during booting, they are not exposed via the jump table

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
    mov r0, 0          ; sector counter
    mov r2, 0x00000800 ; destination pointer
    mov r3, 0x80003000 ; command to read a sector from disk 0 into memory
    mov r4, 0x80002000 ; command to set the location of the buffer

    ; first, check to see if this is a FAT-formatted disk
    out r4, r2         ; set the memory buffer location
    out r3, 0          ; read sector 0 into the buffer
    cmp.8 [r2], 0xEB   ; check for an x86 jmp instruction, indicating a possible FAT volume
    ifz jmp start_boot_process_fat
    cmp.8 [r2], 0xE9   ; check for an x86 jmp instruction, indicating a possible FAT volume
    ifz jmp start_boot_process_fat
start_boot_process_raw_binary_sector_loop:
    out r4, r2         ; set the memory buffer location
    out r3, r0         ; read the current sector into memory
    inc r0             ; increment sector counter
    add r2, 512        ; increment the destination pointer
    loop start_boot_process_raw_binary_sector_loop
    jmp start_boot_process_done
start_boot_process_fat:
    ;
start_boot_process_done:
    ; done loading !!!
    ; now clean up and jump to the loaded binary
    call boot_cleanup
    jmp 0x00000800

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
    mov r0, 0x8000031E
    out r0, 0

    ret