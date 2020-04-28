`include "dff.vh"

/* BytePipe interface, indended to sit on top of USB for register access.

- BytePipe has been designed with these goals:
  1. Very low cost to implement (approximately 17 dff, plus memory),
  2. Simple to reset to a known state.
  3. Simple and efficient mechanism for confirming that state *was* what you
     expected it to be as you update (functional monitoring).
  4. Efficient polling loops for non-linear sequences of addresses.

- All addressable locations are 1B wide.
- Up to 127 writable locations, 128 readable locations.
  Location 0 is reserved for the writing the burst counter, but may be read to
  provide a status, config, or magic value.
- Non-implemented addresses always read as 0.
  This allows all writeable bits to be discovered by writing `0xff` to each
  position, inspecting the result.
- All non-burst transactions generate 1B response.
- Write transaction sends cmd+address byte, then data byte, then receives 1B
  with previous/overwritten value at that address.
  The received value serves as a write-response to confirm that the write has
  taken place.
- Read transaction sends cmd+address byte, then receives 1B with the value at
  the previous address.
*/
module bpRegMem #(
  parameter ZERO_UNIMPL = 1, // Unimplemented locations return 0->unknown, 1->zero.
  parameter VALUE0 = 8'd0, // in {0x00..0xff}. Arbitrary value read from location 0.
  parameter N_REG = 63  // in {2..127}. Number of registers to implement.
) (
  input wire          i_clk,
  input wire          i_rst,
  input wire          i_cg,

  input  wire [7:0]   i_bp_data,
  input  wire         i_bp_valid,
  output wire         o_bp_ready,

  output wire [7:0]   o_bp_data,
  output wire         o_bp_valid,
  input  wire         i_bp_ready
);

localparam N_LOC = N_REG+1;
localparam ADDR_W = $clog2(N_LOC);
localparam ADDR_REG_LO = 1;
localparam ADDR_REG_HI = ADDR_REG_LO + N_REG - 1;

`dff_cg_srst(reg, wr, i_clk, i_cg, i_rst, '0) // 1b FSM
`dff_cg_srst(reg, rd, i_clk, i_cg, i_rst, '0) // 1b FSM
//`dff_cg_norst(reg [ADDR_W-1:0], addr, i_clk, i_cg)
//`dff_cg_srst(reg [ADDR_W-1:0], addr, i_clk, i_cg, i_rst, '0)
//`dff_cg_srst(reg [ADDR_W-1:0], addr, i_clk, i_cg, i_rst, '1)
`dff_cg_srst(reg [6:0], addr, i_clk, i_cg, i_rst, '1)
`dff_cg_srst(reg [7:0], rdData, i_clk, i_cg, i_rst, '0)
`dff_cg_srst(reg [7:0], burst, i_clk, i_cg, i_rst, '0) // 8b downcounter

// IO aliases
wire in_accepted = i_bp_valid && o_bp_ready;
wire out_accepted = o_bp_valid && i_bp_ready;
wire cmdWr = i_bp_data[7];
wire cmdRd = !i_bp_data[7];
wire [6:0] cmdAddr = i_bp_data[6:0];

wire txnBegin = !wr_q && in_accepted;
wire inBurst = (burst_q != '0) && (addr_q != '0);
wire inBurstWr = inBurst && wr_q;
wire inBurstRd = inBurst && rd_q;
wire doWrite = wr_q && in_accepted;
wire addrInRange;
generate if (N_REG == 127) begin
  assign addrInRange = 1'b1;
end else begin
  assign addrInRange = (ADDR_REG_HI[6:0] >= addr_q);
end endgenerate

wire wrSet = txnBegin && cmdWr;
wire wrClr = doWrite && !inBurst;
wire rdSet = (txnBegin && cmdRd) || wrClr;
wire rdClr = out_accepted && !inBurst;
wire burstInit = doWrite && (addr_q == '0);
wire burstDecr = (inBurstWr && in_accepted) || (inBurstRd && out_accepted);

always @*
  if      (wrSet) wr_d = 1'b1;
  else if (wrClr) wr_d = 1'b0;
  else            wr_d = wr_q;

always @*
  if      (rdSet) rd_d = 1'b1;
  else if (rdClr) rd_d = 1'b0;
  else            rd_d = rd_q;

always @* addr_d = txnBegin ?
  //cmdAddr[ADDR_W-1:0] :
  cmdAddr :
  addr_q;

always @*
  if      (burstInit) burst_d = i_bp_data;
  else if (burstDecr) burst_d = burst_q - 8'd1;
  else                burst_d = burst_q;

(* mem2reg *) reg [7:0] memory_m [N_REG]; // dff_cg_norst
genvar r;
generate for (r = 0; r < N_REG; r=r+1) begin : reg_b
  localparam a = r+1;
  always @(posedge i_clk)
    if (i_cg && doWrite && (addr_q == a[6:0]))
      memory_m[r] <= i_bp_data;
end : reg_b endgenerate

wire [6:0] regAddr = addr_q - 7'd1;
wire [$clog2(N_REG)-1:0] rdAddr = regAddr[$clog2(N_REG)-1:0];
always @*
  if (rd_d)
    if (addr_q == '0)
      rdData_d = VALUE0;
    else if (addrInRange)
      rdData_d = memory_m[rdAddr];
    else
      rdData_d = '0;
  else
    rdData_d = rdData_q;

// Backpressure goes straight through so destination controls all flow, so the
// sink must keep accepting data.
assign o_bp_ready = i_bp_ready && !inBurstRd;

assign o_bp_data = rdData_q;
assign o_bp_valid = rd_q;

endmodule
