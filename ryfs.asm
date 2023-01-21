; RYFS routines

; file struct:
;   file_disk: 1 byte
;   file_first_sector: 2 bytes
;   file_seek_offset: 4 bytes
;   file_reserved: 1 byte

; open a file from a RYFS-formatted disk
; inputs:
; r0: pointer to file name string (8.3 format, for example "test    txt" for test.txt)
; r1: disk ID
; r2: file struct: pointer to a blank file struct
; outputs:
; r0: first file sector, or zero if file wasn't found
ryfs_open:
    push r1
    push r2
    push r10
    push r31

    ; r10: pointer to file struct entry
    mov r10, r2
    mov.8 [r10], r1 ; write file_disk
    inc r10

    push r0
    mov r0, 1
    mov r2, TEMP_SECTOR_BUF
    call read_sector
    pop r0

    ; point to the file name of the first directory entry
    mov r1, TEMP_SECTOR_BUF
    add r1, 20
    mov r2, 11 ; compare 11 bytes
    mov r31, 31 ; 31 file entries total
ryfs_open_find_dir_entry_loop:
    call compare_memory_bytes
    ifz jmp ryfs_open_found_dir_entry
    add r1, 16 ; point to the file name in the next directory entry
    loop ryfs_open_find_dir_entry_loop
    ; if we reach this point, the file wasn't found
    mov r0, 0
    jmp ryfs_open_end
ryfs_open_found_dir_entry:
    sub r1, 4          ; point to first sector of this file
    mov.16 [r10], [r1] ; write file_first_sector
    add r10, 2
    mov [r10], 0       ; write file_seek_offset
    inc r10
    mov.8 [r10], 0     ; write file_reserved
    movz.16 r0, [r1]
ryfs_open_end:
    pop r31
    pop r10
    pop r2
    pop r1
    ret

; seek specified file to the specified offset
; inputs:
; r0: byte offset
; r1: pointer to file struct
; outputs:
; none
ryfs_seek:
    push r1

    add r1, 3
    mov [r1], r0

    pop r1
    ret

; get the seek offset of the specified file
; inputs:
; r0: pointer to file struct
; outputs:
; r0: byte offset
ryfs_tell:
    add r0, 3
    mov r0, [r0]

    ret

; read specified number of bytes into the specified buffer
; inputs:
; r0: number of bytes to read
; r1: pointer to file struct
; r2: pointer to destination buffer
; outputs:
; none
ryfs_read:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r10
    push r11
    push r12
    push r31

    ; number_of_sectors_to_load = ceil(input r0, 506) / 506

    ; first, ceil the number of bytes to multiple of 506
    ; value_temp = value / 506
    ; if value % 506 != 0:
    ;   value_temp++
    ; value_ceil = value_temp * 506
    mov r10, r0
    mov r11, r0
    mov r12, 506
    div r11, r12
    rem r10, r12
    ifnz inc r11
    mul r11, r12
    div r11, r12
    mov r3, r11 ; r3: number_of_sectors_to_load

    mov r10, r1
    add r10, 3
    mov r4, [r10]

    mov r10, r4
    mov r11, r4
    mov r12, 506
    div r11, r12
    rem r10, r12
    ifnz inc r11
    mul r11, r12
    div r11, r12
    mov r4, r11 ; r4: number of sectors to traverse

    ; start_sector = traverse through linked sectors starting at file_struct.file_first_sector

    push r0
    push r1
    push r2
    mov r10, r1
    ; read the file's first sector into the temp buffer
    movz.8 r1, [r10] ; file_disk
    inc r10
    movz.16 r0, [r10] ; file_first_sector
    mov r31, r4
ryfs_read_traverse_sectors_loop:
    mov r2, TEMP_SECTOR_BUF
    call read_sector
    mov r4, r0
    add r2, 2 ; point to next sector number
    movz.16 r0, [r2] ; load next sector number
    cmp r31, 0 ; if we started at zero, then don't attempt to loop
    ifnz loop ryfs_read_traverse_sectors_loop
    pop r2
    pop r1
    pop r0

    ; r4: start_sector

    ; total_bytes_remaining = input r0
    ; this_sector = start_sector
    ; for range 0..number_of_sectors_to_load:
    ;   load this_sector into temporary buffer
    ;   bytes_to_load = if total_bytes_remaining >= 506
    ;     506
    ;   else:
    ;     total_bytes_remaining
    ;   for range 0..bytes_to_load:
    ;     load byte from temporary buffer into destination buffer
    ;   this_sector = this_sector.next

    mov r10, r0 ; r10: total_bytes_remaining
ryfs_read_sector_loop:
    push r0
    push r1
    push r2
    ; read this sector into the temp buffer
    mov r0, r4
    movz.8 r1, [r1] ; file_disk
    mov r2, TEMP_SECTOR_BUF
    call read_sector
    pop r2
    pop r1
    pop r0

    ; r11: bytes_to_load
    cmp r10, 506
    ifgteq mov r11, 506
    iflt mov r11, r10

    push r0
    push r1
    push r2

    ; calculate the seek offset
    mov r12, r1
    add r12, 3
    mov r5, [r12]
    rem r5, 506

    ; copy the sector data to the destination buffer
    mov r0, TEMP_SECTOR_BUF
    add r0, 6
    add r0, r5 ; add the seek offset
    mov r1, r2
    mov r2, r11
    call copy_memory_bytes
    pop r2
    pop r1
    pop r0

    ; this_sector = this_sector.next
    mov r5, TEMP_SECTOR_BUF
    add r5, 2
    movz.16 r5, [r5]
    mov r4, r5

    add r2, r11
    sub r10, r11
    ifnz jmp ryfs_read_sector_loop

    ; file_struct.file_seek_offset += input r0
    add r1, 3
    add [r1], r0

    pop r31
    pop r12
    pop r11
    pop r10
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret

; read a whole file into the specified buffer
; inputs:
; r0: pointer to file struct
; r1: pointer to destination buffer
; outputs:
; none
ryfs_read_whole_file:
    push r0
    push r1
    push r2

    mov r2, r1
    mov r1, r0
    call ryfs_get_size
    call ryfs_read

    pop r2
    pop r1
    pop r0
    ret

; write specified number of bytes from the specified buffer
; THIS DOES NOT UPDATE THE TOTAL SIZE OF THE FILE; do not write past the end of a file, bad things will happen
; inputs:
; r0: number of bytes to write
; r1: pointer to file struct
; r2: pointer to source buffer
; outputs:
; none
ryfs_write:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r10
    push r11
    push r12
    push r31

    ; number_of_sectors_to_load = ceil(input r0, 506) / 506

    ; first, ceil the number of bytes to multiple of 506
    ; value_temp = value / 506
    ; if value % 506 != 0:
    ;   value_temp++
    ; value_ceil = value_temp * 506
    mov r10, r0
    mov r11, r0
    mov r12, 506
    div r11, r12
    rem r10, r12
    ifnz inc r11
    mul r11, r12
    div r11, r12
    mov r3, r11 ; r3: number_of_sectors_to_load

    mov r10, r1
    add r10, 3
    mov r4, [r10]

    mov r10, r4
    mov r11, r4
    mov r12, 506
    div r11, r12
    rem r10, r12
    ifnz inc r11
    mul r11, r12
    div r11, r12
    mov r4, r11 ; r4: number of sectors to traverse

    ; start_sector = traverse through linked sectors starting at file_struct.file_first_sector

    push r0
    push r1
    push r2
    mov r10, r1
    ; read the file's first sector into the temp buffer
    movz.8 r1, [r10] ; file_disk
    inc r10
    movz.16 r0, [r10] ; file_first_sector
    mov r31, r4
ryfs_write_traverse_sectors_loop:
    mov r2, TEMP_SECTOR_BUF
    call read_sector
    mov r4, r0
    add r2, 2 ; point to next sector number
    movz.16 r0, [r2] ; load next sector number
    cmp r31, 0 ; if we started at zero, then don't attempt to loop
    ifnz loop ryfs_write_traverse_sectors_loop
    pop r2
    pop r1
    pop r0

    ; r4: start_sector

    ; total_bytes_remaining = input r0
    ; this_sector = start_sector
    ; for range 0..number_of_sectors_to_load:
    ;   load this_sector into temporary buffer
    ;   bytes_to_load = if total_bytes_remaining >= 506
    ;     506
    ;   else:
    ;     total_bytes_remaining
    ;   for range 0..bytes_to_load:
    ;     load byte from temporary buffer into destination buffer
    ;   this_sector = this_sector.next

    mov r10, r0 ; r10: total_bytes_remaining
ryfs_write_sector_loop:
    push r0
    push r1
    push r2
    ; read this sector into the temp buffer
    mov r0, r4
    movz.8 r1, [r1] ; file_disk
    mov r2, TEMP_SECTOR_BUF
    call read_sector
    pop r2
    pop r1
    pop r0

    ; r11: bytes_to_load
    cmp r10, 506
    ifgteq mov r11, 506
    iflt mov r11, r10

    push r0
    push r1
    push r2

    ; calculate the seek offset
    mov r12, r1
    add r12, 3
    mov r5, [r12]
    rem r5, 506

    ; copy the sector data from the source buffer to the temp buffer
    mov r0, r2
    mov r1, TEMP_SECTOR_BUF
    add r1, 6
    add r1, r5 ; add the seek offset
    mov r2, r11
    call copy_memory_bytes
    pop r2
    pop r1
    pop r0

    push r0
    push r1
    push r2
    ; write this sector back out to disk
    mov r0, r4
    movz.8 r1, [r1] ; file_disk
    mov r2, TEMP_SECTOR_BUF
    call write_sector
    pop r2
    pop r1
    pop r0

    ; this_sector = this_sector.next
    mov r5, TEMP_SECTOR_BUF
    add r5, 2
    movz.16 r5, [r5]
    mov r4, r5

    add r2, r11
    sub r10, r11
    ifnz jmp ryfs_write_sector_loop

    ; file_struct.file_seek_offset += input r0
    add r1, 3
    add [r1], r0

    pop r31
    pop r12
    pop r11
    pop r10
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret

; get the exact size of a file
; inputs:
; r0: pointer to file struct
; outputs:
; r0: file size in bytes
ryfs_get_size:
    push r1
    push r2
    push r10
    push r11

    mov r10, r0
    mov r11, 0 ; byte counter

    ; read the first sector into the temp buffer
    movz.8 r1, [r0] ; file_disk
    inc r0
    movz.16 r0, [r0] ; file_first_sector
ryfs_get_size_sector_loop:
    mov r2, TEMP_SECTOR_BUF
    call read_sector

    ; check to see if this is the last sector
    ; if this is the last sector, read the sector size field in the header
    mov r0, TEMP_SECTOR_BUF
    add r0, 2
    cmp.16 [r0], 0
    ifz jmp ryfs_get_size_last_sector

    ; there are more sectors left, load them
    movz.16 r0, [r0] ; sector number
    mov r1, [r10]    ; file_disk
    add r11, 506
    jmp ryfs_get_size_sector_loop
ryfs_get_size_last_sector:
    ; this is the last sector, read the header to get the reamining number of bytes
    mov r0, TEMP_SECTOR_BUF
    add r0, 4
    movz.16 r0, [r0]
    add r11, r0

    ; return final size
    mov r0, r11

    pop r11
    pop r10
    pop r2
    pop r1
    ret

; get a list of all files on disk
; format: "file1   extfile2   ext", etc.
; each file name is exactly 11 characters long, the buffer is not null-terminated
; inputs:
; r0: pointer to 341 byte buffer (max size) for file names (31 file entries * 11 chars)
; r1: disk ID
; outputs:
; r0: number of files
ryfs_get_file_list:
    push r1
    push r2
    push r3
    push r31

    mov r3, r0

    ; load directory sector into temp buffer
    mov r0, 1
    mov r2, TEMP_SECTOR_BUF
    call read_sector

    mov r31, 31
    mov r0, TEMP_SECTOR_BUF
    add r0, 20 ; point to first file name
    mov r1, r3
    mov r3, 0 ; file counter
ryfs_get_file_list_loop:
    ; check if this file entry is filled
    cmp.8 [r0], 0
    ifz jmp ryfs_get_file_list_loop_next
    ; copy 11 bytes from [r0] to [r1]
    mov r2, 11
    call copy_memory_bytes
    inc r3
ryfs_get_file_list_loop_next:
    add r0, 16 ; point to next file entry
    add r1, 11 ; increment the destination pointer
    loop ryfs_get_file_list_loop

    ; return number of files
    mov r0, r3

    pop r31
    pop r3
    pop r2
    pop r1
    ret
