; exit command

monitor_shell_exit_command_string: data.strz "exit"

monitor_shell_exit_command:
    jmp exit_monitor
