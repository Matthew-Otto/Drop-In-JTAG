// device ID
`define DEVICE_ID 32'hDEADBEEF  // 12.1.1 (d)

// instruction register width
`define INST_REG_WIDTH 3

// decoded (one-hot) instruction signal bus width
`define INST_COUNT 7

// encoded instructions
`define E_BYPASS         'b111  // 8.4
`define E_IDCODE         'b001  // 8.13
`define E_SAMPLE_PRELOAD 'b010  // 8.6, 8.7
`define E_EXTEST         'b011  // 8.8
`define E_INTEST         'b100  // 8.9
`define E_CLAMP          'b101  // 8.11

`define E_STEP           'b110  // toggle logic clock once

// decoded instructions
`define D_BYPASS         'b1
`define D_IDCODE         'b10
`define D_SAMPLE_PRELOAD 'b100
`define D_EXTEST         'b1000
`define D_INTEST         'b10000
`define D_CLAMP          'b100000

`define D_STEP           'b1000000