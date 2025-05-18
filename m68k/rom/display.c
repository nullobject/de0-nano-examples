#include <stdint.h>

volatile uint8_t *LED = (uint8_t *)0x2000;

void __attribute__((noreturn)) main(void) {
  asm("dc.l 0x2000"); // Set stack to top of RAM
  asm("dc.l start");
  __builtin_unreachable();
}

void delay(int d) {
  for (int i = 0; i < d; i++) {
    asm("nop");
  }
}

void start(void) {
  while (1) {
    *LED = 0x1;
    delay(100000);

    *LED = 0x0;
    delay(100000);
  }
}
