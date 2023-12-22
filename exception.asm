; exception handling routines

; called if a divide by zero occurs
; does not return, calls panic
system_div_zero_handler:
    push r0

    mov r0, system_div_zero_str
    call debug_print
    call print_string_to_monitor

    pop r0
    jmp system_breakpoint_handler
system_div_zero_str: data.str "Divide by zero" data.8 10 data.8 0

; called if an invalid opcode is executed
; does not return, calls panic
system_invalid_op_handler:
    push r0

    mov r0, system_invalid_op_str
    call debug_print
    call print_string_to_monitor

    pop r0
    jmp system_breakpoint_handler
system_invalid_op_str: data.str "Invalid opcode" data.8 10 data.8 0

; called if a page fault occurs
; does not return, calls panic
system_page_fault_handler:
    push r0

    mov r0, system_page_fault_str
    call debug_print
    call print_string_to_monitor

    pop r0
    pop r1
    jmp system_breakpoint_handler
system_page_fault_str: data.str "Page fault at virtual address r1" data.8 10 data.8 0

; called upon execution of a `brk` instruction
; ensure the stack has at least 128 bytes of free space before triggering this exception!!
system_breakpoint_handler:
    add rsp, 4

    ; push all registers once to save them
    push rfp
    push resp
    push rsp
    push r31
    push r30
    push r29
    push r28
    push r27
    push r26
    push r25
    push r24
    push r23
    push r22
    push r21
    push r20
    push r19
    push r18
    push r17
    push r16
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push r7
    push r6
    push r5
    push r4
    push r3
    push r2
    push r1
    push r0

    ; modify the saved rsp value to reflect the value of rsp before the
    ; interrupt occured
    ; resp (4) + rfp (4) + flags (1) + return address (4) = 13 bytes
    add [rsp+128], 13

    ; print breakpoint message
    mov r0, system_breakpoint_str
    call debug_print
    call print_string_to_monitor

    ; print the display containing all of the registers
    ; r1 - used to store a pointer to the current string
    ; r2 - stores the current address on the stack
    ; r3 - loop counter
    mov r1, system_breakpoint_r0_str
    mov r2, rsp
    mov r3, 0
system_breakpoint_print_loop:
    ; print the register label
    mov r0, r1
    call print_string_to_monitor
    ; print the register value
    mov r0, [r2]
    call print_hex_word_to_monitor
    ; adjust string pointer, stack address, and loop counter
    add r1, SYSTEM_BREAKPOINT_R_STR_SIZE
    inc r2, 4
    inc r3
    ; decide whether to print a separator or a newline by checking if the loop
    ; counter is a multiple of 4
    mov r0, r3
    and r0, 0x03
    ifnz jmp system_breakpoint_print_sep
system_breakpoint_print_newline:
    mov r0, 10
    jmp system_breakpoint_print_last_char
system_breakpoint_print_sep:
    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
system_breakpoint_print_last_char:
    call print_character_to_monitor
    ; loop again if not on last register
    cmp r3, 35
    iflt jmp system_breakpoint_print_loop
    ; print rip
    mov r0, system_breakpoint_rip_str
    call print_string_to_monitor
    mov r0, [r2+1]
    call print_hex_word_to_monitor
    mov r0, 10
    call print_character_to_monitor

    call invoke_monitor

    pop r0
    pop r1
    pop r2
    pop r3
    pop r4
    pop r5
    pop r6
    pop r7
    pop r8
    pop r9
    pop r10
    pop r11
    pop r12
    pop r13
    pop r14
    pop r15
    pop r16
    pop r17
    pop r18
    pop r19
    pop r20
    pop r21
    pop r22
    pop r23
    pop r24
    pop r25
    pop r26
    pop r27
    pop r28
    pop r29
    pop r30
    pop r31
    ; don't restore rsp and resp. not sure whether restoring a potentially
    ; modified resp would break things, but changing rsp definitely would.
    add rsp, 8
    pop rfp
    reti
system_breakpoint_str:     data.str "Breakpoint reached!" data.8 10 data.8 0
const SYSTEM_BREAKPOINT_R_STR_SIZE: 7
system_breakpoint_r0_str:  data.strz "r0:   "
system_breakpoint_r1_str:  data.strz "r1:   "
system_breakpoint_r2_str:  data.strz "r2:   "
system_breakpoint_r3_str:  data.strz "r3:   "
system_breakpoint_r4_str:  data.strz "r4:   "
system_breakpoint_r5_str:  data.strz "r5:   "
system_breakpoint_r6_str:  data.strz "r6:   "
system_breakpoint_r7_str:  data.strz "r7:   "
system_breakpoint_r8_str:  data.strz "r8:   "
system_breakpoint_r9_str:  data.strz "r9:   "
system_breakpoint_r10_str: data.strz "r10:  "
system_breakpoint_r11_str: data.strz "r11:  "
system_breakpoint_r12_str: data.strz "r12:  "
system_breakpoint_r13_str: data.strz "r13:  "
system_breakpoint_r14_str: data.strz "r14:  "
system_breakpoint_r15_str: data.strz "r15:  "
system_breakpoint_r16_str: data.strz "r16:  "
system_breakpoint_r17_str: data.strz "r17:  "
system_breakpoint_r18_str: data.strz "r18:  "
system_breakpoint_r19_str: data.strz "r19:  "
system_breakpoint_r20_str: data.strz "r20:  "
system_breakpoint_r21_str: data.strz "r21:  "
system_breakpoint_r22_str: data.strz "r22:  "
system_breakpoint_r23_str: data.strz "r23:  "
system_breakpoint_r24_str: data.strz "r24:  "
system_breakpoint_r25_str: data.strz "r25:  "
system_breakpoint_r26_str: data.strz "r26:  "
system_breakpoint_r27_str: data.strz "r27:  "
system_breakpoint_r28_str: data.strz "r28:  "
system_breakpoint_r29_str: data.strz "r29:  "
system_breakpoint_r30_str: data.strz "r30:  "
system_breakpoint_r31_str: data.strz "r31:  "
system_breakpoint_rsp_str: data.strz "rsp:  "
system_breakpoint_resp_str: data.strz "resp: "
system_breakpoint_rfp_str: data.strz "rfp:  "
system_breakpoint_rip_str: data.strz "rip:  "
