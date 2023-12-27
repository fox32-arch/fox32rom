; brk command

monitor_shell_brk_command_string: data.strz "brk"

monitor_shell_brk_command:
    ; push an extra return to redraw the console
    push redraw_monitor_console
    call monitor_shell_parse_arguments

    ; arguments:
    ; $0: address to set breakpoint at (optional)
    ; $1: breakpoint number (optional)
    ; if $1 is omitted, set breakpoint using first available number
    ; if $0 is omitted, list current breakpoints

    ; check if argument $0 is empty
    cmp r0, 0
    ifz jmp monitor_shell_brk_command_list
    ; if not, convert it to integer
    push r1
    mov r1, 16
    call string_to_int
    mov r10, r0

    ; check if argument $1 is empty
    pop r0
    cmp r0, 0
    ifz jmp monitor_shell_brk_command_add_any
    ; if not, convert it to integer
    call string_to_int
    mov r11, r0

monitor_shell_brk_command_add:
    ; check if breakpoint number is valid
    cmp r11, 0x10
    ifgteq jmp monitor_shell_brk_command_add_invalid_num
    ; add the breakpoint
    mov r0, r10
    mov r1, r11
    call monitor_breakpoint_add
    ; check if adding the breakpoint failed
    cmp r0, 0xFFFFFFFF
    ifz jmp monitor_shell_brk_command_add_fail
    ; check if a breakpoint was removed to add this one, and if so, display
    ; a message
    cmp r0, 0
    ifnz call monitor_shell_brkrm_command_print_rm_msg
    ; display a message that a breakpoint was added
    mov r0, r10
    mov r1, r11
    call monitor_shell_brk_command_print_add_msg

    ret

monitor_shell_brk_command_add_fail:
    ; print failure message
    mov r0, r10
    mov r1, r11
    call monitor_shell_brk_command_print_fail_msg

    ret

monitor_shell_brk_command_add_invalid_num:
    ; print failure message
    mov r0, r11
    call monitor_shell_brk_command_print_invalid_msg

    ret

monitor_shell_brk_command_add_any:
    ; add the breakpoint
    mov r0, r10
    call monitor_breakpoint_add_any
    ; check if adding the breakpoint failed
    cmp r0, 0xFFFFFFFF
    ifz jmp monitor_shell_brk_command_add_any_fail
    ; display a message that the breakpoint was added
    mov r1, r0
    mov r0, r10
    call monitor_shell_brk_command_print_add_msg

    ret

monitor_shell_brk_command_add_any_fail:
    ; print failure message
    mov r0, r10
    call monitor_shell_brk_command_print_fail_msg_no_num

    ret

monitor_shell_brk_command_list:
    ; get breakpoint number in r1 and table pointer in r2
    mov r1, 0
    mov r2, MONITOR_BREAKPOINT_TABLE
    ; loop over each table entry
monitor_shell_brk_command_list_loop:
    ; print breakpoint number and address
    mov r0, r1
    call print_hex_digit_to_monitor
    mov r0, ':'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor
    ; check whether breakpoint is set
    mov r0, [r2]
    cmp r0, 0
    ifnz jmp monitor_shell_brk_command_list_print_addr
    ; breakpoint is not set, so print dashes instead of address
    mov r0, monitor_shell_brk_command_unset_str
    call print_string_to_monitor
    jmp monitor_shell_brk_command_list_print_addr_done
monitor_shell_brk_command_list_print_addr:
    ; breakpoint is set, so print its address
    call print_hex_word_to_monitor
monitor_shell_brk_command_list_print_addr_done:
    ; increment breakpoint number and table pointer
    inc r1
    inc r2, 4
    ; if new breakpoint number is a multiple of 4, only print a newline
    mov r0, r1
    and r0, 0x03
    ifz mov r0, 10
    ifz jmp monitor_shell_brk_command_list_print_last
    ; print separator
    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
monitor_shell_brk_command_list_print_last:
    call print_character_to_monitor
    ; loop again if new breakpoint number is in range
    cmp r1, 0x10
    iflt jmp monitor_shell_brk_command_list_loop

    ret

; print a message stating that the breakpoint was added
; 'Added breakpoint X at XXXXXXXX'
; inputs:
; r0: address of breakpoint
; r1: breakpoint number
; outputs:
; none
monitor_shell_brk_command_print_add_msg:
    push r0
    mov r0, monitor_shell_brk_command_add_str
    call print_string_to_monitor
    pop r0
    call monitor_shell_brk_command_print_num_at_addr
    ret

; print a message stating that the breakpoint couldn't be added
; 'Failed to add breakpoint X at XXXXXXXX'
; inputs:
; r0: address of breakpoint
; r1: breakpoint number
; outputs:
; none
monitor_shell_brk_command_print_fail_msg:
    push r0
    mov r0, monitor_shell_brk_command_fail_str
    call print_string_to_monitor
    pop r0
    call monitor_shell_brk_command_print_num_at_addr
    ret

; print a message stating that the breakpoint couldn't be added
; 'Failed to add breakpoint  at XXXXXXXX'
; inputs:
; r0: address of breakpoint
; r1: breakpoint number
; outputs:
; none
monitor_shell_brk_command_print_fail_msg_no_num:
    push r0
    push r0
    mov r0, monitor_shell_brk_command_fail_str
    call print_string_to_monitor
    mov r0, monitor_shell_brk_command_at_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor
    mov r0, 10
    call print_character_to_monitor
    pop r0
    ret

; print a message that the provided breakpoint number is invalid
; 'Invalid breakpoint number XXXXXXXX'
; inputs:
; r0: breakpoint number
; outputs:
; none
monitor_shell_brk_command_print_invalid_msg:
    push r0
    push r0
    mov r0, monitor_shell_brk_command_invalid_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor
    mov r0, 10
    call print_character_to_monitor
    pop r0
    ret

; print the breakpoint number, followed by ' at ', followed by its address,
; followed by a newline
; inputs:
; r0: address of breakpoint
; r1: breakpoint number
; outputs:
; none
monitor_shell_brk_command_print_num_at_addr:
    push r0
    push r0
    mov r0, r1
    call print_hex_digit_to_monitor
    mov r0, monitor_shell_brk_command_at_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor
    mov r0, 10
    call print_character_to_monitor
    pop r0
    ret

monitor_shell_brk_command_add_str:
    data.strz "Added breakpoint "
monitor_shell_brk_command_fail_str:
    data.strz "Failed to add breakpoint "
monitor_shell_brk_command_invalid_str:
    data.strz "Invalid breakpoint number "
monitor_shell_brk_command_at_str:
    data.strz " at "
monitor_shell_brk_command_unset_str:
    data.strz "--------"
