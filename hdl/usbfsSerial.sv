`include "asrt.svh"
`include "dff.svh"

module usbfsSerial #(
  parameter VIDPID_SQUAT = 1,
  parameter ACM_NOT_GENERIC = 0,
  parameter MAX_PKT = 8  // in {8,16,32,64}. wMaxPacketSize
) (
  input  wire                       i_clk_48MHz,
  input  wire                       i_rst,

  // USB {d+, d-}, output enable.
  input  wire                       i_dp,
  input  wire                       i_dn,
  output wire                       o_dp,
  output wire                       o_dn,
  output wire                       o_oe,

  output wire                       o_devToHost_ready,
  input  wire                       i_devToHost_valid,
  input  wire [7:0]                 i_devToHost_data,

  input  wire                       i_hostToDev_ready,
  output wire                       o_hostToDev_valid,
  output wire [7:0]                 o_hostToDev_data
);
/*
The OpenMoko project act as an unofficial database of product IDs for FOSS
projects, issuing them free of charge for suitable projects.
http://wiki.openmoko.org/wiki/USB_Product_IDs
https://raw.githubusercontent.com/openmoko/openmoko-usb-oui/master/usb_product_ids.psv
Links working as of 2019-11-27

OpenMoko VID is 0x1D50
PID 0xF055 is just a placeholder.

NetChip Technologies VID:PID for debug with usbserial as suggested by kernel doc.
*/
localparam NETCHIP_VID = 16'h0525;
localparam USBSERIAL_PID = 16'ha4a6;
localparam VENDOR_ID = VIDPID_SQUAT ? NETCHIP_VID : 16'h1D50;
localparam PRODUCT_ID = VIDPID_SQUAT ? USBSERIAL_PID : 16'hF055;

localparam HOST2DEV_N_ENDP = 2;
localparam DEV2HOST_N_ENDP = 2;
localparam DATA_W = 8*MAX_PKT;
localparam NBYTES_W = $clog2(MAX_PKT + 1);
localparam RDIDX_W = $clog2(MAX_PKT);
localparam WRIDX_W = $clog2(MAX_PKT);

wire [HOST2DEV_N_ENDP-1:0]  dev_o_erValid, dev_i_erReady, dev_i_erStall;
wire [DEV2HOST_N_ENDP-1:0]  dev_i_etValid, dev_o_etReady, dev_i_etStall;

wire [HOST2DEV_N_ENDP-1:0]          dev_i_erRdEn;
wire [HOST2DEV_N_ENDP*RDIDX_W-1:0]  dev_i_erRdIdx;
wire [7:0]                          dev_o_erRdByte;
wire [NBYTES_W-1:0]                 dev_o_erRdNBytes;

wire [DEV2HOST_N_ENDP-1:0]          dev_o_etTxAccepted;
wire [DEV2HOST_N_ENDP-1:0]          dev_i_etWrEn;
wire [DEV2HOST_N_ENDP*WRIDX_W-1:0]  dev_i_etWrIdx;
wire [DEV2HOST_N_ENDP*8-1:0]        dev_i_etWrByte;

wire [10:0] dev_o_frameNumber;
wire [2:0]  dev_o_txnType;

wire [6:0] devAddr;
usbfsTxn #( // {{{ u_txn
  .RX_N_ENDP        (HOST2DEV_N_ENDP),
  .TX_N_ENDP        (DEV2HOST_N_ENDP),
  .RX_ISOCHRONOUS   (0),
  .TX_ISOCHRONOUS   (0),
  .RX_STALLABLE     (0),
  .TX_STALLABLE     (1), // Endpoint0 can stall for unsupported descriptors.
  .MAX_PKT          (MAX_PKT) // TODO: Split RX/TX_MAX_PKT
) u_txn (
  .i_clk_48MHz              (i_clk_48MHz),
  .i_rst                    (i_rst),

  // USB {d+, d-}, output enable.
  .i_dp                     (i_dp),
  .i_dn                     (i_dn),
  .o_dp                     (o_dp),
  .o_dn                     (o_dn),
  .o_oe                     (o_oe),

  // Endpoints receiving data (HOST2DEV_N_ENDP)
  .i_erReady                (dev_i_erReady),
  .o_erValid                (dev_o_erValid),
  .i_erStall                (dev_i_erStall),

  // Read buffer interface to u_rx
  .i_erRdEn                 (dev_i_erRdEn),
  .i_erRdIdx                (dev_i_erRdIdx),
  .o_erRdByte               (dev_o_erRdByte),
  .o_erRdNBytes             (dev_o_erRdNBytes),

  // Endpoints transmitting data (DEV2HOST_N_ENDP)
  .o_etReady                (dev_o_etReady),
  .i_etValid                (dev_i_etValid),
  .i_etStall                (dev_i_etStall),

  // Write buffer interface to u_tx
  .o_etTxAccepted           (dev_o_etTxAccepted),
  .i_etWrEn                 (dev_i_etWrEn),
  .i_etWrIdx                (dev_i_etWrIdx),
  .i_etWrByte               (dev_i_etWrByte),

  // Current state of transaction flags $onehot({SETUP, OUT, IN}).
  // Mostly useful in dev-mode.
  .o_txnType                (dev_o_txnType),

  // Current frame number.
  // NOTE: Endpoints are not required to do anything with this.
  // Host-mode --> Counter value.
  // Device-mode --> Frame number from token[SOF].
  .o_frameNumber            (dev_o_frameNumber),

  // Device address, initially the Default Address (0), but configured with a
  // Setup transfer to the Default Endpoint (0).
  .i_devAddr                (devAddr)
); // }}} v_dev

usbfsEndpCtrlSerial #( // {{{ u_ctrlSerial
  .VENDOR_ID        (VENDOR_ID),
  .PRODUCT_ID       (PRODUCT_ID),
  .ACM_NOT_GENERIC  (ACM_NOT_GENERIC),
  .MAX_PKT          (MAX_PKT)
) u_ctrlSerial (
  .i_clk                    (i_clk_48MHz),
  .i_rst                    (i_rst),

  .o_devAddr                (devAddr),

  // Host-to-device
  .o_er0Ready               (dev_i_erReady[0]),
  .i_er0Valid               (dev_o_erValid[0]),
  .o_er0Stall               (dev_i_erStall[0]),

  // Read buffer interface to u_rx
  .o_er0RdEn                (dev_i_erRdEn[0]),
  .o_er0RdIdx               (dev_i_erRdIdx[0*RDIDX_W +: RDIDX_W]),
  .i_er0RdByte              (dev_o_erRdByte),
  .i_er0RdNBytes            (dev_o_erRdNBytes),

  .i_et0Ready               (dev_o_etReady[0]),
  .o_et0Valid               (dev_i_etValid[0]),
  .o_et0Stall               (dev_i_etStall[0]),

  // Write buffer interface to u_tx
  .i_et0TxAccepted          (dev_o_etTxAccepted[0]),
  .o_et0WrEn                (dev_i_etWrEn[0]),
  .o_et0WrIdx               (dev_i_etWrIdx[0*WRIDX_W +: WRIDX_W]),
  .o_et0WrByte              (dev_i_etWrByte[0*8 +: 8]),

  .i_txnType                (dev_o_txnType)
); // }}} u_ctrlSerial

usbfsEndpRx #( // {{{ u_endpRx
  .MAX_PKT          (MAX_PKT)
) u_endpRx (
  .i_clk                    (i_clk_48MHz),
  .i_rst                    (i_rst),

  .i_ready                  (i_hostToDev_ready),
  .o_valid                  (o_hostToDev_valid),
  .o_data                   (o_hostToDev_data),

  .o_erReady                (dev_i_erReady[1]),
  .i_erValid                (dev_o_erValid[1]),
  .o_erStall                (dev_i_erStall[1]),

  .o_erRdEn                 (dev_i_erRdEn[1]),
  .o_erRdIdx                (dev_i_erRdIdx[1*RDIDX_W +: RDIDX_W]),
  .i_erRdByte               (dev_o_erRdByte),
  .i_erRdNBytes             (dev_o_erRdNBytes)
); // }}} u_endpRx

usbfsEndpTx #( // {{{ u_endpTx
  .MAX_PKT          (MAX_PKT)
) u_endpTx (
  .i_clk                    (i_clk_48MHz),
  .i_rst                    (i_rst),

  .o_ready                  (o_devToHost_ready),
  .i_valid                  (i_devToHost_valid),
  .i_data                   (i_devToHost_data),

  .i_etReady                (dev_o_etReady[1]),
  .o_etValid                (dev_i_etValid[1]),
  .o_etStall                (dev_i_etStall[1]),

  // Write buffer interface to u_tx
  .i_etTxAccepted           (dev_o_etTxAccepted[1]),
  .o_etWrEn                 (dev_i_etWrEn[1]),
  .o_etWrIdx                (dev_i_etWrIdx[1*WRIDX_W +: WRIDX_W]),
  .o_etWrByte               (dev_i_etWrByte[1*8 +: 8])
); // }}} u_endpTx

endmodule
