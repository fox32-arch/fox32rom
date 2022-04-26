; exit command

monitor_shell_exit_command_string: data.str "exit" data.8 0

monitor_shell_exit_command:
    jmp exit_monitor
