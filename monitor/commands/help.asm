; help command

monitor_shell_help_command_string: data.str "help" data.8 0

monitor_shell_help_command:
    mov r0, monitor_shell_help_text
    call print_string_to_monitor
    ret

monitor_shell_help_text:
    data.str "command | description" data.8 10
    data.str "------- | -----------" data.8 10
    data.str "exit    | exit the monitor" data.8 10
    data.str "help    | display this help text" data.8 10
    data.8 0
