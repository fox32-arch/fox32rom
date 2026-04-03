; fox32 opcode disassembler

; disassemble instruction(s) at the given address
; inputs:
; r0: address to disassemble from
; r1: number of instructions to disassemble
; outputs:
; r0: address of next instruction
monitor_disassemble:
    cmp r1, 0
    ifz mov r1, 8
    mov r31, r1
monitor_disassemble_loop:
    push r0
    call print_hex_word_to_monitor
    mov r0, ' '
    call print_character_to_monitor
    mov r0, '|'
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor
    pop r0

    movz.8 r2, [r0+1] ; load instruction
    movz.8 r8, [r0]   ; load modifiers
    mov r3, r2
    and r2, 0b11000000 ; mask off the instruction bits
    srl r2, 6
    and r3, 0b00111111 ; mask off the size bits
    mov r4, instruction_table
    mov r6, 2 ; size of this in-flight instruction
    mov r1, NUM_INSTRUCTIONS
monitor_disassemble_find_instr_loop:
    cmp.8 [r4], r3
    ifz jmp monitor_disassemble_found_instr
    inc r4, 8
    dec r1
    ifnz jmp monitor_disassemble_find_instr_loop
monitor_disassemble_bad_instr:
    push r0
    mov r0, instr_error_str
    call print_string_to_monitor
    pop r0
    jmp monitor_disassemble_loop_end
monitor_disassemble_found_instr:
    movz.8 r5, [r4+1] ; get the number of operands

    ; print the condition
    push r0
    mov r0, r8
    srl r0, 4
    and r0, 0b00000111
    cmp r0, NUM_CONDITIONS
    ifgteq pop r0
    ifgteq jmp monitor_disassemble_bad_instr
    mul r0, 8
    add r0, condition_table
    call print_string_to_monitor
    ; print the instruction
    mov r0, r4
    inc r0, 2
    call print_string_to_monitor
    ; print the size
    mov r0, r2
    mul r0, 5
    add r0, size_table
    call print_string_to_monitor
    pop r0

    mov r7, 0
    cmp r5, 0
    ifz jmp monitor_disassemble_loop_end
    ; handle destination operand
    cmp r5, 1
    ifz jmp monitor_disassemble_print_source
    ; determine source length so we can skip over it for now
    push r6
    mov r9, r8
    and r9, 0b00000011
    cmp r9, 0
    ifz call monitor_disassemble_oper_reg_add_size
    cmp r9, 1
    ifz call monitor_disassemble_oper_regptr_add_size
    cmp r9, 2
    ifz call monitor_disassemble_oper_imm_add_size
    cmp r9, 3
    ifz call monitor_disassemble_oper_immptr_add_size
    ; print destination operand
    mov r9, r8
    and r9, 0b00001100
    srl r9, 2
    cmp r9, 0
    ifz call monitor_disassemble_oper_reg
    cmp r9, 1
    ifz call monitor_disassemble_oper_regptr
    cmp r9, 2
    ifz call monitor_disassemble_oper_imm
    cmp r9, 3
    ifz call monitor_disassemble_oper_immptr
    push r0
    mov r0, ','
    call print_character_to_monitor
    mov r0, ' '
    call print_character_to_monitor
    pop r0
    mov r7, r6 ; r7 = position *after* dest
    pop r6 ; r6 = position of source
monitor_disassemble_print_source:
    ; print source operand
    mov r9, r8
    and r9, 0b00000011
    cmp r9, 0
    ifz call monitor_disassemble_oper_reg
    cmp r9, 1
    ifz call monitor_disassemble_oper_regptr
    cmp r9, 2
    ifz call monitor_disassemble_oper_imm
    cmp r9, 3
    ifz call monitor_disassemble_oper_immptr
monitor_disassemble_loop_end:
    push r0
    mov r0, 10
    call print_character_to_monitor
    pop r0
    cmp r7, 0
    ifnz add r0, r7 ; r7 = position *after* dest
    ifz add r0, r6 ; r6 = position *after* source

    ; DEBUG !!!
    ;push r0
    ;mov r0, r6
    ;call print_hex_word_to_monitor
    ;mov r0, ' '
    ;call print_character_to_monitor
    ;mov r0, r7
    ;call print_hex_word_to_monitor
    ;pop r0

    loop monitor_disassemble_loop
    ret
monitor_disassemble_oper_reg:
    push r0
    mov r0, 'r'
    call print_character_to_monitor
    pop r0
    push r0
    add r0, r6
    movz.8 r0, [r0] ; get register number
    call print_register
    pop r0
    jmp monitor_disassemble_oper_reg_add_size
monitor_disassemble_oper_regptr:
    push r0
    mov r0, '['
    call print_character_to_monitor
    mov r0, 'r'
    call print_character_to_monitor
    pop r0
    push r0
    add r0, r6
    movz.8 r0, [r0] ; get register number
    call print_register
    bts r8, 7
    ifz jmp monitor_disassemble_oper_regptr_no_offset
    mov r0, '+'
    call print_character_to_monitor
    pop r0
    push r0
    add r0, r6
    movz.8 r0, [r0+1] ; get offset
    call print_dec_to_monitor
monitor_disassemble_oper_regptr_no_offset:
    mov r0, ']'
    call print_character_to_monitor
    pop r0
    jmp monitor_disassemble_oper_regptr_add_size
monitor_disassemble_oper_imm:
    push r0
    add r0, r6
    cmp r2, 0
    ifz movz.8 r0, [r0] ; get immediate byte
    cmp r2, 1
    ifz movz.16 r0, [r0] ; get immediate half
    cmp r2, 2
    ifz mov r0, [r0] ; get immediate word
    call print_hex_word_to_monitor
    pop r0
    jmp monitor_disassemble_oper_imm_add_size
monitor_disassemble_oper_immptr:
    push r0
    mov r0, '['
    call print_character_to_monitor
    pop r0
    push r0
    add r0, r6
    mov r0, [r0] ; get immediate word
    call print_hex_word_to_monitor
    mov r0, ']'
    call print_character_to_monitor
    pop r0
    jmp monitor_disassemble_oper_immptr_add_size

monitor_disassemble_oper_reg_add_size:
    inc r6 ; reg operand takes 1 byte
    ret
monitor_disassemble_oper_regptr_add_size:
    inc r6 ; regptr operand takes 1 byte or 2 bytes
    bts r8, 7 ; is there an offset?
    ifnz inc r6
    ret
monitor_disassemble_oper_imm_add_size:
    cmp r2, 0 ; imm operand takes 1, 2, or 4 bytes depending on the operation size
    ifz inc r6
    cmp r2, 1
    ifz inc r6, 2
    cmp r2, 2
    ifz inc r6, 4
    ret
monitor_disassemble_oper_immptr_add_size:
    inc r6, 4 ; immptr operand takes 4 bytes
    ret

print_register:
    cmp r0, 32
    ifz jmp print_register_rsp
    cmp r0, 33
    ifz jmp print_register_resp
    cmp r0, 34
    ifz jmp print_register_rfp
    call print_dec_to_monitor
    ret
print_register_rsp:
    mov r0, print_register_rsp_str
    jmp print_register_str
print_register_resp:
    mov r0, print_register_resp_str
    jmp print_register_str
print_register_rfp:
    mov r0, print_register_rfp_str
print_register_str:
    call print_string_to_monitor
    ret
print_register_rsp_str: data.strz "sp"
print_register_resp_str: data.strz "esp"
print_register_rfp_str: data.strz "fp"

instr_error_str: data.strz "<bad opcode>"

const NUM_SIZES: 3
size_table:
    data.strz ".8  "
    data.strz ".16 "
    data.strz " "

const NUM_CONDITIONS: 9
condition_table:
    data.strz "       "
    data.strz "ifz    "
    data.strz "ifnz   "
    data.strz "ifc    "
    data.strz "iflt   "
    data.strz "ifnc   "
    data.strz "ifgteq "
    data.strz "ifgt   "
    data.strz "iflteq "

const NUM_INSTRUCTIONS: 49
instruction_table:
    ; opcode    # opers  mnemonic         padding
    data.8 0x00 data.8 0 data.str "nop"   data.fill 0, 3
    data.8 0x01 data.8 2 data.str "add"   data.fill 0, 3
    data.8 0x02 data.8 2 data.str "mul"   data.fill 0, 3
    data.8 0x03 data.8 2 data.str "and"   data.fill 0, 3
    data.8 0x04 data.8 2 data.str "sla"   data.fill 0, 3
    data.8 0x05 data.8 2 data.str "sra"   data.fill 0, 3
    data.8 0x06 data.8 2 data.str "bse"   data.fill 0, 3
    data.8 0x07 data.8 2 data.str "cmp"   data.fill 0, 3
    data.8 0x08 data.8 1 data.str "jmp"   data.fill 0, 3
    data.8 0x09 data.8 1 data.str "rjmp"  data.fill 0, 2
    data.8 0x0A data.8 1 data.str "push"  data.fill 0, 2
    data.8 0x0B data.8 2 data.str "in"    data.fill 0, 4
    data.8 0x0C data.8 0 data.str "ise"   data.fill 0, 3
    data.8 0x0D data.8 0 data.str "mse"   data.fill 0, 3
    data.8 0x10 data.8 0 data.str "halt"  data.fill 0, 2
    data.8 0x11 data.8 1 data.str "inc"   data.fill 0, 3
    data.8 0x13 data.8 2 data.str "or"    data.fill 0, 4
    data.8 0x14 data.8 2 data.str "imul"  data.fill 0, 2
    data.8 0x15 data.8 2 data.str "srl"   data.fill 0, 3
    data.8 0x16 data.8 2 data.str "bcl"   data.fill 0, 3
    data.8 0x17 data.8 2 data.str "mov"   data.fill 0, 3
    data.8 0x18 data.8 1 data.str "call"  data.fill 0, 2
    data.8 0x19 data.8 1 data.str "rcall" data.fill 0, 1
    data.8 0x1A data.8 1 data.str "pop"   data.fill 0, 3
    data.8 0x1B data.8 2 data.str "out"   data.fill 0, 3
    data.8 0x1C data.8 0 data.str "icl"   data.fill 0, 3
    data.8 0x1D data.8 0 data.str "mcl"   data.fill 0, 3
    data.8 0x20 data.8 0 data.str "brk"   data.fill 0, 3
    data.8 0x21 data.8 2 data.str "sub"   data.fill 0, 3
    data.8 0x22 data.8 2 data.str "div"   data.fill 0, 3
    data.8 0x23 data.8 2 data.str "xor"   data.fill 0, 3
    data.8 0x24 data.8 2 data.str "rol"   data.fill 0, 3
    data.8 0x25 data.8 2 data.str "ror"   data.fill 0, 3
    data.8 0x26 data.8 2 data.str "bts"   data.fill 0, 3
    data.8 0x27 data.8 2 data.str "movz"  data.fill 0, 2
    data.8 0x28 data.8 1 data.str "loop"  data.fill 0, 2
    data.8 0x29 data.8 1 data.str "rloop" data.fill 0, 1
    data.8 0x2A data.8 0 data.str "ret"   data.fill 0, 3
    data.8 0x2C data.8 1 data.str "int"   data.fill 0, 3
    data.8 0x2D data.8 1 data.str "tlb"   data.fill 0, 3
    data.8 0x31 data.8 1 data.str "dec"   data.fill 0, 3
    data.8 0x32 data.8 2 data.str "rem"   data.fill 0, 3
    data.8 0x33 data.8 1 data.str "not"   data.fill 0, 3
    data.8 0x34 data.8 2 data.str "idiv"  data.fill 0, 2
    data.8 0x35 data.8 2 data.str "irem"  data.fill 0, 2
    data.8 0x37 data.8 2 data.str "icmp"  data.fill 0, 2
    data.8 0x39 data.8 2 data.str "rta"   data.fill 0, 3
    data.8 0x3A data.8 0 data.str "reti"  data.fill 0, 2
    data.8 0x3D data.8 1 data.str "flp"   data.fill 0, 3
