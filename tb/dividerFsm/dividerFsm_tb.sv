/** dividerFsm_tb.sv - Testbench for dividerFsm
 * Instance name should be u_dividerFsm_<width>_[abstract]
 * Connecting wires should be <instance>_<port>
 */
`include "asrt.svh"
`include "dff.svh"

`ifndef N_CYCLES
`define N_CYCLES 'd100000
`endif

module dividerFsm_tb (
`ifdef VERILATOR // V_erilator testbench can only drive IO from C++.
  input  wire           i_clk,
  input  wire           i_cg,
  input  wire           i_rst,

  input  wire           common_i_begin,
  input  wire [7:0]     common_i_dividend,
  input  wire [7:0]     common_i_divisor,

  output wire           dividerFsm_8_o_busy,
  output wire           dividerFsm_8_o_done,
  output wire [7:0]     dividerFsm_8_o_quotient,
  output wire [7:0]     dividerFsm_8_o_remainder,

  output wire           dividerFsm_8_abstract_o_busy,
  output wire           dividerFsm_8_abstract_o_done,
  output wire [7:0]     dividerFsm_8_abstract_o_quotient,
  output wire [7:0]     dividerFsm_8_abstract_o_remainder
`endif
);

localparam WIDTH = 8;

// {{{ clock,clockgate,reset,dump

wire clk;
reg cg;
reg rst;

generateClock u_clk (
`ifdef VERILATOR // V_erilator must drive its own root clock
  .i_rootClk        (i_clk),
`endif
  .o_clk            (clk),
  .i_periodHi       (8'd0),
  .i_periodLo       (8'd0),
  .i_jitterControl  (8'd0)
);

`dff_nocg_norst(reg [31:0], nCycles, clk)
initial nCycles_q = '0;
always @*
  nCycles_d = nCycles_q + 'd1;

`ifdef VERILATOR // V_erilator tb drives its own clockgate,reset
always @* cg = i_cg;
always @* rst = i_rst;
`else
initial cg = 1'b1;
//always @(posedge clk) cg = ($urandom_range(9, 0) != 0); // TODO: Dynamic cg.

initial rst = 1'b1;
always @*
  if (nCycles_q > 20)
    rst = 1'b0;
  else
    rst = 1'b1;

initial begin
  $dumpfile("build/dividerFsm_tb.iverilog.vcd");
  $dumpvars(0, dividerFsm_tb);
end

// Finish sim after an upper limit on the number of clock cycles.
always @* if (nCycles_q > `N_CYCLES) $finish;
`endif

// }}} clock,clockgate,reset,dump

`ifndef VERILATOR // {{{ Non-V_erilator tb
reg               common_i_begin = 0;
reg [WIDTH-1:0]   common_i_dividend;
reg [WIDTH-1:0]   common_i_divisor;

wire              dividerFsm_8_o_busy;
wire [WIDTH-1:0]  dividerFsm_8_o_quotient;
wire [WIDTH-1:0]  dividerFsm_8_o_remainder;

wire              dividerFsm_8_abstract_o_busy;
wire [WIDTH-1:0]  dividerFsm_8_abstract_o_quotient;
wire [WIDTH-1:0]  dividerFsm_8_abstract_o_remainder;

always @(posedge clk)
  if (dividerFsm_8_o_busy) begin
    common_i_begin <= 1'b0;
  end else if (!common_i_begin) begin
    common_i_begin <= ($urandom_range(9, 0) == 0);
    common_i_dividend <= $urandom_range((1 << WIDTH)-1, 0);
    common_i_divisor <= $urandom_range((1 << WIDTH)-1, 0);
  end

`endif // }}} Non-V_erilator tb

dividerFsm #(
  .WIDTH          (WIDTH),
  .ABSTRACT_MODEL (0)
) u_dividerFsm_8 (
  .i_clk      (clk),
  .i_cg       (cg),
  .i_rst      (rst),

  .i_begin    (common_i_begin),
  .i_dividend (common_i_dividend),
  .i_divisor  (common_i_divisor),

  .o_done     (dividerFsm_8_o_done),
  .o_busy     (dividerFsm_8_o_busy),
  .o_quotient (dividerFsm_8_o_quotient),
  .o_remainder(dividerFsm_8_o_remainder)
);

dividerFsm #(
  .WIDTH          (WIDTH),
  .ABSTRACT_MODEL (1)
) u_dividerFsm_8_abstract (
  .i_clk      (clk),
  .i_cg       (cg),
  .i_rst      (rst),

  .i_begin    (common_i_begin),
  .i_dividend (common_i_dividend),
  .i_divisor  (common_i_divisor),

  .o_done     (dividerFsm_8_abstract_o_done),
  .o_busy     (dividerFsm_8_abstract_o_busy),
  .o_quotient (dividerFsm_8_abstract_o_quotient),
  .o_remainder(dividerFsm_8_abstract_o_remainder)
);

`dff_cg_srst(reg, expectingResult, clk, cg, rst, '0)
always @*
  if (!dividerFsm_8_o_busy && common_i_begin)
    expectingResult_d = 1'b1;
  else if (expectingResult_q && !dividerFsm_8_o_busy)
    expectingResult_d = 1'b0;
  else
    expectingResult_d = expectingResult_q;

wire doAsserts = !rst && !dividerFsm_8_o_busy && cg && expectingResult_q;
`asrt(quotient, clk, doAsserts, dividerFsm_8_o_quotient == dividerFsm_8_abstract_o_quotient)
`asrt(remainder, clk, doAsserts, dividerFsm_8_o_remainder == dividerFsm_8_abstract_o_remainder)

endmodule

