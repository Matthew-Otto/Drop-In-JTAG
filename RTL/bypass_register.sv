module bypass_register (
    input tck, tdi, enable,
    output logic tdo
);

always @(tck) begin
    if (enable)
        tdo <= tdi;
end

endmodule // bypass_register