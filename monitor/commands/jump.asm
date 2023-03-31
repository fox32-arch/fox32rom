; jump command

monitor_shell_jump_command_string: data.strz "jump"

monitor_shell_jump_command:
    call monitor_shell_parse_arguments
    mov r1, 16
    call string_to_int

    ; r0: address

    jmp exit_monitor_and_jump
