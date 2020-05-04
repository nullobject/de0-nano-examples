  ld hl, $8000

loop:
  ld (hl), $00
  ld de, $8000

delay1:
  dec de
  ld a, d
  or e
  jp nz, delay1

  ld (hl), $ff
  ld de, $8000

delay2:
  dec de
  ld a, d
  or e
  jp nz, delay2

  jp loop
