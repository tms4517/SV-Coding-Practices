/** Testbench for USB Full Speed transactions.
 *
 * 1. usbFullSpeedTransactor[host] (verif) <--> usbFullSpeedTransactor[device] (verif)
 */
`include "asrt.svh"
`include "dff.svh"

module usbFullSpeedTransactions_tb (
`ifdef VERILATOR // V_erilator testbench can only drive IO from C++.
  `error No Verilator testbench here!
  input wire i_rootClk,
`endif
);

`include "usbSpec.svh"

localparam HOST2DEV_N_ENDP = 2;
localparam DEV2HOST_N_ENDP = 2;
localparam MAX_PKT = 8;
localparam DATA_W = 8*MAX_PKT;
localparam NBYTES_W = $clog2(MAX_PKT)+1;

wire       host_o_txnReady;
wire       host_i_txnValid;
wire [2:0] drvHost_o_txnType;
wire [6:0] drvHost_o_txnAddr;
wire [3:0] drvHost_o_txnEndp;

wire  host_i_dp, dev_i_dp;
wire  host_i_dn, dev_i_dn;
wire  host_o_dp, dev_o_dp;
wire  host_o_dn, dev_o_dn;
wire  host_o_oe, dev_o_oe;

wire [HOST2DEV_N_ENDP-1:0]  host_i_etValid, host_o_etReady,
                             dev_o_erValid,  dev_i_erReady;

wire [DEV2HOST_N_ENDP-1:0]   dev_i_etValid,  dev_o_etReady,
                            host_o_erValid, host_i_erReady;

wire [DATA_W-1:0]        host_o_erData,        dev_o_erData;
wire [NBYTES_W-1:0]    host_o_erData_nBytes, dev_o_erData_nBytes;

wire [HOST2DEV_N_ENDP*DATA_W-1:0] host_i_etData;
wire [DEV2HOST_N_ENDP*DATA_W-1:0] dev_i_etData;
wire [HOST2DEV_N_ENDP*NBYTES_W-1:0] host_i_etData_nBytes;
wire [DEV2HOST_N_ENDP*NBYTES_W-1:0] dev_i_etData_nBytes;

wire [HOST2DEV_N_ENDP-1:0]  host_i_etStall, dev_i_erStall;
wire [DEV2HOST_N_ENDP-1:0]  host_i_erStall, dev_i_etStall;

wire [10:0] host_o_frameNumber, dev_o_frameNumber;
wire [2:0]  host_o_txnType,     dev_o_txnType;


wire clk_12MHz;
wire clk_48MHz;
reg rst;

`ifndef VERILATOR // {{{ Non-V_erilator tb

initial begin
  $dumpfile("build/usbFullSpeedTransactions_tb.iverilog.vcd");
  $dumpvars(0, usbFullSpeedTransactions_tb);
end

driveTransactions v_driveTransactions ( // {{{
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .i_ready                  (host_o_txnReady),
  .o_valid                  (host_i_txnValid),

  .o_txnType                (drvHost_o_txnType),
  .o_txnAddr                (drvHost_o_txnAddr),
  .o_txnEndp                (drvHost_o_txnEndp)
); // }}} v_driveTransactions

`endif // }}} Non-V_erilator tb

// NOTE: Both host and dev run from the same clock which obviously can't be true
// for an implementation, but because the sync mechanism (strobe 12MHz) is shown
// to work in tb/usbFullSpeedPackets, it's good enough for testing the
// tranactor.
generateClock u_clk_48MHz (
`ifdef VERILATOR // V_erilator must drive its own root clock
  .i_rootClk        (i_rootClk),
`endif
  .o_clk            (clk_48MHz),
  .i_periodHi       (8'd0),
  .i_periodLo       (8'd0),
  .i_jitterControl  (8'd0)
);

`dff_nocg_norst(reg [31:0], nCycles, clk_48MHz)
initial nCycles_q = '0;
always @*
  nCycles_d = nCycles_q + 'd1;

initial rst = 1'b1;
always @*
  if (nCycles_q > 20)
    rst = 1'b0;
  else
    rst = 1'b1;

wire host_txn_accepted = host_o_txnReady && host_i_txnValid;
`dff_nocg_srst(reg [31:0], nTxns, clk_48MHz, rst, '0)
always @*
  if (host_txn_accepted)
    nTxns_d = nTxns_q + 1;
  else
    nTxns_d = nTxns_q;

// Finish sim after an upper limit on the number of clock cycles, or USB
// transactions sent.
always @*
  if ((nCycles_q > 500000) || (nTxns_q > 1000))
    $finish;

// Should not accept another packet while one is inflight.
`asrt(drvAccept, clk_48MHz, !rst, !((host_o_txnType != '0) && host_txn_accepted))

usbFullSpeedTransactor #( // {{{ v_host
  .AS_HOST_NOT_DEV  (1),
  .RX_N_ENDP        (DEV2HOST_N_ENDP),
  .TX_N_ENDP        (HOST2DEV_N_ENDP),
  .RX_ISOCHRONOUS   (0),
  .TX_ISOCHRONOUS   (0),
  .TX_ISOCHRONOUS   (0),
  .RX_STALLABLE     (0),
  .TX_STALLABLE     (0),
  .MAX_PKT          (MAX_PKT)
) v_host (
  .i_clk_48MHz              (clk_48MHz),
  .i_rst                    (rst),

  // USB {d+, d-}, output enable.
  .i_dp                     (host_i_dp),
  .i_dn                     (host_i_dn),
  .o_dp                     (host_o_dp),
  .o_dn                     (host_o_dn),
  .o_oe                     (host_o_oe),

  // Endpoints receiving data (DEV2HOST_N_ENDP)
  .i_erReady                (host_i_erReady),
  .o_erValid                (host_o_erValid),
  .o_erData                 (host_o_erData),
  .o_erData_nBytes          (host_o_erData_nBytes),

  // Endpoints transmitting data (HOST2DEV_N_ENDP)
  .o_etReady                (host_o_etReady),
  .i_etValid                (host_i_etValid),
  .i_etData                 (host_i_etData), // {epPktN, ..., epPkt0}
  .i_etData_nBytes          (host_i_etData_nBytes),

  // Endpoints are stalled or not.
  // Only used if corresponding bit in *X_STALLABLE is set.
  .i_erStall                (host_i_erStall),
  .i_etStall                (host_i_etStall),

  // Current state of transaction flags $onehot({SETUP, OUT, IN}).
  // Mostly useful in dev-mode.
  .o_txnType                (host_o_txnType),

  // Current frame number.
  // NOTE: Endpoints are not required to do anything with this.
  // Host-mode --> Counter value.
  // Device-mode --> Frame number from token[SOF].
  .o_frameNumber            (host_o_frameNumber),

  // Device address, endpoint, and type of next transaction
  // to perform.
  // Host-mode only. Interface unused in dev-mode.
  .o_txnReady               (host_o_txnReady),
  .i_txnValid               (host_i_txnValid),
  .i_txnType                (drvHost_o_txnType), // {SETUP, OUT, IN}
  .i_txnAddr                (drvHost_o_txnAddr),
  .i_txnEndp                (drvHost_o_txnEndp),

  // Dev-mode only. Unused in host-mode. Input comes from endpoint0.
  // Device address, initially the Default Address (0), but configured with a
  // Setup transfer to the Default Endpoint (0).
  // In host-mode this sets the device address for the next transaction and will
  // not be sampled whilst any transaction is outstanding.
  .i_devAddr                (7'd0)
); // }}} v_host

driveEndpointTx #( // {{{ v_hostEt0
  .MAX_PKT          (MAX_PKT)
) v_hostEt0 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_etStall                (host_i_etStall[0]),

  .i_etReady                (host_o_etReady[0]),
  .o_etValid                (host_i_etValid[0]),
  .o_etData                 (host_i_etData[0*DATA_W +: DATA_W]),
  .o_etData_nBytes          (host_i_etData_nBytes[0*NBYTES_W +: NBYTES_W]),

  .i_txnType                (host_o_txnType)
); // }}} v_hostEt0
driveEndpointTx #( // {{{ v_hostEt1
  .MAX_PKT          (MAX_PKT)
) v_hostEt1 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_etStall                (host_i_etStall[1]),

  .i_etReady                (host_o_etReady[1]),
  .o_etValid                (host_i_etValid[1]),
  .o_etData                 (host_i_etData[1*DATA_W +: DATA_W]),
  .o_etData_nBytes          (host_i_etData_nBytes[1*NBYTES_W +: NBYTES_W]),

  .i_txnType                (host_o_txnType)
); // }}} v_hostEt1
driveEndpointRx #( // {{{ v_hostEr0
  .MAX_PKT          (MAX_PKT)
) v_hostEr0 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_erStall                (host_i_erStall[0]),

  .o_erReady                (host_i_erReady[0]),
  .i_erValid                (host_o_erValid[0]),
  .i_erData                 (host_o_erData),
  .i_erData_nBytes          (host_o_erData_nBytes),

  .i_txnType                (host_o_txnType)
); // }}} v_hostEr0
driveEndpointRx #( // {{{ v_hostEr1
  .MAX_PKT          (MAX_PKT)
) v_hostEr1 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_erStall                (host_i_erStall[1]),

  .o_erReady                (host_i_erReady[1]),
  .i_erValid                (host_o_erValid[1]),
  .i_erData                 (host_o_erData),
  .i_erData_nBytes          (host_o_erData_nBytes),

  .i_txnType                (host_o_txnType)
); // }}} v_hostEr1

wire usb_dp, usb_dn;
tristateBuffer host_dp (
  .i_outputEnable(host_o_oe),
  .o_xIn  (host_i_dp),
  .i_xOut (host_o_dp),
  .b_xIO  (usb_dp)
);
tristateBuffer dev_dp (
  .i_outputEnable(dev_o_oe),
  .o_xIn  (dev_i_dp),
  .i_xOut (dev_o_dp),
  .b_xIO  (usb_dp)
);
tristateBuffer host_dn (
  .i_outputEnable(host_o_oe),
  .o_xIn  (host_i_dn),
  .i_xOut (host_o_dn),
  .b_xIO  (usb_dn)
);
tristateBuffer dev_dn (
  .i_outputEnable(dev_o_oe),
  .o_xIn  (dev_i_dn),
  .i_xOut (dev_o_dn),
  .b_xIO  (usb_dn)
);
`asrt(dp_oe, clk_48MHz, !rst, $onehot0({host_o_oe, dev_o_oe}))

usbFullSpeedTransactor #( // {{{ v_dev
  .AS_HOST_NOT_DEV  (0),
  .RX_N_ENDP        (HOST2DEV_N_ENDP),
  .TX_N_ENDP        (DEV2HOST_N_ENDP),
  .RX_ISOCHRONOUS   (0),
  .TX_ISOCHRONOUS   (0),
  .TX_ISOCHRONOUS   (0),
  .RX_STALLABLE     (0),
  .TX_STALLABLE     (1), // Endpoint0 can stall for unsupported descriptors.
  .MAX_PKT          (MAX_PKT)
) v_dev (
  .i_clk_48MHz              (clk_48MHz),
  .i_rst                    (rst),

  // USB {d+, d-}, output enable.
  .i_dp                     (dev_i_dp),
  .i_dn                     (dev_i_dn),
  .o_dp                     (dev_o_dp),
  .o_dn                     (dev_o_dn),
  .o_oe                     (dev_o_oe),

  // Endpoints receiving data (HOST2DEV_N_ENDP)
  .i_erReady                (dev_i_erReady),
  .o_erValid                (dev_o_erValid),
  .o_erData                 (dev_o_erData),
  .o_erData_nBytes          (dev_o_erData_nBytes),

  // Endpoints transmitting data (DEV2HOST_N_ENDP)
  .o_etReady                (dev_o_etReady),
  .i_etValid                (dev_i_etValid),
  .i_etData                 (dev_i_etData), // {epPktN, ..., epPkt0}
  .i_etData_nBytes          (dev_i_etData_nBytes),

  // Endpoints are stalled or not.
  // Only used if corresponding bit in *X_STALLABLE is set.
  .i_erStall                (dev_i_erStall),
  .i_etStall                (dev_i_etStall),

  // Current state of transaction flags $onehot({SETUP, OUT, IN}).
  // Mostly useful in dev-mode.
  .o_txnType                (dev_o_txnType),

  // Current frame number.
  // NOTE: Endpoints are not required to do anything with this.
  // Host-mode --> Counter value.
  // Device-mode --> Frame number from token[SOF].
  .o_frameNumber            (dev_o_frameNumber),

  // Device address, endpoint, and type of next transaction
  // to perform.
  // Host-mode only. Interface unused in dev-mode.
  .o_txnReady               (),
  .i_txnValid               (1'b0),
  .i_txnType                (3'b000), // {SETUP, OUT, IN}
  .i_txnAddr                (7'd0),
  .i_txnEndp                (4'd0),

  // Dev-mode only. Unused in host-mode. Input comes from endpoint0.
  // Device address, initially the Default Address (0), but configured with a
  // Setup transfer to the Default Endpoint (0).
  // In host-mode this sets the device address for the next transaction and will
  // not be sampled whilst any transaction is outstanding.
  .i_devAddr                (7'd0) // TODO: from endpoint0 driver.
); // }}} v_dev

driveEndpointRx #( // {{{ v_devEr0
  .MAX_PKT          (MAX_PKT)
) v_devEr0 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_erStall                (dev_i_erStall[0]),

  .o_erReady                (dev_i_erReady[0]),
  .i_erValid                (dev_o_erValid[0]),
  .i_erData                 (dev_o_erData),
  .i_erData_nBytes          (dev_o_erData_nBytes),

  .i_txnType                (dev_o_txnType)
); // }}} v_devEr0
driveEndpointRx #( // {{{ v_devEr1
  .MAX_PKT          (MAX_PKT)
) v_devEr1 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_erStall                (dev_i_erStall[1]),

  .o_erReady                (dev_i_erReady[1]),
  .i_erValid                (dev_o_erValid[1]),
  .i_erData                 (dev_o_erData),
  .i_erData_nBytes          (dev_o_erData_nBytes),

  .i_txnType                (dev_o_txnType)
); // }}} v_devEr1
driveEndpointTx #( // {{{ v_devEt0
  .MAX_PKT          (MAX_PKT)
) v_devEt0 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_etStall                (dev_i_etStall[0]),

  .i_etReady                (dev_o_etReady[0]),
  .o_etValid                (dev_i_etValid[0]),
  .o_etData                 (dev_i_etData[0*DATA_W +: DATA_W]),
  .o_etData_nBytes          (dev_i_etData_nBytes[0*NBYTES_W +: NBYTES_W]),

  .i_txnType                (dev_o_txnType)
); // }}} v_devEt0
driveEndpointTx #( // {{{ v_devEt1
  .MAX_PKT          (MAX_PKT)
) v_devEt1 (
  .i_clk                    (clk_48MHz),
  .i_rst                    (rst),

  .o_etStall                (dev_i_etStall[1]),

  .i_etReady                (dev_o_etReady[1]),
  .o_etValid                (dev_i_etValid[1]),
  .o_etData                 (dev_i_etData[1*DATA_W +: DATA_W]),
  .o_etData_nBytes          (dev_i_etData_nBytes[1*NBYTES_W +: NBYTES_W]),

  .i_txnType                (dev_o_txnType)
); // }}} v_devEt1

endmodule

