// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_sync_fifo_directed;
    localparam DATA_W = 8;
    localparam ADDR_W = 3;
    localparam DEPTH  = 1 << ADDR_W;      // 8

    reg               clk, rst_n;
    reg               wr_en, rd_en;
    reg  [DATA_W-1:0] wr_data;
    wire [DATA_W-1:0] rd_data;
    wire              full, empty;

    sync_fifo #(.DATA_W(DATA_W), .ADDR_W(ADDR_W)) dut (
        .clk(clk), .rst_n(rst_n),
        .wr_en(wr_en), .rd_en(rd_en),
        .wr_data(wr_data), .rd_data(rd_data),
        .full(full), .empty(empty)
    );

    initial clk = 0;
    always #5 clk = ~clk;                 // 10ns period

    // ---- reusable stimulus, callable like a function ----
    task automatic do_write(input [DATA_W-1:0] data);
        @(negedge clk);
        wr_en = 1; wr_data = data;
        @(negedge clk);
        wr_en = 0;
    endtask

    task automatic do_read;
        @(negedge clk);
        rd_en = 1;
        @(negedge clk);
        rd_en = 0;
    endtask

    integer i;

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_sync_fifo_directed);

        rst_n = 0; wr_en = 0; rd_en = 0; wr_data = 0;
        @(negedge clk); @(negedge clk);
        rst_n = 1;

        // Test 1: fill exactly to DEPTH, check full asserts at the right count
        for (i = 0; i < DEPTH; i = i + 1)
            do_write(i);
        if (full) $display("PASS: full asserted after %0d writes", DEPTH);
        else      $display("FAIL: full not asserted, wr_ptr=%0d rd_ptr=%0d",
                            dut.wr_ptr, dut.rd_ptr);

        // Test 2: overflow attempt while full — must be silently rejected
        do_write(8'hFF);
        do_read;                          // pop the oldest item to inspect it
        if (rd_data === 8'd0)
            $display("PASS: overflow ignored, data0 intact (%0d)", rd_data);
        else
            $display("FAIL: overflow corrupted data, got %0d", rd_data);

        // Test 3: drain the remaining 7, check empty
        for (i = 0; i < DEPTH-1; i = i + 1)
            do_read;
        if (empty) $display("PASS: empty asserted after full drain");
        else       $display("FAIL: not empty, wr_ptr=%0d rd_ptr=%0d",
                             dut.wr_ptr, dut.rd_ptr);

        // Test 4: underflow attempt while empty
        do_read;
        if (rd_data === 8'd7)
            $display("PASS: underflow ignored, rd_data holds last value (%0d)", rd_data);
        else
            $display("FAIL: underflow disturbed rd_data, got %0d", rd_data);

        // Test 5: simultaneous read + write, neither full nor empty
        do_write(8'hAA);
        do_write(8'hBB);
        @(negedge clk);
        wr_en = 1; wr_data = 8'hCC; rd_en = 1;
        @(negedge clk);
        wr_en = 0; rd_en = 0;
        if (rd_data === 8'hAA)
            $display("PASS: simultaneous read/write correct");
        else
            $display("FAIL: expected AA, got %0h", rd_data);

        $display("Directed test complete at time %0t", $time);
        $finish;
    end
endmodule
