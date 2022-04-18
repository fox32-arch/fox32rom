; debug monitor keyboard routines

; convert a make scancode to an ASCII character
; inputs:
; r0: make scancode
; outputs:
; r0: ASCII character
scancode_to_ascii:
    add r0, scancode_table
    movz.8 r0, [r0]

    ret

; scancode set 1:
; https://wiki.osdev.org/PS/2_Keyboard#Scan_Code_Set_1
const LSHIFT_PRESS:   0x2A
const LSHIFT_RELEASE: 0xAA
const RSHIFT_PRESS:   0x36
const RSHIFT_RELEASE: 0xB6
const CAPS_PRESS:     0x3A
const CAPS_RELEASE:   0xBA
scancode_table:
    data.8 0 data.8 27 data.str "1234567890-=" data.8 8
    data.8 9 data.str "qwertyuiop[]" data.8 10 data.8 0
    data.str "asdfghjkl;'`" data.8 0 data.8 92
    data.str "zxcvbnm,./" data.8 0 data.str "*" data.8 0 data.str " "
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.str "-" data.8 0 data.8 0 data.8 0 data.str "+"
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0
scancode_table_shift:
    data.8 0 data.8 27 data.str "!@#$%^&*()_+" data.8 8
    data.8 9 data.str "QWERTYUIOP{}" data.8 10 data.8 0
    data.str "ASDFGHJKL:" data.8 34 data.str "~" data.8 0 data.str "|"
    data.str "ZXCVBNM<>?" data.8 0 data.str "*" data.8 0 data.str " "
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.str "-" data.8 0 data.8 0 data.8 0 data.str "+"
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0
scancode_table_caps:
    data.8 0 data.8 27 data.str "1234567890-=" data.8 8
    data.8 9 data.str "QWERTYUIOP[]" data.8 10 data.8 0
    data.str "ASDFGHJKL;'`" data.8 0 data.8 92
    data.str "ZXCVBNM,./" data.8 0 data.str "*" data.8 0 data.str " "
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.str "-" data.8 0 data.8 0 data.8 0 data.str "+"
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0 data.8 0
    data.8 0 data.8 0 data.8 0

const MONITOR_MODIFIER_BITMAP: 0x03ED3FDB ; 1 byte
