// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Florian Zaruba <zarubaf@iis.ee.ethz.ch>
// Description: This module is a reset synchronizer with a dedicated reset bypass pin for testmode reset.
// Pro Tip: The wise Dr. Schaffner recommends at least 4 registers!

module rstgen_bypass
#(
    parameter NumRegs = 4
)
(
    input  logic clk_i,
    input  logic rst_ni,
    input  logic rst_test_mode_ni,
    input  logic test_mode_i,
    output logic rst_no,
    output logic init_no
);

    // internal reset
    logic rst_n;
    logic s_synch_regs;

    // bypass mode
    always_comb begin
        if (test_mode_i == 1'b0) begin
            rst_n   = rst_ni;
            rst_no  = s_synch_regs;
            init_no = s_synch_regs;
        end else begin
            rst_n   = rst_test_mode_ni;
            rst_no  = rst_test_mode_ni;
            init_no = 1'b1;
        end
    end


    pulp_sync #(.STAGES(NumRegs))  r_bf_synch
    (
        .clk_i    ( clk_i        ),
        .rstn_i   ( rst_n        ),
        .serial_i ( 1'b1         ),
        .serial_o ( s_synch_regs )
    );


    initial 
    begin : p_assertions
        if ((NumRegs <= 1) ||( NumRegs > 4) ) $fatal(1, "Num Regs out of allowed range [2:4] in %m");
    end
endmodule
