MEMORY
{
  rom_vectors (rx) : ORIGIN = 0x00, LENGTH = 0x0010
  rom_code    (rx) : ORIGIN = 0x10, LENGTH = 0x1000
}

SECTIONS
{
  .text.startup :
  {
    *(.text.startup)
  } > rom_vectors

  .text :
  {
    *(.text)
  } > rom_code
}

OUTPUT_FORMAT(binary)
