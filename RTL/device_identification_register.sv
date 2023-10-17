// SEE 1149.1 - 12.1.1 for details on providing optional USERCODE instruction support

module device_identification_register (
    `include "defines.sv"

    input tdi,
    input clockDR,
    input captureDR,
    output tdo
);

logic [32:0] shift_reg;
assign shift_reg[0] = tdi;
assign tdo = shift_reg[32];

genvar i;
for (i = 0; i < 32; i = i + 1) begin
    always @(posedge clockDR) begin 
        //On the rising edge of TCK in the Capture-DR controller state, the device identification register shall be set
        // such that subsequent shifting causes an identification code to be presented in serial form at TDO

        if (captureDR) begin
            shift_reg[32:1] <= `DEVICE_ID;
        end else begin
            shift_reg[i+1] <= shift_reg[i];
        end

    end
end




endmodule // device_identification_register