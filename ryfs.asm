; RYFS routines

; open a file from a RYFS-formatted disk
; inputs:
; r0: pointer to file name string (8.3 format, for example "test    txt" for test.txt)
; r1: disk ID
; r2: file struct: pointer to a blank 8 byte file struct as described below
; r3: pointer to sector buffer
; outputs:
; r0: first file sector
;
; file struct:
; file_disk: 1 byte
; file_first_sector: 2 bytes
; file_seek_offset: 4 bytes
; file_reserved: 1 byte
ryfs_open:
    push r1
    push r2
    push r10

    ; r10: pointer to file struct entry
    mov r10, r2
    mov.8 [r10], r1 ; write file_disk
    inc r10

    push r0
    mov r0, 1
    mov r2, r3
    call read_sector
    pop r0

    ; point to the file name of the first directory entry
    mov r1, r3
    add r1, 20
    mov r2, 11 ; compare 11 bytes
ryfs_open_find_dir_entry_loop:
    call compare_memory_bytes
    ifz jmp ryfs_open_found_dir_entry
    add r1, 16 ; point to the file name in the next directory entry
    jmp ryfs_open_find_dir_entry_loop ; FIXME: this never returns if the file wasn't found
ryfs_open_found_dir_entry:
    sub r1, 4          ; point to first sector of this file
    mov.16 [r10], [r1] ; write file_first_sector
    add r10, 2
    mov [r10], 0       ; write file_seek_offset
    inc r10
    mov.8 [r10], 0     ; write file_reserved
    movz.16 r0, [r1]

    pop r10
    pop r2
    pop r1
    ret

; read a whole file into the specified buffer
; FIXME: this will always load a multiple of 506 bytes, even if the file is smaller
; inputs:
; r0: pointer to file struct
; r1: pointer to destination buffer
; outputs:
; none
;
; file struct:
; file_disk: 1 byte
; file_first_sector: 2 bytes
; file_seek_offset: 4 bytes
; file_reserved: 1 byte
ryfs_read_whole_file:
    push r0
    push r1
    push r2
    push r10
    push r11

    mov r10, r0
    mov r11, r1

    ; read the first sector into the temp buffer
    movz.8 r1, [r0] ; file_disk
    inc r0
    movz.16 r0, [r0] ; file_first_sector
ryfs_read_whole_file_sector_loop:
    mov r2, TEMP_SECTOR_BUF
    call read_sector

    ; copy the sector data to the destination buffer
    mov r0, TEMP_SECTOR_BUF
    add r0, 6
    mov r1, r11
    mov r2, 506
    call copy_memory_bytes

    ; check to see if this is the last sector
    ; FIXME: if this is the last sector, it should respect the sector size field in the header
    sub r0, 4
    cmp.16 [r0], 0
    ifz jmp ryfs_read_whole_file_last_sector

    ; there are more sectors left, load them
    movz.16 r0, [r0] ; sector number
    mov r1, [r10]    ; file_disk
    add r11, 506
    jmp ryfs_read_whole_file_sector_loop
ryfs_read_whole_file_last_sector:
    pop r11
    pop r10
    pop r2
    pop r1
    pop r0
    ret
