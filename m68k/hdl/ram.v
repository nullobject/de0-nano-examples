module ram #(
  parameter DEPTH = 16384,
  parameter ADDRESS_WIDTH = $clog2(DEPTH)
) (
  input clk,
  input we,
  input [1:0] mask,
  input [ADDRESS_WIDTH-1:0] addr,
  input [15:0] din,
  output reg [15:0] dout
);

reg [7:0] ram_lo[0:DEPTH-1];
reg [7:0] ram_hi[0:DEPTH-1];

always @(posedge clk) begin
  if (we) begin
    if (mask[0]) ram_lo[addr] <= din[7:0];
    if (mask[1]) ram_hi[addr] <= din[15:8];
  end
  dout <= {ram_hi[addr], ram_lo[addr]};
end

endmodule
