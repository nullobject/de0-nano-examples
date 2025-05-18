module top (
  input clk,
  input [1:0] key,
  output reg [7:0] led,
  output reg [7:0] gpio
);

wire [23:0] cpu_addr;
wire [15:0] cpu_dout;
wire [15:0] cpu_din;
wire [15:0] rom_dout;
wire [15:0] ram_dout;
wire [7:0] acia_dout;

wire cpu_rw;    // read = 1, write = 0
wire cpu_as_n;  // address strobe
wire cpu_lds_n; // lower byte
wire cpu_uds_n; // upper byte
wire cpu_E;     // peripheral enable
wire vma_n;     // valid memory address
wire vpa_n;     // valid peripheral address

// address 0x2000 to 0x3fff used for peripherals
assign vpa_n = !(cpu_addr[15:12] > 1) | cpu_as_n;

// chip select
wire ram_cs = cpu_addr[15:12] == 1;
wire led_cs = !vma_n && cpu_addr == 16'h2000;
wire gpio_cs = !vma_n && cpu_addr == 16'h2002;

// reset
reg rst_n = 0;

always @(posedge clk) begin
  rst_n <= 1;
end

// DTACK
reg dtack_n; // Data transfer ack (always ready)

always @(posedge clk) begin
  dtack_n <= !vpa_n;
end

// LED
always @(posedge clk) begin
  if (led_cs && !cpu_rw) led <= cpu_dout;
end

// GPIO
always @(posedge clk) begin
  if (gpio_cs && !cpu_rw) gpio <= cpu_dout;
end

// phi clock
reg fx68_phi1;
reg fx68_phi2;

always @(posedge clk) begin
  fx68_phi1 <= ~fx68_phi1;
  fx68_phi2 <= fx68_phi1;
end

// decode CPU input data bus
assign cpu_din = gpio_cs ? {gpio, 8'h0} : (ram_cs ? ram_dout : rom_dout);

fx68k m68k (
  // clock/reset
  .clk(clk),
  .HALTn(1'b1),
  .extReset(!rst_n || !key[0]),
  .pwrUp(!rst_n),
  .enPhi1(fx68_phi1),
  .enPhi2(fx68_phi2),

  // output
  .eRWn(cpu_rw),
  .ASn(cpu_as_n),
  .LDSn(cpu_lds_n),
  .UDSn(cpu_uds_n),
  .E(cpu_E),
  .VMAn(vma_n),
  .FC0(),
  .FC1(),
  .FC2(),
  .BGn(),

  // input
  .DTACKn(dtack_n),
  .VPAn(vpa_n),
  .BERRn(1'b1),
  .BRn(1'b1),
  .BGACKn(1'b1),
  .IPL0n(1'b1),
  .IPL1n(1'b1),
  .IPL2n(1'b1),

  // busses
  .eab(cpu_addr[23:1]),
  .iEdb(cpu_din),
  .oEdb(cpu_dout)
);

// ROM
rom #(
  .MEM_INIT_FILE("build/display.hex"),
  .DEPTH(2048)
) prog_rom (
  .clk(clk),
  .addr(cpu_addr[11:1]),
  .dout(rom_dout)
);

// RAM
ram #(
  .DEPTH(2048)
) work_ram (
  .clk(clk),
  .we(!cpu_rw && ram_cs),
  .mask({!cpu_uds_n, !cpu_lds_n}),
  .addr(cpu_addr[11:1]),
  .din(cpu_dout),
  .dout(ram_dout)
);

endmodule
