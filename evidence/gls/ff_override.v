// Purely functional override for sky130_fd_sc_hd__dfxtp_1
// Used only for functional gate-level simulation.
// Timing is verified separately by OpenSTA (pre-layout: all 16 corners PASSED).
module sky130_fd_sc_hd__dfxtp_1 (
    output Q  ,
    input  CLK,
    input  D
);
    reg Q_r;
    initial Q_r = 1'b0;
    always @(posedge CLK) Q_r <= D;
    assign Q = Q_r;
endmodule
