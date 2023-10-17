// device ID
`define DEVICE_ID 32'hDEADBEEF

// instruction register width
`define INST_REG_WIDTH 3

// decoded (one-hot) instruction signal bus width
`define INST_COUNT 2 ** `INST_REG_WIDTH

// encoded instructions
`define E_BYPASS         3'b111
`define E_IDCODE         3'b001
`define E_SAMPLE_PRELOAD 3'b010
`define E_EXTEST         3'b011
`define E_CLAMP          3'b100
`define E_IC_RESET       3'b101

// decoded instructions
`define D_BYPASS         'b1
`define D_IDCODE         'b10
`define D_SAMPLE_PRELOAD 'b100
`define D_EXTEST         'b1000
`define D_CLAMP          'b100000
`define D_IC_RESET       'b1000000