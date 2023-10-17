// device ID
`define DEVICE_ID 32'hDEADBEEF

// instruction register width
`define INST_REG_WIDTH 3

// decoded (one-hot) instruction signal bus width
`define INST_COUNT 2 ** `INST_REG_WIDTH

// encoded instructions
`define E_BYPASS         3'b111
`define E_IDCODE         3'b001
`define E_SAMPLE_PRELOAD 6'b000010
`define E_EXTEST         6'b000100
`define E_CLAMP          6'b010000
`define E_IC_RESET       6'b100000

// decoded instructions
`define D_BYPASS         `INST_COUNT'b1
`define D_IDCODE         `INST_COUNT'b10
`define D_SAMPLE_PRELOAD `INST_COUNT'b100
`define D_EXTEST         `INST_COUNT'b1000
`define D_CLAMP          `INST_COUNT'b100000
`define D_IC_RESET       `INST_COUNT'b1000000