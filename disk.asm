; disk routines

const TEMP_SECTOR_BUF: 0x01FFF808

; read a sector into the specified memory buffer
; inputs:
; r0: sector number
; r1: disk ID
; r2: sector buffer (512 bytes)
; outputs:
; none
read_sector:
    cmp.8 r1, 4
    ifz jmp read_romdisk_sector

    push r3
    push r4

    mov r3, 0x80002000       ; command to set the location of the buffer
    mov r4, 0x80003000       ; command to read a sector from a disk into the buffer
    or.8 r4, r1              ; set the disk ID
    out r3, r2               ; set the memory buffer location
    out r4, r0               ; read the sector into memory

    pop r4
    pop r3
    ret

; read a sector from the romdisk into the specified memory buffer
; inputs:
; r0: sector number
; r2: sector buffer (512 bytes)
; outputs:
; none
read_romdisk_sector:
    push r0
    push r1
    push r2

    ; source pointer
    mul r0, 512
    add r0, romdisk_image

    ; destination pointer
    mov r1, r2

    ; copy 512 bytes
    mov r2, 512

    call copy_memory_bytes

    pop r2
    pop r1
    pop r0
    ret

; check if a RYFS image is included as a romdisk
; inputs:
; none
; outputs:
; Z flag: set if available, reset if not
is_romdisk_available:
    push r0

    mov r0, romdisk_image
    add r0, 514
    cmp.16 [r0], 0x5952

    pop r0
    ret

; write a sector from the specified memory buffer
; inputs:
; r0: sector number
; r1: disk ID
; r2: sector buffer (512 bytes)
; outputs:
; none
write_sector:
    cmp.8 r1, 4
    ifz ret

    push r3
    push r4

    mov r3, 0x80002000       ; command to set the location of the buffer
    mov r4, 0x80004000       ; command to write a sector to a disk from the buffer
    or.8 r4, r1              ; set the disk ID
    out r3, r2               ; set the memory buffer location
    out r4, r0               ; write the sector from memory

    pop r4
    pop r3
    ret
