loop:
  ld a, $00
  out ($00), a
  ld de, $8000

delay1:
  dec de
  ld a, d
  or e
  jp nz, delay1

  ld a, $ff
  out ($00), a
  ld de, $8000

delay2:
  dec de
  ld a, d
  or e
  jp nz, delay2

  jp loop
