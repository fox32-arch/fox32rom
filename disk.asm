; disk routines

const RAMDISK_SIZE_SECTORS: 16384 ; 1 MiB = 2048 sectors
const RAMDISK_SIZE_BYTES: 8388608 ; 8 MiB

system_disk_interrupt_handler:
    inc rsp, 4
    call [DISK_DATA_READY_CALLBACK]
    reti

; set the callback routine to call when waiting for data from a disk
; inputs:
; r0: pointer to routine
; outputs:
; none
set_disk_data_wait_callback:
    mov [DISK_DATA_WAIT_CALLBACK], r0
    ret

; set the callback routine to call when data from disk is fully read into memory
; inputs:
; r0: pointer to routine
; outputs:
; none
set_disk_data_ready_callback:
    mov [DISK_DATA_READY_CALLBACK], r0
    ret

; call [DISK_DATA_WAIT_CALLBACK], which should point to
; code which waits for [DISK_DATA_READY_CALLBACK] to be called
; inputs:
; none
; outputs:
; none
wait_sector:
    jmp [DISK_DATA_WAIT_CALLBACK]

; read a sector into the specified memory buffer
; NOTE: data is not fully read into memory until [DISK_DATA_READY_CALLBACK] is called
; inputs:
; r0: sector number
; r1: disk ID
; r2: sector buffer (512 bytes)
; outputs:
; none
read_sector:
    cmp.8 r1, 4
    ifz jmp read_romdisk_sector
    cmp.8 r1, 5
    ifz jmp read_ramdisk_sector

    push r3
    push r4

    mov.8 [DISK_DATA_WAIT_STATE], 0

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
    call [DISK_DATA_READY_CALLBACK]

    pop r2
    pop r1
    pop r0
    ret

; read a sector from the ramdisk into the specified memory buffer
; inputs:
; r0: sector number
; r2: sector buffer (512 bytes)
; outputs:
; none
read_ramdisk_sector:
    push r0
    push r1
    push r2

    ; source pointer
    mul r0, 512
    add r0, [RAMDISK_START]

    ; destination pointer
    mov r1, r2

    ; copy 512 bytes
    mov r2, 512

    call copy_memory_bytes
    call [DISK_DATA_READY_CALLBACK]

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

; check if a RYFS filesystem is initialized on the ramdisk
; inputs:
; none
; outputs:
; Z flag: set if available, reset if not
is_ramdisk_formatted:
    push r0

    mov r0, [RAMDISK_START]
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
    cmp.8 r1, 5
    ifz jmp write_ramdisk_sector

    push r3
    push r4

    mov.8 [DISK_DATA_WAIT_STATE], 0

    mov r3, 0x80002000       ; command to set the location of the buffer
    mov r4, 0x80004000       ; command to write a sector to a disk from the buffer
    or.8 r4, r1              ; set the disk ID
    out r3, r2               ; set the memory buffer location
    out r4, r0               ; write the sector from memory

    pop r4
    pop r3
    ret

; write a sector to ramdisk from the specified memory buffer
; inputs:
; r0: sector number
; r2: sector buffer (512 bytes)
; outputs:
; none
write_ramdisk_sector:
    push r0
    push r1
    push r2

    ; destination pointer
    mov r1, r0
    mul r1, 512
    add r1, [RAMDISK_START]

    ; source pointer
    mov r0, r2

    ; copy 512 bytes
    mov r2, 512

    call copy_memory_bytes
    call [DISK_DATA_READY_CALLBACK]

    pop r2
    pop r1
    pop r0
    ret

; default disk wait behavior: spin in a loop until the disk reports the data is ready
default_disk_data_wait_callback:
    cmp.8 [DISK_DATA_WAIT_STATE], 0
    ifnz rjmp.8 default_disk_data_wait_callback_ready
    rjmp.8 default_disk_data_wait_callback
default_disk_data_wait_callback_ready:
    mov.8 [DISK_DATA_WAIT_STATE], 0
    ret

; default disk ready behavior: set [DISK_DATA_WAIT_STATE] to a non-zero value
default_disk_data_ready_callback:
    mov.8 [DISK_DATA_WAIT_STATE], 1
    ret
