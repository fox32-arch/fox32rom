; event system routines

const EVENT_QUEUE_TOP:    0x01FFFFFE
const EVENT_QUEUE_BOTTOM: 0x01FFFBFE ; top - 0x400 (32 events * (4 bytes * (1 type + 7 parameters)))
const EVENT_QUEUE_INDEX:  0x01FFFFFF ; byte
const EVENT_QUEUE_SIZE:   32         ; 32 events
const EVENT_SIZE_BYTES:   32         ; 32 bytes per event
const EVENT_SIZE_WORDS:   8          ; 8 words per event

; event types
const MOUSE_CLICK_EVENT_TYPE:    0x00000000
const MENU_BAR_CLICK_EVENT_TYPE: 0x00000001
const MENU_UPDATE_EVENT_TYPE:    0x00000002
const MENU_CLICK_EVENT_TYPE:     0x00000003
const EMPTY_EVENT_TYPE:          0xFFFFFFFF

; block until an event is available
; inputs:
; none
; outputs:
; r0: event type
; r1-r7: event parameters
wait_for_event:
    ise
    halt

    ; if the event queue index doesn't equal zero, then at least one event is available
    cmp.8 [EVENT_QUEUE_INDEX], 0
    ifz jmp wait_for_event

    ; an event is available in the event queue, remove it from the queue and return it
    call get_next_event

    ret

; add an event to the event queue
; inputs:
; r0: event type
; r1-r7: event parameters
; outputs:
; none
new_event:
    ; ensure there is enough space left for another event
    cmp.8 [EVENT_QUEUE_INDEX], EVENT_QUEUE_SIZE
    ifz ret

    push r8
    push r9

    ; point to the current event queue index
    mov r8, EVENT_QUEUE_BOTTOM
    movz.8 r9, [EVENT_QUEUE_INDEX]
    mul r9, EVENT_SIZE_BYTES
    add r8, r9

    ; copy the event type
    mov [r8], r0
    add r8, 4

    ; copy the event parameters
    mov [r8], r1
    add r8, 4
    mov [r8], r2
    add r8, 4
    mov [r8], r3
    add r8, 4
    mov [r8], r4
    add r8, 4
    mov [r8], r5
    add r8, 4
    mov [r8], r6
    add r8, 4
    mov [r8], r7
    add r8, 4

    ; increment the index
    inc.8 [EVENT_QUEUE_INDEX]

    pop r9
    pop r8
    ret

; get the next event and remove it from the event queue
; inputs:
; none
; outputs:
; r0: event type
; r1-r7: event parameters
get_next_event:
    ; if the event queue index equals zero, then the queue is empty
    cmp.8 [EVENT_QUEUE_INDEX], 0
    ifz jmp get_next_event_empty

    icl
    push r8

    ; point to the bottom of the event queue
    mov r8, EVENT_QUEUE_BOTTOM

    ; copy the event type
    mov r0, [r8]
    add r8, 4

    ; copy the event parameters
    mov r1, [r8]
    add r8, 4
    mov r2, [r8]
    add r8, 4
    mov r3, [r8]
    add r8, 4
    mov r4, [r8]
    add r8, 4
    mov r5, [r8]
    add r8, 4
    mov r6, [r8]
    add r8, 4
    mov r7, [r8]

    ; shift all events down by one
    call shift_events

    ; decrement the index
    dec.8 [EVENT_QUEUE_INDEX]

    pop r8
    ise
    ret
get_next_event_empty:
    mov r0, EMPTY_EVENT_TYPE
    mov r1, 0
    mov r2, 0
    mov r3, 0
    mov r4, 0
    mov r5, 0
    mov r6, 0
    mov r7, 0

    ret

; shift all events down by one, overwriting the zero'th event
; inputs:
; none
; outputs:
; none
shift_events:
    push r0
    push r1
    push r2
    push r3
    push r4

    ; for (int i = 0; i < (event_queue_index - 1); i++) {
    ;    event_queue[i] = event_queue[i + 1];
    ; }

    movz.8 r31, [EVENT_QUEUE_INDEX]
    mov r3, 0 ; i

    ; source pointer: event_queue[i + 1]
    mov r0, EVENT_QUEUE_BOTTOM
    mov r4, r3
    inc r4
    mul r4, EVENT_SIZE_WORDS
    add r0, r4

    ; destination pointer: event_queue[i]
    mov r1, EVENT_QUEUE_BOTTOM
    mov r4, r3
    mul r4, EVENT_SIZE_WORDS
    add r1, r4

    ; size: event_size_words
    mov r2, EVENT_SIZE_WORDS

    call copy_memory_words

    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    ret