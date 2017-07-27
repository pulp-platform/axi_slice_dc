/* Copyright (C) 2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */

module dc_synchronizer (clk, rstn, d_in, d_out);

    parameter WIDTH       = 1;
    parameter RESET_VALUE = 'h0;

    input                  clk;
    input                  rstn;
    input  [WIDTH - 1 : 0] d_in;
    output [WIDTH - 1 : 0] d_out;

    reg [WIDTH - 1 : 0]    d_middle;
    reg [WIDTH - 1 : 0]    d_out;

    always @(posedge clk  or negedge rstn)
    begin: update_state
        if (rstn == 1'b0)
        begin
            d_middle <= RESET_VALUE;
            d_out <= RESET_VALUE;
        end
        else
        begin
            d_middle <= d_in;
            d_out <= d_middle;
        end
    end

endmodule
