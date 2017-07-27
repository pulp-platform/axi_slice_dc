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

module dc_full_detector(clk, rstn, read_pointer, write_pointer, valid, full);

    parameter                    BUFFER_DEPTH = 8;

    input                        clk;
    input                        rstn;
    input [BUFFER_DEPTH - 1 : 0] read_pointer;
    input [BUFFER_DEPTH - 1 : 0] write_pointer;
    input                        valid;
    output                       full;

    wire                         fifo_full;
    wire                         fifo_1_free;
    wire                         fifo_2_free;
    wire                         full_dn;
    wire                         full_up;
    reg                          latched_full_s;

    assign fifo_full = |(read_pointer & {write_pointer[BUFFER_DEPTH - 2 : 0], write_pointer[BUFFER_DEPTH - 1]});
    assign fifo_1_free = |(read_pointer & {write_pointer[BUFFER_DEPTH - 3 : 0], write_pointer[BUFFER_DEPTH - 1 : BUFFER_DEPTH - 2]});
    assign fifo_2_free = |(read_pointer & {write_pointer[BUFFER_DEPTH - 4 : 0], write_pointer[BUFFER_DEPTH - 1 : BUFFER_DEPTH - 3]});
    assign full_dn = (fifo_full | fifo_1_free | fifo_2_free);

    dc_synchronizer
    #(
      .WIDTH(1),
      .RESET_VALUE(1'b0)
    )
    full_synch
    (
      .clk   ( clk     ),
      .rstn  ( rstn    ),
      .d_in  ( full_dn ),
      .d_out ( full_up )
    );

    always @(posedge clk  or negedge rstn)
    begin: full_evaluator
        if (rstn == 1'b0)
            latched_full_s <= 1'b0;
        else
            latched_full_s <= full_up | valid;
    end

    assign full = latched_full_s & full_up;

endmodule
