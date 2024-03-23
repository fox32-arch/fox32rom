; fox32rom routine definitions for Okameron

; PROCEDURE Panic(
;    str: POINTER TO CHAR;
; );
Panic:
    jmp panic

; PROCEDURE NewEvent(
;    eventType,
;    eventArg0,
;    eventArg1,
;    eventArg2,
;    eventArg3,
;    eventArg4,
;    eventArg5,
;    eventArg6: INT;
; );
NewEvent:
    push r7
    mov r7, 0
    call new_event
    pop r7
    ret

; PROCEDURE GetNextEvent(event: POINTER TO ARRAY 8 OF INT);
GetNextEvent:
    push r8
    mov r8, r0
    call get_next_event
    mov [r8], r0
    add r8, 4
    mov [r8], r1
    add r8, 4
    mov [r8], r2
    add r8, 4
    mov [r8], r3
    add r8, 4
    mov [r8], r4
    add r8, 4
    mov [r8], r5
    add r8, 4
    mov [r8], r6
    add r8, 4
    mov [r8], r7
    pop r8
    ret

; PROCEDURE ScancodeToAscii(scancode: CHAR;): CHAR;
ScancodeToAscii:
    jmp scancode_to_ascii

; PROCEDURE ShiftPressed();
ShiftPressed:
    jmp shift_pressed

; PROCEDURE ShiftReleased();
ShiftReleased:
    jmp shift_released

; PROCEDURE CapsPressed();
CapsPressed:
    jmp caps_pressed

; PROCEDURE FillBackground(color: INT;);
FillBackground:
    jmp fill_background

; PROCEDURE DrawStrToBackground(
;    str: POINTER TO CHAR;
;    x, y, fgColor, bgColor: INT;
; );
DrawStrToBackground:
    jmp draw_str_to_background

; PROCEDURE DrawFontTileToBackground(
;    c: CHAR;
;    x, y, fgColor, bgColor: INT;
; );
DrawFontTileToBackground:
    jmp draw_font_tile_to_background

; PROCEDURE DrawFormatStrToBackground(
;    str: POINTER TO CHAR;
;    x, y, fgColor, bgColor,
;    format0, format1, format2: INT;
; );
DrawFormatStrToBackground:
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    mov r10, r5
    mov r11, r6
    mov r12, r7
    mov r13, 0
    mov r14, 0
    mov r15, 0
    call draw_format_str_to_background
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    ret

; PROCEDURE FillOverlay(color, overlay: INT;);
FillOverlay:
    jmp fill_overlay

; PROCEDURE DrawStrToOverlay(
;    str: POINTER TO CHAR;
;    x, y, fgColor, bgColor, overlay: INT;
; );
DrawStrToOverlay:
    jmp draw_str_to_overlay

; PROCEDURE DrawFormatStrToBackground(
;    str: POINTER TO CHAR;
;    x, y, fgColor, bgColor, overlay,
;    format0, format1: INT;
; );
DrawFormatStrToOverlay:
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    mov r10, r5
    mov r11, r6
    mov r12, r7
    mov r13, 0
    mov r14, 0
    mov r15, 0
    call draw_format_str_to_overlay
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    ret

; PROCEDURE DrawFilledRectangleToOverlay(
;    x, y, width, height, color, overlay: INT;
; );
DrawFilledRectangleToOverlay:
    jmp draw_filled_rectangle_to_overlay

; PROCEDURE RYFSOpen(
;    name: POINTER TO CHAR;
;    id: INT;
;    struct: POINTER TO ROMFile;
; ): INT;
RYFSOpen:
    jmp ryfs_open

; PROCEDURE RYFSSeek(
;    offset: INT;
;    struct: POINTER TO ROMFile;
; );
RYFSSeek:
    jmp ryfs_seek

; PROCEDURE RYFSTell(
;    struct: POINTER TO ROMFile;
; ): INT;
RYFSTell:
    jmp ryfs_tell

; PROCEDURE RYFSRead(
;    size: INT;
;    struct: POINTER TO ROMFile;
;    destination: POINTER TO CHAR;
; );
RYFSRead:
    jmp ryfs_read

; PROCEDURE RYFSReadWholeFile(
;    struct: POINTER TO ROMFile;
;    destination: POINTER TO CHAR;
; );
RYFSReadWholeFile:
    jmp ryfs_read_whole_file

; PROCEDURE RYFSGetSize(
;    struct: POINTER TO ROMFile;
; ): INT;
RYFSGetSize:
    jmp ryfs_get_size

; PROCEDURE RYFSGetFileList(
;    buffer: POINTER TO CHAR;
;    id: INT;
; );
RYFSGetFileList:
    jmp ryfs_get_file_list

; PROCEDURE RYFSWrite(
;    size: INT;
;    struct: POINTER TO ROMFile;
;    source: POINTER TO CHAR;
; );
RYFSWrite:
    jmp ryfs_write

; PROCEDURE RYFSCreate(
;    name: POINTER TO CHAR;
;    id: INT;
;    struct: POINTER TO ROMFile;
;    sizeInBytes: INT;
; ): INT;
RYFSCreate:
    jmp ryfs_create

; PROCEDURE StringToInt(
;    str: POINTER TO CHAR;
;    radix: INT;
; ): INT;
StringToInt:
    jmp string_to_int

; PROCEDURE CopyMemoryChar(
;    source, destination: POINTER TO CHAR;
;    size: INT;
; );
CopyMemoryChar:
    jmp copy_memory_bytes

; PROCEDURE CopyMemoryInt(
;    source, destination: POINTER TO INT;
;    size: INT;
; );
CopyMemoryInt:
    jmp copy_memory_words

; PROCEDURE CopyString(
;    source, destination: POINTER TO CHAR;
; );
CopyString:
    jmp copy_string

; PROCEDURE CompareMemoryChar(
;    source, destination: POINTER TO CHAR;
;    size: INT;
; ): INT;
CompareMemoryChar:
    call compare_memory_bytes
    ifz mov r0, 0
    ifnz mov r0, 1
    ret

; PROCEDURE CompareMemoryInt(
;    source, destination: POINTER TO INT;
;    size: INT;
; ): INT;
CompareMemoryInt:
    call compare_memory_words
    ifz mov r0, 0
    ifnz mov r0, 1
    ret

; PROCEDURE CompareString(
;    source, destination: POINTER TO CHAR;
;    size: INT;
; ): INT;
CompareString:
    call compare_string
    ifz mov r0, 0
    ifnz mov r0, 1
    ret

; PROCEDURE StringLength(
;    source: POINTER TO CHAR;
; ): INT;
StringLength:
    jmp string_length
