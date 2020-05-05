STACK_ADDR: equ $2000 ; stack address
DELAY_DURATION: equ $8000; 1 second

  di
  ld sp, STACK_ADDR

start:
  ld a, $00
  out ($00), a

  ld bc, DELAY_DURATION
  call delay

  ld a, $ff
  out ($00), a

  ld bc, DELAY_DURATION
  call delay

  jp start

; Delays for a duration.
;
; bc - duration
delay:
  dec bc
  ld a, b
  or c
  jp nz, delay
  ret
