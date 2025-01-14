
module top (
  input  SYSCLK_P, // (E19 LVDS VC707.U51.4)
  input  SYSCLK_N, // (E18 LVDS VC707.U51.5)


`ifdef VC707_FMC1_XM105
  // VC707 with XM105 in FMC1 with external USB electrical conversion board.
  // probes: J1 pins in order, overflowing onto J2
  // pwm: J20 odd numbered pins.
  // {{{ usb electrical conversion VC707.*
  output FMC1_HPC_LA29_N, // USB OE     (T30 LVCMOS18 VC707.J17.XX XM105.J16.11)
  inout  FMC1_HPC_LA29_P, // USB d-     (T29 LVCMOS18 VC707.J17.XX XM105.J16.9)
  inout  FMC1_HPC_LA28_N, // USB d+     (L30 LVCMOS18 VC707.J17.XX XM105.J16.7)
  output FMC1_HPC_LA28_P, // usbpu/Vext (L29 LVCMOS18 VC707.J17.XX XM105.J16.5)
  // }}} usb electrical conversion VC707.*
  // {{{ probes XM105.J1 odd
  input  FMC1_HPC_LA00_CC_P,  // (K39 LVCMOS18 VC707.J17.XX XM105.J1.1)
  input  FMC1_HPC_LA00_CC_N,  // (K40 LVCMOS18 VC707.J17.XX XM105.J1.3)
  input  FMC1_HPC_LA01_CC_P,  // (J41 LVCMOS18 VC707.J17.XX XM105.J1.5)
  input  FMC1_HPC_LA01_CC_N,  // (J40 LVCMOS18 VC707.J17.XX XM105.J1.7)
  input  FMC1_HPC_LA02_P,     // (P41 LVCMOS18 VC707.J17.XX XM105.J1.9)
  input  FMC1_HPC_LA02_N,     // (N41 LVCMOS18 VC707.J17.XX XM105.J1.11)
  input  FMC1_HPC_LA03_P,     // (M42 LVCMOS18 VC707.J17.XX XM105.J1.13)
  input  FMC1_HPC_LA03_N,     // (L42 LVCMOS18 VC707.J17.XX XM105.J1.15)
  input  FMC1_HPC_LA04_P,     // (H40 LVCMOS18 VC707.J17.XX XM105.J1.17)
  input  FMC1_HPC_LA04_N,     // (H41 LVCMOS18 VC707.J17.XX XM105.J1.19)
  input  FMC1_HPC_LA05_P,     // (M41 LVCMOS18 VC707.J17.XX XM105.J1.21)
  input  FMC1_HPC_LA05_N,     // (L41 LVCMOS18 VC707.J17.XX XM105.J1.23)
  input  FMC1_HPC_LA06_P,     // (K42 LVCMOS18 VC707.J17.XX XM105.J1.25)
  input  FMC1_HPC_LA06_N,     // (J42 LVCMOS18 VC707.J17.XX XM105.J1.27)
  input  FMC1_HPC_LA07_P,     // (G41 LVCMOS18 VC707.J17.XX XM105.J1.29)
  input  FMC1_HPC_LA07_N,     // (G42 LVCMOS18 VC707.J17.XX XM105.J1.31)
  input  FMC1_HPC_LA08_P,     // (M37 LVCMOS18 VC707.J17.XX XM105.J1.33)
  input  FMC1_HPC_LA08_N,     // (M38 LVCMOS18 VC707.J17.XX XM105.J1.35)
  input  FMC1_HPC_LA09_P,     // (R42 LVCMOS18 VC707.J17.XX XM105.J1.37)
  input  FMC1_HPC_LA09_N,     // (P42 LVCMOS18 VC707.J17.XX XM105.J1.39)
  // }}} probes XM105.J1 odd
  // {{{ probes XM105.J1 even
  input  FMC1_HPC_LA10_P,     // (N38 LVCMOS18 VC707.J17.XX XM105.J1.2)
  input  FMC1_HPC_LA10_N,     // (M39 LVCMOS18 VC707.J17.XX XM105.J1.4)
  input  FMC1_HPC_LA11_P,     // (F40 LVCMOS18 VC707.J17.XX XM105.J1.6)
  input  FMC1_HPC_LA11_N,     // (F41 LVCMOS18 VC707.J17.XX XM105.J1.8)
  input  FMC1_HPC_LA12_P,     // (R40 LVCMOS18 VC707.J17.XX XM105.J1.10)
  input  FMC1_HPC_LA12_N,     // (P40 LVCMOS18 VC707.J17.XX XM105.J1.12)
  input  FMC1_HPC_LA13_P,     // (H39 LVCMOS18 VC707.J17.XX XM105.J1.14)
  input  FMC1_HPC_LA13_N,     // (G39 LVCMOS18 VC707.J17.XX XM105.J1.16)
  input  FMC1_HPC_LA14_P,     // (N39 LVCMOS18 VC707.J17.XX XM105.J1.18)
  input  FMC1_HPC_LA14_N,     // (N40 LVCMOS18 VC707.J17.XX XM105.J1.20)
  input  FMC1_HPC_LA15_P,     // (M36 LVCMOS18 VC707.J17.XX XM105.J1.22)
  input  FMC1_HPC_LA15_N,     // (L37 LVCMOS18 VC707.J17.XX XM105.J1.24)
  input  FMC1_HPC_LA16_P,     // (K37 LVCMOS18 VC707.J17.XX XM105.J1.26)
  input  FMC1_HPC_LA16_N,     // (K38 LVCMOS18 VC707.J17.XX XM105.J1.28)
  input  FMC1_HPC_LA17_CC_P,  // (L31 LVCMOS18 VC707.J17.XX XM105.J1.30)
  input  FMC1_HPC_LA17_CC_N,  // (K32 LVCMOS18 VC707.J17.XX XM105.J1.32)
  input  FMC1_HPC_LA18_CC_P,  // (M32 LVCMOS18 VC707.J17.XX XM105.J1.34)
  input  FMC1_HPC_LA18_CC_N,  // (L32 LVCMOS18 VC707.J17.XX XM105.J1.36)
  input  FMC1_HPC_LA19_P,     // (W30 LVCMOS18 VC707.J17.XX XM105.J1.38)
  input  FMC1_HPC_LA19_N,     // (W31 LVCMOS18 VC707.J17.XX XM105.J1.40)
  // }}} probes XM105.J1 even
  // {{{ probes XM105.J2 odd
  input  FMC1_HPC_HB00_CC_P,  // (J25 LVCMOS18 VC707.J17.XX XM105.J2.1)
  input  FMC1_HPC_HB00_CC_N,  // (J26 LVCMOS18 VC707.J17.XX XM105.J2.3)
  input  FMC1_HPC_HB01_P,     // (H28 LVCMOS18 VC707.J17.XX XM105.J2.5)
  input  FMC1_HPC_HB01_N,     // (H29 LVCMOS18 VC707.J17.XX XM105.J2.7)
  input  FMC1_HPC_HB02_P,     // (K28 LVCMOS18 VC707.J17.XX XM105.J2.9)
  input  FMC1_HPC_HB02_N,     // (J28 LVCMOS18 VC707.J17.XX XM105.J2.11)
  input  FMC1_HPC_HB03_P,     // (G28 LVCMOS18 VC707.J17.XX XM105.J2.13)
  input  FMC1_HPC_HB03_N,     // (G29 LVCMOS18 VC707.J17.XX XM105.J2.15)
  input  FMC1_HPC_HB04_P,     // (H24 LVCMOS18 VC707.J17.XX XM105.J2.17)
  input  FMC1_HPC_HB04_N,     // (G24 LVCMOS18 VC707.J17.XX XM105.J2.19)
  input  FMC1_HPC_HB05_P,     // (K27 LVCMOS18 VC707.J17.XX XM105.J2.21)
  input  FMC1_HPC_HB05_N,     // (J27 LVCMOS18 VC707.J17.XX XM105.J2.23)
  /*
  input  FMC1_HPC_HB06_CC_P,  // (K23 LVCMOS18 VC707.J17.XX XM105.J2.25)
  input  FMC1_HPC_HB06_CC_N,  // (J23 LVCMOS18 VC707.J17.XX XM105.J2.27)
  input  FMC1_HPC_HB07_P,     // (G26 LVCMOS18 VC707.J17.XX XM105.J2.29)
  input  FMC1_HPC_HB07_N,     // (G27 LVCMOS18 VC707.J17.XX XM105.J2.31)
  input  FMC1_HPC_HB08_P,     // (H25 LVCMOS18 VC707.J17.XX XM105.J2.33)
  input  FMC1_HPC_HB08_N,     // (H26 LVCMOS18 VC707.J17.XX XM105.J2.35)
  input  FMC1_HPC_HB09_P,     // (H23 LVCMOS18 VC707.J17.XX XM105.J2.37)
  input  FMC1_HPC_HB09_N,     // (G23 LVCMOS18 VC707.J17.XX XM105.J2.39)
  */
  // }}} probes XM105.J2 odd
  // {{{ probes XM105.J2 even
  input  FMC1_HPC_HB10_P,     // (M22 LVCMOS18 VC707.J17.XX XM105.J2.2)
  input  FMC1_HPC_HB10_N,     // (L22 LVCMOS18 VC707.J17.XX XM105.J2.4)
  input  FMC1_HPC_HB11_P,     // (K22 LVCMOS18 VC707.J17.XX XM105.J2.6)
  input  FMC1_HPC_HB11_N,     // (J22 LVCMOS18 VC707.J17.XX XM105.J2.8)
  input  FMC1_HPC_HB12_P,     // (K24 LVCMOS18 VC707.J17.XX XM105.J2.10)
  input  FMC1_HPC_HB12_N,     // (K25 LVCMOS18 VC707.J17.XX XM105.J2.12)
  input  FMC1_HPC_HB13_P,     // (P25 LVCMOS18 VC707.J17.XX XM105.J2.14)
  input  FMC1_HPC_HB13_N,     // (P26 LVCMOS18 VC707.J17.XX XM105.J2.16)
  input  FMC1_HPC_HB14_P,     // (J21 LVCMOS18 VC707.J17.XX XM105.J2.18)
  input  FMC1_HPC_HB14_N,     // (H21 LVCMOS18 VC707.J17.XX XM105.J2.20)
  input  FMC1_HPC_HB15_P,     // (M21 LVCMOS18 VC707.J17.XX XM105.J2.22)
  input  FMC1_HPC_HB15_N,     // (L21 LVCMOS18 VC707.J17.XX XM105.J2.24)
  /*
  input  FMC1_HPC_HB16_P,     // (N25 LVCMOS18 VC707.J17.XX XM105.J2.26)
  input  FMC1_HPC_HB16_N,     // (N26 LVCMOS18 VC707.J17.XX XM105.J2.28)
  input  FMC1_HPC_HB17_CC_P,  // (M24 LVCMOS18 VC707.J17.XX XM105.J2.30)
  input  FMC1_HPC_HB17_CC_N,  // (L24 LVCMOS18 VC707.J17.XX XM105.J2.32)
  input  FMC1_HPC_HB18_P,     // (G21 LVCMOS18 VC707.J17.XX XM105.J2.34)
  input  FMC1_HPC_HB18_N,     // (G22 LVCMOS18 VC707.J17.XX XM105.J2.36)
  input  FMC1_HPC_HB19_P,     // (L25 LVCMOS18 VC707.J17.XX XM105.J2.38)
  input  FMC1_HPC_HB19_N,     // (L26 LVCMOS18 VC707.J17.XX XM105.J2.40)
  */
  // }}} probes XM105.J2 even
  `ifdef VC707_LED
  // Just a temporary measure to see LEDs controllable.
  // {{{ result pwm (VC707 LEDs)
  output GPIO_LED_0, // (AM39 LVCMOS18 VC707.DS2.2)
  output GPIO_LED_1, // (AN39 LVCMOS18 VC707.DS3.2)
  output GPIO_LED_2, // (AR37 LVCMOS18 VC707.DS3.2)
  output GPIO_LED_3, // (AT37 LVCMOS18 VC707.DS3.2)
  output GPIO_LED_4, // (AR35 LVCMOS18 VC707.DS3.2)
  output GPIO_LED_5, // (AP41 LVCMOS18 VC707.DS3.2)
  output GPIO_LED_6, // (AP42 LVCMOS18 VC707.DS2.2)
  output GPIO_LED_7  // (AU39 LVCMOS18 VC707.DS2.2)
  // }}} result pwm
  `else
  // {{{ result pwm XM105.J20 odd
  output FMC1_HPC_LA20_P, // (Y29 LVCMOS18 VC707.J17.G21 XM105.J20.1)
  output FMC1_HPC_LA20_N, // (Y30 LVCMOS18 VC707.J17.G22 XM105.J20.3)
  output FMC1_HPC_LA21_P, // (N28 LVCMOS18 VC707.J17.H25 XM105.J20.5)
  output FMC1_HPC_LA21_N, // (N29 LVCMOS18 VC707.J17.H26 XM105.J20.7)
  output FMC1_HPC_LA22_P, // (R28 LVCMOS18 VC707.J17.G24 XM105.J20.9)
  output FMC1_HPC_LA22_N, // (P28 LVCMOS18 VC707.J17.G25 XM105.J20.11)
  output FMC1_HPC_LA23_P, // (P30 LVCMOS18 VC707.J17.D23 XM105.J20.13)
  output FMC1_HPC_LA23_N  // (N31 LVCMOS18 VC707.J17.D24 XM105.J20.15)
  // }}} result pwm XM105.J20 odd
  `endif
`else
  // Dummy configuration without a workable USB interface (not enough GPIO),
  // just to get bitstream generating.
  // {{{ usb electrical conversion VC707.*
  output FMC1_HPC_LA29_N, // USB OE     (T30 LVCMOS18 VC707.J17.XX XM105.J16.11)
  inout  USER_SMA_GPIO_P, // USB d+ (AN31 LVCMOS18 VC707.J33.1)
  inout  USER_SMA_GPIO_N, // USB d- (AP31 LVCMOS18 VC707.J34.1)
  output FMC1_HPC_LA28_P, // usbpu/Vext (L29 LVCMOS18 VC707.J17.XX XM105.J16.5)
  // }}} usb electrical conversion VC707.*
  // {{{ probes VC707.SW* pushbuttons
  input  GPIO_SW_N,  // probe[0] (AR40 LVCMOS18 VC707.SW3.3)
  input  GPIO_SW_E,  // probe[1] (AU38 LVCMOS18 VC707.SW4.3)
  input  GPIO_SW_S,  // probe[2] (AP40 LVCMOS18 VC707.SW5.3)
  input  GPIO_SW_W,  // probe[3] (AW40 LVCMOS18 VC707.SW7.3)
  // }}} probes VC707.SW* pushbuttons
  // {{{ pwm VC707.LEDs
  output GPIO_LED_6, // (AP42 LVCMOS18 VC707.DS2.2)
  output GPIO_LED_7, // (AU39 LVCMOS18 VC707.DS2.2)
  output GPIO_LED_0, // (AM39 LVCMOS18 VC707.DS2.2)
  output GPIO_LED_1  // (AN39 LVCMOS18 VC707.DS3.2)
  // }}} pwm VC707.LEDs
`endif
);
wire i_pin_sysclk_p_200MHz = SYSCLK_P;
wire i_pin_sysclk_n_200MHz = SYSCLK_N;
wire o_pin_usbpu;
wire b_pin_usb_p;
wire b_pin_usb_n;
wire o_pin_usb_oe;
`ifdef VC707_FMC1_XM105
  localparam N_PROBE  = 64;
  localparam N_ENGINE = 8;

  assign FMC1_HPC_LA29_N = o_pin_usb_oe;
  assign b_pin_usb_p = FMC1_HPC_LA28_N;
  assign b_pin_usb_n = FMC1_HPC_LA29_P;
  assign FMC1_HPC_LA28_P = o_pin_usbpu;

  wire [N_PROBE-1:0] i_pin_probe = {
  // {{{ XM105.J1
  FMC1_HPC_LA19_N,
  FMC1_HPC_LA09_N,
  FMC1_HPC_LA19_P,
  FMC1_HPC_LA09_P,
  FMC1_HPC_LA18_CC_N,
  FMC1_HPC_LA08_N,
  FMC1_HPC_LA18_CC_P,
  FMC1_HPC_LA08_P,
  FMC1_HPC_LA17_CC_N,
  FMC1_HPC_LA07_N,
  FMC1_HPC_LA17_CC_P,
  FMC1_HPC_LA07_P,
  FMC1_HPC_LA16_N,
  FMC1_HPC_LA06_N,
  FMC1_HPC_LA16_P,
  FMC1_HPC_LA06_P,
  FMC1_HPC_LA15_N,
  FMC1_HPC_LA05_N,
  FMC1_HPC_LA15_P,
  FMC1_HPC_LA05_P,
  FMC1_HPC_LA14_N,
  FMC1_HPC_LA04_N,
  FMC1_HPC_LA14_P,
  FMC1_HPC_LA04_P,
  FMC1_HPC_LA13_N,
  FMC1_HPC_LA03_N,
  FMC1_HPC_LA13_P,
  FMC1_HPC_LA03_P,
  FMC1_HPC_LA12_N,
  FMC1_HPC_LA02_N,
  FMC1_HPC_LA12_P,
  FMC1_HPC_LA02_P,
  FMC1_HPC_LA11_N,
  FMC1_HPC_LA01_CC_N,
  FMC1_HPC_LA11_P,
  FMC1_HPC_LA01_CC_P,
  FMC1_HPC_LA10_N,
  FMC1_HPC_LA00_CC_N,
  FMC1_HPC_LA10_P,
  FMC1_HPC_LA00_CC_P,
  // }}} XM105.J1
  // {{{ XM105.J2
  FMC1_HPC_HB15_N,
  FMC1_HPC_HB05_N,
  FMC1_HPC_HB15_P,
  FMC1_HPC_HB05_P,
  FMC1_HPC_HB14_N,
  FMC1_HPC_HB04_N,
  FMC1_HPC_HB14_P,
  FMC1_HPC_HB04_P,
  FMC1_HPC_HB13_N,
  FMC1_HPC_HB03_N,
  FMC1_HPC_HB13_P,
  FMC1_HPC_HB03_P,
  FMC1_HPC_HB12_N,
  FMC1_HPC_HB02_N,
  FMC1_HPC_HB12_P,
  FMC1_HPC_HB02_P,
  FMC1_HPC_HB11_N,
  FMC1_HPC_HB01_N,
  FMC1_HPC_HB11_P,
  FMC1_HPC_HB01_P,
  FMC1_HPC_HB10_N,
  FMC1_HPC_HB00_CC_N,
  FMC1_HPC_HB10_P,
  FMC1_HPC_HB00_CC_P
  // }}} XM105.J2
  };

  wire [N_ENGINE-1:0] o_pin_pwm;
  assign {
  `ifdef VC707_LED
    GPIO_LED_7,
    GPIO_LED_6,
    GPIO_LED_5,
    GPIO_LED_4,
    GPIO_LED_3,
    GPIO_LED_2,
    GPIO_LED_1,
    GPIO_LED_0
  `else
    FMC1_HPC_LA23_N,
    FMC1_HPC_LA23_P,
    FMC1_HPC_LA22_N,
    FMC1_HPC_LA22_P,
    FMC1_HPC_LA21_N,
    FMC1_HPC_LA21_P,
    FMC1_HPC_LA20_N,
    FMC1_HPC_LA20_P
  `endif
  } = o_pin_pwm;
`else
  localparam N_PROBE  = 4;
  localparam N_ENGINE = 2;

  assign FMC1_HPC_LA29_N = o_pin_usb_oe;
  assign b_pin_usb_n = USER_SMA_GPIO_N;
  assign b_pin_usb_p = USER_SMA_GPIO_P;
  assign FMC1_HPC_LA28_P = o_pin_usbpu;

  wire [N_PROBE-1:0] i_pin_probe = {
    GPIO_SW_W,
    GPIO_SW_S,
    GPIO_SW_E,
    GPIO_SW_N
  };

  wire [N_ENGINE-1:0] o_pin_pwm;
  assign {
    GPIO_LED_1,
    GPIO_LED_0
  } = o_pin_pwm;
`endif

wire clk_48MHz;
wire pllLocked;
pll48 u_pll48 (
  .i_clk_p_200MHz (i_pin_sysclk_p_200MHz),
  .i_clk_n_200MHz (i_pin_sysclk_n_200MHz),
  .o_clk_48MHz    (clk_48MHz),
  .o_locked       (pllLocked)
);

wire rst;
fpgaReset u_rst (
  .i_clk        (clk_48MHz),
  .i_pllLocked  (pllLocked),
  .o_rst        (rst)
);
assign o_pin_usbpu = !rst;

`ifndef VC707_FMC1_XM105
// Test debouncing.
syncBit #(
  .DEBOUNCE_CYCLES (240000), // 5ms at 48MHz
  .EDGECNTR_W (1),
  .N_SYNC     (2)
) u_btnW (
  .i_clk        (clk_48MHz),
  .i_cg         (1'b1),
  .i_rst        (rst),
  .i_bit        (GPIO_SW_W),

  .o_bit        (GPIO_LED_6),
  .o_edge       (),
  .o_rise       (),
  .o_fall       (),
  .o_nEdge      (),
  .o_nRise      (GPIO_LED_7),
  .o_nFall      ()
);
`endif


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

IOBUF #(
  .DRIVE        (16),
  .IBUF_LOW_PWR ("FALSE"),
  .IOSTANDARD   ("DEFAULT"),
  .SLEW         ("FAST")
) iobuf_usbp (
  .O  (usb_p),
  .I  (usbTx_p),
  .IO (b_pin_usb_p),
  .T  (!usbOutputEnable)
);

IOBUF #(
  .DRIVE        (16),
  .IBUF_LOW_PWR ("FALSE"),
  .IOSTANDARD   ("DEFAULT"),
  .SLEW         ("FAST")
) iobuf_usbn (
  .O  (usb_n),
  .I  (usbTx_n),
  .IO (b_pin_usb_n),
  .T  (!usbOutputEnable)
  );


wire [N_ENGINE-1:0] resultPwm;
usbfsBpCorrelator #(
  .USBFS_VIDPID_SQUAT     (1),
  .USBFS_ACM_NOT_GENERIC  (1),
  .USBFS_MAX_PKT          (16), // in {8,16,32,64}. wMaxPacketSize
  .N_PROBE                (N_PROBE),
  .N_ENGINE               (N_ENGINE),
  .MAX_WINDOW_LENGTH_EXP  (16),
  .MAX_SAMPLE_PERIOD_EXP  (15),
  .MAX_SAMPLE_JITTER_EXP  (8),
  .WINDOW_PRECISION       (8), // 1 < p <= MAX_WINDOW_LENGTH_EXP
  .METRIC_PRECISION       (16),
  .PKTFIFO_DEPTH          (50)
) u_usbfsBpCorrelator (
  .i_clk_48MHz        (clk_48MHz),
  .i_rst              (rst),
  .i_cg               (1'b1),

  // USB {d+, d-}, output enable.
  .i_dp               (usbRx_p),
  .i_dn               (usbRx_n),
  .o_dp               (usbTx_p),
  .o_dn               (usbTx_n),
  .o_oe               (usbOutputEnable),

  .i_probe            (i_pin_probe),

  .o_pwm              (resultPwm)
);
assign o_pin_usb_oe = usbOutputEnable;

assign o_pin_pwm = resultPwm;

endmodule
