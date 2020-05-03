`include "dff.vh"

module xoroshiro #(
  parameter WR_ACK_NOT_PREV = 0 // Writes return 0->ACK/unknown value, 1->previous value.
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

`dff_cg_srst(reg, wr, i_clk, i_cg, i_rst, '0) // 1b FSM
`dff_cg_srst(reg, rd, i_clk, i_cg, i_rst, '0) // 1b FSM
`dff_cg_norst(reg [6:0], addr, i_clk, i_cg)
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

always @* addr_d = txnBegin ?  cmdAddr : addr_q;

always @*
  if      (burstInit) burst_d = i_bp_data;
  else if (burstDecr) burst_d = burst_q - 8'd1;
  else                burst_d = burst_q;

wire memory_updt;
generate if (WR_ACK_NOT_PREV != 0) begin
  // The returned value for on writes is not necessarily the previous value
  // since memory is updated in preparation for accepting.
  // Relies on data being held steady while valid is high but ready is low.
  assign memory_updt = i_cg && wr_q && i_bp_valid; // Faster, less logic.
end else begin
  assign memory_updt = i_cg && doWrite;
end endgenerate

wire rdData_updt =
  (!wr_q && i_bp_valid) ||    // Single Read initiated
  rd_q ||                     // Burst Read in-progress
  wr_q;                       // End of Write

// The only writable thing is the 128b seed which is split into 2 addresses.
wire seedValid = memory_updt && addr_q[1]; // @2..3
reg [63:0] seedS0, seedS1;
always @* seedS0 = (addr_q[0] == 1'd0) ? {s0[55:0],  i_bp_data} : s0;
always @* seedS1 = (addr_q[0] == 1'd1) ? {s1[55:0],  i_bp_data} : s1;

wire [63:0] s0, s1, result;
prngXoroshiro128p u_prng (
  .i_clk              (i_clk),
  .i_rst              (i_rst),
  .i_cg               (i_cg),

  .i_seedValid        (seedValid),
  .i_seedS0           (seedS0),
  .i_seedS1           (seedS1),

  .o_s0               (s0),
  .o_s1               (s1),
  .o_result           (result)
);

(* mem2reg *) reg [7:0] seedReadMem [16]; // @16..31
always @* begin
  seedReadMem[0]   = s0[7:0];
  seedReadMem[1]   = s0[15:8];
  seedReadMem[2]   = s0[23:16];
  seedReadMem[3]   = s0[31:24];
  seedReadMem[4]   = s0[39:32];
  seedReadMem[5]   = s0[47:40];
  seedReadMem[6]   = s0[55:48];
  seedReadMem[7]   = s0[63:56];
  seedReadMem[8]   = s1[7:0];
  seedReadMem[9]   = s1[15:8];
  seedReadMem[10]  = s1[23:16];
  seedReadMem[11]  = s1[31:24];
  seedReadMem[12]  = s1[39:32];
  seedReadMem[13]  = s1[47:40];
  seedReadMem[14]  = s1[55:48];
  seedReadMem[15]  = s1[63:56];
end

`dff_cg_norst(reg [7:0], rdData, i_clk, i_cg && rdData_updt)
always @* rdData_d = addr_q[4] ? seedReadMem[addr_q[3:0]] :
                                ((addr_q == '0) ? '0 : result[7:0]);

// Backpressure goes straight through so destination controls all flow, so the
// sink must keep accepting data.
assign o_bp_ready = i_bp_ready && !inBurstRd;

assign o_bp_data = rdData_q;
assign o_bp_valid = rd_q;

endmodule
