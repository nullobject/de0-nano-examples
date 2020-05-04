  ld sp, $2000

loop:
  ld a, $00
  out ($00), a

  call delay

  ld a, $ff
  out ($00), a

  call delay

  jp loop

; wait for 1s
delay:
  ld de, $8000
_delay:
  dec de
  ld a, d
  or e
  jp nz, _delay
  ret
