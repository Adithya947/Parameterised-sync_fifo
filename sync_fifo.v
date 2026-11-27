
`timescale 1ns/1ps

module sync_fifo #(
    parameter DATA_W = 8,
    parameter ADDR_W = 3                 // DEPTH = 2^ADDR_W = 8
)(
    input                   clk, rst_n,
    input                   wr_en, rd_en,
    input      [DATA_W-1:0] wr_data,
    output reg [DATA_W-1:0] rd_data,
    output                  full, empty
);
    localparam DEPTH = 1 << ADDR_W;

    reg [DATA_W-1:0] mem [0:DEPTH-1];
    reg [ADDR_W:0]   wr_ptr, rd_ptr;     // extra MSB = lap bit

    // flags: pure comparisons of the two pointers
    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]) &&
                   (wr_ptr[ADDR_W]     != rd_ptr[ADDR_W]);

    // accept an operation only if legal
    wire do_wr = wr_en && !full;
    wire do_rd = rd_en && !empty;

    // pointers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (do_wr) wr_ptr <= wr_ptr + 1;
            if (do_rd) rd_ptr <= rd_ptr + 1;
        end
    end

    // memory: only the lower ADDR_W bits address it
    always @(posedge clk) begin
        if (do_wr) mem[wr_ptr[ADDR_W-1:0]] <= wr_data;
        if (do_rd) rd_data <= mem[rd_ptr[ADDR_W-1:0]];
    end
endmodule
