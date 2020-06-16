#ifndef _VERILATORTBCTRL_H
#define _VERILATORTBCTRL_H

#include <fcntl.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "verilated.h"
#include "verilated_vcd_c.h"

#include "dmpvlCommon.h"

#define TBCTRL_BUFLEN 32
#define TBCTRL_FIFOPATH "tbCtrl"

template <class VA> class VerilatorTbCtrl { // {{{
public:
  VA*               m_dut;
  VerilatedVcdC*    m_trace;
  uint64_t          m_tickcount;
  int               m_ctrlfifo;
  bool              m_doDump;
  int               m_doStep;
  uint64_t          m_tickPeriod_us;

  VerilatorTbCtrl(const char* vcdname) : m_trace(NULL), m_tickcount(0l) {
    VERB("Enter");
    m_dut = new VA;
    Verilated::traceEverOn(true);
    m_dut->i_clk = 0;
    m_dut->i_rst = 1;
    m_doDump = true;
    m_doStep = 0;
    m_tickPeriod_us = 1000000; // 1Hz (maximum period)
    eval(); // Get our initial values set properly.
    opentrace(vcdname);
    openctrl();
    VERB("  Exit");
  }

  virtual ~VerilatorTbCtrl(void) {
    VERB("Enter");
    closetrace();
    closectrl();
    delete m_dut;
    m_dut = NULL;
    VERB("  Exit");
  }

  virtual void openctrl(void) {
    VERB("Enter");

    // Delete any pre-existing named pipe.
    remove(TBCTRL_FIFOPATH);

    if (0 > mkfifo(TBCTRL_FIFOPATH, 0666)) {
      ERROR("Cannot open control fifo.");
    }

    VERB("  Control FIFO path=%s", TBCTRL_FIFOPATH);
    m_ctrlfifo = open(TBCTRL_FIFOPATH, O_RDONLY | O_NONBLOCK);
    VERB("  m_ctrlfifo: %d", m_ctrlfifo);
    VERB("  Exit");
  }

  virtual void closectrl(void) {
    VERB("Enter");
    if (0 <= m_ctrlfifo) {
      close(m_ctrlfifo);
    }
    remove(TBCTRL_FIFOPATH);
    VERB("  Exit");
  }

  virtual void opentrace(const char* vcdname) {
    VERB("Enter");
    if (!m_trace) {
      VERB("  VCD path=%s", vcdname);
      m_trace = new VerilatedVcdC;
      m_dut->trace(m_trace, 99);
      m_trace->open(vcdname);
    }
    VERB("  Exit");
  }

  virtual void closetrace(void) {
    VERB("Enter");
    if (m_trace) {
      VERB("  Closing trace VCD");
      m_trace->close();
      delete m_trace;
      m_trace = NULL;
    }
    VERB("  Exit");
  }

  virtual void eval(void) {
    m_dut->eval();
  }

  // Call from loop {check, drive, tick}
  virtual void tick(void) {
    VERB("Enter");

    VERB("  posedge");
    m_dut->i_clk = 1;
    m_dut->eval();
    if (m_doDump && m_trace) {
      m_trace->dump((uint64_t)(10*m_tickcount));
    }

    VERB("  negedge");
    m_dut->i_clk = 0;
    m_dut->eval();
    if (m_doDump && m_trace) {
      m_trace->dump((uint64_t)(10*m_tickcount+5));
      m_trace->flush();
    }

    m_tickcount++;
    VERB("  Exit");
  }

  virtual void reset(void) {
    VERB("Enter");
    m_dut->i_rst = 1;
    for (int i = 0; i < 5; i++)
      tick();
    m_dut->i_rst = 0;
    VERB("  Exit");
  }

  unsigned long tickcount(void) {
    return m_tickcount;
  }

  virtual bool done(void) {
    return Verilated::gotFinish();
  }

  virtual char* readCtrlLine(void) {
    static int i = 0;
    static char buf[TBCTRL_BUFLEN] = {0};

    char* ret_line      = buf;
    char* ret_error     = (char*)(-1);
    char* ret_notReady  = (char*)(NULL);

    //VERB("Enter");

    int nRead;
    char* ret;

    while (1) {
      // https://linux.die.net/man/2/read
      if (0 > (nRead = read(m_ctrlfifo, &buf[i], 1))) {
        // Cannot get char either because there's no data in fifo, or an error.
        bool blocking = (EAGAIN == errno) || (EWOULDBLOCK == errno);
        //VERB("%s errno=%d", __func__, errno);
        ret = blocking ? ret_notReady : ret_error;
        break;
      }

      if (0 == nRead) {
        ret = ret_notReady;
        break;
      }
      //VERB("  nRead=%d buf[%d]=%c buf=%s", nRead, i, buf[i], buf);

      // Zero characters read, without causing an error.
      assert(1 == nRead);

      if (buf[i] == '\n') {
        // End of line --> return pointer to buf.

        buf[i] = '\0'; // Avoid comparisons with command separator.
        i = 0;
        //VERB("  Got separator buf=%s", buf);

        ret = ret_line;
        break;
      }

      if (i > TBCTRL_BUFLEN-1) {
        // No space left in buffer --> return error
        i = 0;
        ret = ret_error;
        break;
      }

      // Read another character into buffer, now try to get another.
      i++;
    }

    //VERB("  Exit");
    return ret;
  }

  virtual bool strStartswith(const char* prefix, const char* str) {
    return (0 == strncmp(prefix, str, strlen(prefix)));
  }

  virtual bool strEqualto(const char* cmp, const char* str) {
    return (0 == strncmp(cmp, str, TBCTRL_BUFLEN));
  }

  virtual void run(int maxNCycles) {
    char* cmd;

    VERB("Enter");

    while (tickcount() < maxNCycles) {
      // NOTE: Current implementation assumes tick() executes in zero time.
      // TODO: Measure how many us have elapsed?
      usleep(m_tickPeriod_us);

      if (0 > (cmd = readCtrlLine())) {
        ERROR("Reading from tbCtrl failed.");
      } else if (cmd != NULL) {
        //VERB("  cmd=%s", cmd);

        if        ( strEqualto("s", cmd) ||
                    strEqualto("step", cmd)) {

          m_doStep = 1;

        } else if ( strStartswith("s ", cmd) ||
                    strStartswith("step ", cmd) ) {

          unsigned int n;
          assert(1 == sscanf(cmd, "%*s %d", &n));

          m_doStep = (n > 1) ? n : 1;

        } else if ( strEqualto("c", cmd) ||
                    strEqualto("continue", cmd) ) {

          m_doStep = -1;

        } else if ( strEqualto("d", cmd) ||
                    strEqualto("discontinue", cmd) ) {

          m_doStep = 0;

        } else if ( strEqualto("dumpon", cmd) ) {

          m_doDump = true;

        } else if ( strEqualto("dumpoff", cmd) ) {

          m_doDump = false;

        /*
        } else if ( strStartswith("t ", cmd) ||
                    strStartswith("timebase ", cmd) ) {

          // TODO: Get value in {Z, absolute, relative}
        */

        } else if ( strStartswith("f ", cmd) ||
                    strStartswith("frequency_Hz ", cmd) ) {

          // Get value as IEEE754 double-precision float Hertz.
          double f;
          assert(1 == sscanf(cmd, "%*s %lf", &f));

          unsigned int p = (unsigned int)(1000000.0/f);

          m_tickPeriod_us = p;
          VERB("  Frequency=%fHz Period=%dus", f, p);

        } else if ( strStartswith("p ", cmd) ||
                  strStartswith("period_us ", cmd) ) {

          // Get value as unsigned integer microseconds.
          unsigned int p;
          assert(1 == sscanf(cmd, "%*s %d", &p));

          double f = 1000000.0/p;

          m_tickPeriod_us = p;
          VERB("  Frequency=%fHz Period=%dus", f, p);

        } else if ( strEqualto("r", cmd) ||
                    strEqualto("reset", cmd) ) {

          reset();

        } else if ( strEqualto("q", cmd) ||
                    strEqualto("quit", cmd) ) {

          break;
        }

      }

      if (0 != m_doStep) tick();

      if (0 < m_doStep) m_doStep--;

    }

    VERB("  Exit");
    return;
  }

}; // }}}

#endif // _VERILATORTB_H
