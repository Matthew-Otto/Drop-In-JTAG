// See 1149.1 - 12.1.1 for details on providing optional USERCODE instruction support

module device_identification_register (
    `include "defines.sv"

    input tdi,
    input clockDR,
    input captureDR,
    output tdo
);


logic [32:0] shift_reg;
assign shift_reg[32] = tdi;
assign tdo = shift_reg[0];

genvar i;
for (i = 32; i > 0; i = i - 1) begin
    always @(posedge clockDR) begin 
        if (captureDR) begin
            shift_reg[31:0] <= `DEVICE_ID;  // 12.1.1 (d)
            assert property (@(posedge captureDR) shift_reg[0] == 1'b1) else $error("Violation IEEE 1149.1-2013 12.1.1: LSB of identification code must be 1");
        end else begin
            shift_reg[i-1] <= shift_reg[i];
        end

    end
end

endmodule // device_identification_register