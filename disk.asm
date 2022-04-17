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

; wrtie a sector from the specified memory buffer
; inputs:
; r0: sector number
; r1: disk ID
; r2: sector buffer (512 bytes)
; outputs:
; none
write_sector:
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