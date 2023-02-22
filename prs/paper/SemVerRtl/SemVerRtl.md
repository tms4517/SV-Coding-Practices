
Addendum to SemVer: System-on-Chip Projects
===========================================

Overview
--------

SoC projects are similar to sofware in many ways, e.g. the are written in
human-readable computer languages and often use version control systems, but
differ in what comprises an "API".
This is an addendum to the [SemVer 2.0.0](https://semver.org/spec/v2.0.0.html)
specification which extends the SemVer scheme to System-on-Chip projects.
This addendum uses detailed examples to illustrate how the SemVer scheme
applies to SoC projects.

This document assumes that you have read and understood:

- [RFC 2119](https://tools.ietf.org/html/rfc2119)
- [SemVer 2.0.0](https://semver.org/spec/v2.0.0.html)

The main difference between software packages and SoC packages is in what
constitutes a public Application Programming Interface (API).

In software libraries written in the C language, an API includes:

- Names of header files which a library user can reference via `#include`.
- Names of preprocessor macros (defined with the `#define` directive).
- Semantics of preprocessor macros.
- Values of constants.
- Names of exposed functions.
- Order of arguments to exposed functions.
- Anything else which a library user might reasonably rely on.

In command-line applications, an API includes:

- Names of command-line options, flags, and sub-commands.
- Default values of command-line options.
- Precedence of configuration files.
- Anything else which an application user might reasonably rely on.

Those examples of software public APIs demonstrate that an API can be defined
more generally as *anything which a user might reasonably rely on*.
Different from software, SoC designs are intended to be used by dependencies
with fundamentally different requirements including higher-level
designs, verification, physical implementation, and high-level software.

An illustrative example, shown in SystemVerilog, is useful to demonstrate API
components of a typical SoC peripheral where sequential logic is implemented
with D-type flip-flops (DFFs).
Let's say that our module `Alu` performs arithmetic operations on its inputs,
drives known values on its outputs, and provides register access via the APB
protocol.
There is one configuration register called `CFG` at the address `12'h444`, with
a reset value of `32'd5`, arranged as two fields `CFG[2:1]=OPERATION` and
`CFG[0]=ENABLE`.

```systemverilog
module Alu
  #(parameter int RESULT_W = 16
  )
  ( input  var logic [1:0][7:0]     i_operands
  , output var logic [RESULT_W-1:0] o_resultant
  , APB.slave                       ifc_APB
  );

  localparam bit MYCONSTANT = 1'b1;
  logic foo_d; // Assignment via `always_comb` or `assign`.
  logic foo_q; // Assignment via `always_ff`.

  // ... snip ...
endmodule
```


MAJOR Versions
--------------

> Given a version number MAJOR.MINOR.PATCH, increment the:
>
> 1. MAJOR version when you make incompatible API changes

Referencing the example, the MAJOR version must be incremented with any of the
following changes:

1. Modified module name which integrators use to declare an instance of the
  peripheral, e.g. `Alu` to `MyAritmetic`.
  Existing code using the name `Alu` will not elaborate unchanged.
2. Removed parameter port, e.g. `RESULT_W`.
  Existing code overriding the parameter value will not elaborate unchanged.
3. Modified parameter port kind, e.g. `parameter` (overridable) to `localparam`
  (non-overridable).
  Existing code overriding the parameter value will not elaborate unchanged.
4. Modified parameter port name, e.g. `RESULT_W` to `OUT_WIDTH`.
  Existing code using the name `RESULT_W` will not elaborate unchanged.
5. Modified parameter port default value, e.g. `16` to `5`, including removal of
  the default value.
  Existing code may depend on the default value for critical functionality.
6. Modified signal port name, e.g. `i_operands` to `i_numbers`.
  Existing code using the name `i_operands` will not elaborate unchanged.
7. Added input port, e.g. `i_another`.
  Existing code instancing the module will not elaborate unchanged.
8. Removed signal port, e.g. `o_resultant`.
  Existing code using that port will not elaborate unchanged.
9. Modified interface type, e.g. `APB.slave` to `AXI.slave`.
  Existing code using an APB interface will not elaborate unchanged.
10. Modified interface name, e.g. `ifc_APB` to `myApb`.
  Existing code using the name `ifc_APB` will not elaborate unchanged.
11. Modified DFF output name, e.g. `foo_q` to `bar_q`.
  Existing code referencing `foo_q` will not find the inferred DFF.
  You may not notice the breakage until your colleagues in physical
  implementation notify you that their scripts don't work.
  In the worst cases, DFFs requiring special treatment may be silently ignored.
12. Modified register address, e.g. `12'h444` to `12'h888`.
  Existing system software accessing the address `0x444` will not operate
  equivalently.
13. Removed register, e.g. `CFG`.
  Existing system software accessing the `CFG` address will not operate
  equivalently.
14. Modified register field layout, e.g. `CFG[0]=ENABLE` to `CFG[31]=ENABLE`.
  Existing system software accessing the register will not operate
  equivalently.
15. Modified register reset value, e.g. `32'd5` to `32'd0`.
  Existing system software accessing the register will not operate
  equivalently, particularly software performing non-atomic
  [read-modify-write](https://en.wikipedia.org/wiki/Read-modify-write)
  operations on startup like `cfg->operation++`.

To summarise, the MAJOR version must be incremented with any changes which
*require* updates to any projects that fetch your updated module.


MINOR Versions
--------------

> Given a version number MAJOR.MINOR.PATCH, increment the:
>
> 2. MINOR version when you add functionality in a backwards compatible manner

Where SemVer specifies *adding* functionality, SoC projects must update the
MINOR version (if not MAJOR) with any of the following modifications as well as
additions:

- Modified parameter port type, e.g. `int` to `bit [3:0]`, including removal of
  the explicit type.
  Existing code may not elaborate unchanged, or override values may be cast to
  an unexpected width or type.
- Modified signal port type, e.g. `var logic [1:0][7:0]` to `tri logic [15:0]`,
  including removal of the explicit type.
  Existing code may not elaborate unchanged, or input expressions may be cast
  to an unexpected width or type.
- Added inout port, e.g. `b_another`.
  Existing code may elaborate unchanged, though a new port implies new
  functionality.
- Added output port, e.g. `o_another`.
  Existing code may elaborate unchanged, though a new port implies new
  functionality.

TODO


PATCH Versions
--------------

> Given a version number MAJOR.MINOR.PATCH, increment the:
>
> 3. PATCH version when you make backwards compatible bug fixes

TODO


Pre-release Versions and Build Metadata
---------------------------------------

> Additional labels for pre-release and build metadata are available as extensions
> to the MAJOR.MINOR.PATCH format.

TODO
