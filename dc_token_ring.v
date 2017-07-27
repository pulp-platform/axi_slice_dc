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

module dc_token_ring(clk, rstn, enable, state);

    parameter                     BUFFER_DEPTH = 8;
    parameter                     RESET_VALUE = 'h3;

    input                         clk;
    input                         rstn;
    input                         enable;
    output [BUFFER_DEPTH - 1 : 0] state;

    reg [BUFFER_DEPTH - 1 : 0]    state;
    reg [BUFFER_DEPTH - 1 : 0]    next_state;

    always @(posedge clk or negedge rstn)
    begin: update_state
        if (rstn == 1'b0)
            state <= RESET_VALUE;
        else
            state <= next_state;
    end

    always @(enable, state)
    begin
        if (enable)
            next_state = {state[BUFFER_DEPTH - 2 : 0], state[BUFFER_DEPTH - 1]};
        else
            next_state = state;
    end

endmodule
