; set command

monitor_shell_set8_command_string:  data.str "set.8"  data.8 0
monitor_shell_set16_command_string: data.str "set.16" data.8 0
monitor_shell_set32_command_string: data.str "set.32" data.8 0

monitor_shell_set8_command:
    call monitor_shell_parse_arguments

    ; r0: pointer to address string
    ; r1: pointer to byte string

    push r1
    mov r1, 16
    call string_to_int
    mov r10, r0

    pop r0
    mov r1, 16
    call string_to_int
    mov r11, r0

    ; r10: address
    ; r11: byte

    mov.8 [r10], r11

    ret

monitor_shell_set16_command:
    call monitor_shell_parse_arguments

    ; r0: pointer to address string
    ; r1: pointer to half string

    push r1
    mov r1, 16
    call string_to_int
    mov r10, r0

    pop r0
    mov r1, 16
    call string_to_int
    mov r11, r0

    ; r10: address
    ; r11: half

    mov.16 [r10], r11

    ret

monitor_shell_set32_command:
    call monitor_shell_parse_arguments

    ; r0: pointer to address string
    ; r1: pointer to word string

    push r1
    mov r1, 16
    call string_to_int
    mov r10, r0

    pop r0
    mov r1, 16
    call string_to_int
    mov r11, r0

    ; r10: address
    ; r11: word

    mov [r10], r11

    ret
