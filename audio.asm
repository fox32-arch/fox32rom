; audio routines

; use ffmpeg to convert an audio file for playback:
; ffmpeg -i input.mp3 -f s16le -ac 1 -ar 22050 audio.raw

; fox32's audio output works by swapping between two buffers
; interrupt 0xFE (vector 0x000003F8) is fired when it's time to swap buffers
; when that interrupt fires, it calls `refill_buffer` which fills up the buffer

const CURRENT_BUFFER: 0x01FFFF00
const AUDIO_POINTER: 0x01FFFF01
const AUDIO_LENGTH: 0x01FFFF05
const OLD_BUFFER_SWAP_VECTOR: 0x01FFFF09

; play an audio clip (does not block)
; inputs:
; r0: pointer to audio clip
; r1: length of audio clip in bytes (must be a multiple of 32768 bytes)
; r2: audio sample rate
; outputs:
; none
play_audio:
    push r0
    push r1

    ; set the interrupt vector for interrupt 0xFE and save the old one
    mov [OLD_BUFFER_SWAP_VECTOR], [0x000003F8]
    mov [0x000003F8], refill_buffer

    ; store audio pointer
    mov [AUDIO_POINTER], r0

    ; store audio length
    ; floor it to the nearest multiple of 32768
    and r1, 0xFFFF8000
    mov [AUDIO_LENGTH], r1

    ; reset the current buffer to zero
    ; fox32 resets its current buffer to zero internally, so reset it to zero here to stay in sync
    ; refill_buffer will bitwise not this before checking it,
    ; so set it to 0xFF so that it becomes zero when checked for the first time
    mov.8 [CURRENT_BUFFER], 0xFF

    ; enable audio playback and set sample rate
    mov r0, 0x80000600
    out r0, r2

    pop r1
    pop r0
    ret
refill_buffer:
    push r0
    push r1
    push r31

    not.8 [CURRENT_BUFFER]
    cmp.8 [CURRENT_BUFFER], 0
    ifnz jmp refill_buffer_1
refill_buffer_0:
    mov r31, 8192 ; 32768 bytes = 8192 words
    mov r0, [AUDIO_POINTER]
    mov r1, 0x0212C000 ; buffer 0 address
refill_buffer_loop:
    mov [r1], [r0]
    add r0, 4
    add r1, 4
    loop refill_buffer_loop
    mov [AUDIO_POINTER], r0
    sub [AUDIO_LENGTH], 32768
    ifz call stop_audio

    pop r31
    pop r1
    pop r0
    reti
refill_buffer_1:
    mov r31, 8192 ; 32768 bytes = 8192 words
    mov r0, [AUDIO_POINTER]
    mov r1, 0x02134000 ; buffer 1 address
    jmp refill_buffer_loop

; stop audio playback
; inputs:
; none
; outputs:
; none
stop_audio:
    push r0

    ; disable audio playback
    mov r0, 0x80000600
    out r0, 0

    ; restore the old buffer swap vector
    mov [0x000003F8], [OLD_BUFFER_SWAP_VECTOR]

    pop r0
    ret
