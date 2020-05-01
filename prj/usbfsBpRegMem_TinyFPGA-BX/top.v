
module top (
  input  i_pin_clk_16MHz, // TinyFPGA-BX oscillator

  inout  b_pin_usb_p,     // USB d+
  inout  b_pin_usb_n,     // USB d-
  output o_pin_pu,        // USB host-detect pull-up

  output o_pin_led
);

// PLL generated by icepll.
wire clk_48MHz;
wire pllLocked;
pll48 u_pll48 (
  .clock_in   (i_pin_clk_16MHz),
  .clock_out  (clk_48MHz),
  .locked     (pllLocked)
);

wire rst;
fpgaReset u_rst (
  .i_clk        (clk_48MHz),
  .i_pllLocked  (pllLocked),
  .o_rst        (rst)
);

reg [22:0] ledCounter_q;
always @(posedge clk_48MHz)
  if (rst)
    ledCounter_q <= 23'd0;
  else
    ledCounter_q <= ledCounter_q + 23'd1;
assign o_pin_led = ledCounter_q[22];


wire usb_p;
wire usb_n;
wire usbOutputEnable; // Select GPIO input/output mode.
wire usbTx_p;
wire usbTx_n;
wire usbRx_p;
wire usbRx_n;

// Supply receiver with J line state when transmitting.
assign usbRx_p = usbOutputEnable ? 1'b1 : usb_p;
assign usbRx_n = usbOutputEnable ? 1'b0 : usb_n;

SB_IO #(
  .PIN_TYPE (6'b101001), // PIN_OUTPUT_TRISTATE - PIN_INPUT
  .PULLUP   (1'b0)
) iobuf_usbp (
  .PACKAGE_PIN    (b_pin_usb_p),
  .OUTPUT_ENABLE  (usbOutputEnable),
  .D_OUT_0        (usbTx_p),
  .D_IN_0         (usb_p)
);

SB_IO #(
  .PIN_TYPE (6'b101001), // PIN_OUTPUT_TRISTATE - PIN_INPUT
  .PULLUP   (1'b0)
) iobuf_usbn (
  .PACKAGE_PIN    (b_pin_usb_n),
  .OUTPUT_ENABLE  (usbOutputEnable),
  .D_OUT_0        (usbTx_n),
  .D_IN_0         (usb_n)
);

assign o_pin_pu = 1'b1;


wire [7:0] devToHost_data;
wire       devToHost_valid;
wire       devToHost_ready;
wire [7:0] hostToDev_data;
wire       hostToDev_valid;
wire       hostToDev_ready;

// NOTE: Setting MAX_PKT to 8 will actually *increase* LUT usage as yosys will
// convert all the memories to flops instead of using BRAMs.
usbfsSerial #(
  .ACM_NOT_GENERIC  (1),
  .MAX_PKT  (32) // in {8,16,32,64}
) u_dev (
  .i_clk_48MHz        (clk_48MHz),
  .i_rst              (rst),

  // USB {d+, d-}, output enable.
  .i_dp               (usbRx_p),
  .i_dn               (usbRx_n),
  .o_dp               (usbTx_p),
  .o_dn               (usbTx_n),
  .o_oe               (usbOutputEnable),

  .i_devToHost_data   (devToHost_data),
  .i_devToHost_valid  (devToHost_valid),
  .o_devToHost_ready  (devToHost_ready),

  .o_hostToDev_data   (hostToDev_data),
  .o_hostToDev_valid  (hostToDev_valid),
  .i_hostToDev_ready  (hostToDev_ready)
);

bpRegMem #(
  .N_REG  (127) // in {2..127}
) u_bpRegMem128 (
  .i_clk              (clk_48MHz),
  .i_rst              (rst),
  .i_cg               (1'b1),

  .i_bp_data   (hostToDev_data),
  .i_bp_valid  (hostToDev_valid),
  .o_bp_ready  (hostToDev_ready),

  .o_bp_data   (devToHost_data),
  .o_bp_valid  (devToHost_valid),
  .i_bp_ready  (devToHost_ready)
);

endmodule
