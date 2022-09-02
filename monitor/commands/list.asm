; list command

monitor_shell_list_command_string: data.str "list" data.8 0

monitor_shell_list_command:
    mov r0, monitor_shell_list_text
    call print_string_to_monitor

    call monitor_shell_parse_arguments
    mov r1, 16
    call string_to_int

    ; r0: starting address

    mov r10, r0
    mov r31, 16 ; line counter
monitor_shell_list_command_line_loop:
    mov r30, 16 ; byte counter, 16 bytes per line
    ; print current address
    mov r0, r10
    call print_hex_word_to_monitor
    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor
monitor_shell_list_command_byte_loop:
    movz.8 r0, [r10]
    call print_hex_byte_to_monitor
    mov r0, ' '
    call print_character_to_monitor
    inc r10
    dec r30
    ifnz jmp monitor_shell_list_command_byte_loop

    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    mov r29, 16
    sub r10, 16
monitor_shell_list_command_ascii_loop:
    movz.8 r0, [r10]
    cmp r0, ' '
    iflt jmp monitor_shell_list_command_ascii_loop_skip_char
    cmp r0, '~'
    ifgt jmp monitor_shell_list_command_ascii_loop_skip_char

    call print_character_to_monitor
    inc r10
    dec r29
    ifnz jmp monitor_shell_list_command_ascii_loop
    jmp monitor_shell_list_command_ascii_loop_done
monitor_shell_list_command_ascii_loop_skip_char:
    mov r0, '.'
    call print_character_to_monitor
    inc r10
    dec r29
    ifnz jmp monitor_shell_list_command_ascii_loop
monitor_shell_list_command_ascii_loop_done:
    mov r0, 10
    call print_character_to_monitor
    loop monitor_shell_list_command_line_loop

    call redraw_monitor_console

    ret

monitor_shell_list_text: data.str "address  | x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC xD xE xF | ASCII" data.8 10 data.8 0
