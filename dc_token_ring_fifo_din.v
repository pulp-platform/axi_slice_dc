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

module dc_token_ring_fifo_din(clk, rstn, data, valid, ready, write_token, read_pointer, data_async);

    parameter                   DATA_WIDTH = 10;
    parameter                   BUFFER_DEPTH = 8;

    input                       clk;
    input                       rstn;
    input [DATA_WIDTH - 1 : 0]  data;
    input                       valid;
    output                      ready;

    output [BUFFER_DEPTH - 1 : 0] write_token;
    input  [BUFFER_DEPTH - 1 : 0] read_pointer;

    output [DATA_WIDTH - 1 : 0] data_async;

    wire                        stall;
    wire                        write_enable;
    wire [BUFFER_DEPTH - 1 : 0] write_pointer;

    assign ready = ~stall;

    // FIFO read/write enable
    assign write_enable = (valid & ready);

    // Actual FIFO
    dc_data_buffer
    #(
      .DATA_WIDTH   ( DATA_WIDTH   ),
      .BUFFER_DEPTH ( BUFFER_DEPTH )
    )
    buffer
    (
      .clk           ( clk           ),
      .rstn          ( rstn          ),
      .write_pointer ( write_pointer ),
      .write_data    ( data          ),
      .read_pointer  ( read_pointer  ),
      .read_data     ( data_async    )
    );

    // Logic to compute the read, write pointers
    dc_token_ring
    #(
      .BUFFER_DEPTH ( BUFFER_DEPTH ),
      .RESET_VALUE  ( 'hc          )
    )
    write_tr
    (
      .clk    ( clk          ),
      .rstn   ( rstn         ),
      .enable ( write_enable ),
      .state  ( write_token  )
    );

    // Pointers to the write, read addresses (semi-accurate, leveraging the two-hot encoding for extra robustness)
    assign write_pointer = {write_token[BUFFER_DEPTH - 2 : 0], write_token[BUFFER_DEPTH - 1]} & write_token;

    // Full detector
    dc_full_detector
    #(
      .BUFFER_DEPTH ( BUFFER_DEPTH )
    )
    full
    (
      .clk           ( clk           ),
      .rstn          ( rstn          ),
      .read_pointer  ( read_pointer  ),
      .write_pointer ( write_pointer ),
      .valid         ( valid         ),
      .full          ( stall         )
    );

endmodule
