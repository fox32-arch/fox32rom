; jump command

monitor_shell_jump_command_string: data.str "jump" data.8 0

monitor_shell_jump_command:
    call monitor_shell_parse_arguments
    mov r1, 16
    call string_to_int

    ; r0: address

    call r0

    call redraw_monitor_console

    ret
