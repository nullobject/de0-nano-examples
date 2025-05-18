module rom #(
  parameter MEM_INIT_FILE = "",
  parameter DEPTH = 16384,
  parameter ADDRESS_WIDTH = $clog2(DEPTH)
) (
  input clk,
  input [ADDRESS_WIDTH-1:0] addr,
  output reg [15:0] dout
);

reg [15:0] rom[0:DEPTH-1];

initial
  if (MEM_INIT_FILE != "")
    $readmemh(MEM_INIT_FILE, rom);

always @(posedge clk) begin
  dout <= rom[addr];
end

endmodule
