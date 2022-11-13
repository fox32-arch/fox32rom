; exception handling routines

; called if a divide by zero occurs
; does not return, calls panic
system_div_zero_handler:
    mov r0, system_div_zero_str
    jmp panic
system_div_zero_str: data.str "Divide by zero" data.8 10 data.8 0

; called if an invalid opcode is executed
; does not return, calls panic
system_invalid_op_handler:
    mov r0, system_invalid_op_str
    jmp panic
system_invalid_op_str: data.str "Invalid opcode" data.8 10 data.8 0

; called if a page fault occurs
; does not return, calls panic
system_page_fault_handler:
    mov r0, system_page_fault_str
    pop r1
    jmp panic
system_page_fault_str: data.str "Page fault at virtual address r1" data.8 10 data.8 0

; called upon execution of a `brk` instruction
; ensure the stack has at least 256 bytes of free space before triggering this exception!!
; this code is extremely ugly, but it works :P
system_breakpoint_handler:
    add rsp, 4

    ; push all registers once to save them
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

    ; then push all registers again so they can be popped one by one to print to the monitor
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

    mov r0, system_breakpoint_str
    call debug_print
    call print_string_to_monitor

    ; r0
    mov r0, system_breakpoint_r0_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r1
    mov r0, system_breakpoint_r1_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r2
    mov r0, system_breakpoint_r2_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r3
    mov r0, system_breakpoint_r3_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; r4
    mov r0, system_breakpoint_r4_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r5
    mov r0, system_breakpoint_r5_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r6
    mov r0, system_breakpoint_r6_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r7
    mov r0, system_breakpoint_r7_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; r8
    mov r0, system_breakpoint_r8_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r9
    mov r0, system_breakpoint_r9_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r10
    mov r0, system_breakpoint_r10_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r11
    mov r0, system_breakpoint_r11_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; r12
    mov r0, system_breakpoint_r12_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r13
    mov r0, system_breakpoint_r13_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r14
    mov r0, system_breakpoint_r14_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r15
    mov r0, system_breakpoint_r15_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; r16
    mov r0, system_breakpoint_r16_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r17
    mov r0, system_breakpoint_r17_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r18
    mov r0, system_breakpoint_r18_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r19
    mov r0, system_breakpoint_r19_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; r20
    mov r0, system_breakpoint_r20_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r21
    mov r0, system_breakpoint_r21_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r22
    mov r0, system_breakpoint_r22_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r23
    mov r0, system_breakpoint_r23_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; r24
    mov r0, system_breakpoint_r24_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r25
    mov r0, system_breakpoint_r25_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r26
    mov r0, system_breakpoint_r26_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r27
    mov r0, system_breakpoint_r27_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; r28
    mov r0, system_breakpoint_r28_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r29
    mov r0, system_breakpoint_r29_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r30
    mov r0, system_breakpoint_r30_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; r31
    mov r0, system_breakpoint_r31_str
    call print_string_to_monitor
    pop r0
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

    ; rsp
    mov r0, system_breakpoint_rsp_str
    call print_string_to_monitor
    mov r0, rsp
    add r0, 133 ; account for the registers pushed above, and for the int calling convention
    call print_hex_word_to_monitor

    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor

    ; rip
    mov r0, system_breakpoint_rip_str
    call print_string_to_monitor
    mov r0, rsp
    add r0, 129 ; read instruction pointer from the stack
    mov r0, [r0]
    call print_hex_word_to_monitor

    ; ---
    mov r0, 10
    call print_character_to_monitor
    ; ---

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
    reti
system_breakpoint_str:     data.str "Breakpoint reached!" data.8 10 data.8 0
system_breakpoint_r0_str:  data.str "r0:  " data.8 0
system_breakpoint_r1_str:  data.str "r1:  " data.8 0
system_breakpoint_r2_str:  data.str "r2:  " data.8 0
system_breakpoint_r3_str:  data.str "r3:  " data.8 0
system_breakpoint_r4_str:  data.str "r4:  " data.8 0
system_breakpoint_r5_str:  data.str "r5:  " data.8 0
system_breakpoint_r6_str:  data.str "r6:  " data.8 0
system_breakpoint_r7_str:  data.str "r7:  " data.8 0
system_breakpoint_r8_str:  data.str "r8:  " data.8 0
system_breakpoint_r9_str:  data.str "r9:  " data.8 0
system_breakpoint_r10_str: data.str "r10: " data.8 0
system_breakpoint_r11_str: data.str "r11: " data.8 0
system_breakpoint_r12_str: data.str "r12: " data.8 0
system_breakpoint_r13_str: data.str "r13: " data.8 0
system_breakpoint_r14_str: data.str "r14: " data.8 0
system_breakpoint_r15_str: data.str "r15: " data.8 0
system_breakpoint_r16_str: data.str "r16: " data.8 0
system_breakpoint_r17_str: data.str "r17: " data.8 0
system_breakpoint_r18_str: data.str "r18: " data.8 0
system_breakpoint_r19_str: data.str "r19: " data.8 0
system_breakpoint_r20_str: data.str "r20: " data.8 0
system_breakpoint_r21_str: data.str "r21: " data.8 0
system_breakpoint_r22_str: data.str "r22: " data.8 0
system_breakpoint_r23_str: data.str "r23: " data.8 0
system_breakpoint_r24_str: data.str "r24: " data.8 0
system_breakpoint_r25_str: data.str "r25: " data.8 0
system_breakpoint_r26_str: data.str "r26: " data.8 0
system_breakpoint_r27_str: data.str "r27: " data.8 0
system_breakpoint_r28_str: data.str "r28: " data.8 0
system_breakpoint_r29_str: data.str "r29: " data.8 0
system_breakpoint_r30_str: data.str "r30: " data.8 0
system_breakpoint_r31_str: data.str "r31: " data.8 0
system_breakpoint_rsp_str: data.str "rsp: " data.8 0
system_breakpoint_rip_str: data.str "rip: " data.8 0
