; disk booting routines
; these are only used during booting, they are not exposed via the jump table

; read disk 0 and attempt to figure out what type of disk it is, and load the correct binary into memory
; currently this only supports booting raw binaries
; inputs:
; r0: disk size (bytes)
; outputs:
; none (doesn't return)
start_boot_process:
    ; in the future, this will check the header for various different types of disk types
    ; but for now, just assume the user inserted a raw binary
    ; load it to 0x00000800 (immediately after the interrupt vectors) and jump

    ; r0 contains the size of the disk in bytes
    ; divide the size by 512 and add 1 to get the size in sectors
    div r0, 512
    inc r0

    mov r31, r0
    mov r0, 0          ; sector counter
    mov r2, 0x00000800 ; destination pointer
    mov r3, 0x80003000 ; command to read a sector from disk 0 into the sector buffer
    mov r4, 0x80002000 ; command to read a byte from the sector buffer
start_boot_process_sector_loop:
    out r3, r0         ; read the current sector into the sector buffer
    mov r1, 0          ; byte counter
start_boot_process_byte_loop:
    mov r5, r4
    or r5, r1          ; or the byte read command with the current byte counter
    in r5, r5          ; read the current byte into r5
    mov.8 [r2], r5     ; write the byte
    inc r2             ; increment the destination pointer
    inc r1             ; increment the byte counter
    cmp r1, 512
    ifnz jmp start_boot_process_byte_loop
    loop start_boot_process_sector_loop

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
    mov r0, 0xFF000000
    call fill_background

    ; disable the menu bar
    mov r0, 0x8000031E
    out r0, 0

    ret