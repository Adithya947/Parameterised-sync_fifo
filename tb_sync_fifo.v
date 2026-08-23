`timescale 1ns/1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 8;

    reg                  clk;
    reg                  rst;

    reg                  wr_en;
    reg                  rd_en;
    reg  [DATA_WIDTH-1:0] din;

    wire [DATA_WIDTH-1:0] dout;
    wire                 full;
    wire                 empty;

    // DUT
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk   (clk),
        .rst   (rst),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .din   (din),
        .dout  (dout),
        .full  (full),
        .empty (empty)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin

        // Initialize
        rst   = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        din   = '0;

        // Reset
        #20;
        rst = 1'b0;

        $display("======================================");
        $display(" FIFO TEST START");
        $display("======================================");

        // -------------------------------
        // WRITE DATA
        // -------------------------------
        write_data(8'h11);
        write_data(8'h22);
        write_data(8'h33);
        write_data(8'h44);

        // -------------------------------
        // READ DATA
        // -------------------------------
        read_data();
        read_data();
        read_data();
        read_data();

        // -------------------------------
        // TEST EMPTY
        // -------------------------------
        $display("Checking EMPTY flag...");

        @(posedge clk);
        #1;

        if (empty)
            $display("PASS: FIFO is EMPTY");
        else
            $display("FAIL: FIFO should be EMPTY");

        // -------------------------------
        // FILL FIFO
        // -------------------------------
        $display("Filling FIFO...");

        write_data(8'hA0);
        write_data(8'hA1);
        write_data(8'hA2);
        write_data(8'hA3);
        write_data(8'hA4);
        write_data(8'hA5);
        write_data(8'hA6);
        write_data(8'hA7);

        @(posedge clk);
        #1;

        if (full)
            $display("PASS: FIFO is FULL");
        else
            $display("FAIL: FIFO should be FULL");

        // -------------------------------
        // TRY WRITE WHEN FULL
        // -------------------------------
        $display("Trying write while FULL...");

        write_data(8'hFF);

        // -------------------------------
        // READ ALL DATA
        // -------------------------------
        $display("Reading FIFO contents...");

        read_data();
        read_data();
        read_data();
        read_data();
        read_data();
        read_data();
        read_data();
        read_data();

        // -------------------------------
        // FINAL EMPTY CHECK
        // -------------------------------
        @(posedge clk);
        #1;

        if (empty)
            $display("PASS: FIFO is EMPTY after reading");
        else
            $display("FAIL: FIFO should be EMPTY");

        $display("======================================");
        $display(" FIFO TEST COMPLETE");
        $display("======================================");

        #20;
        $finish;
    end


    // ------------------------------------
    // WRITE TASK
    // ------------------------------------
    task write_data(input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);

            if (!full) begin
                wr_en = 1'b1;
                din   = data;

                @(posedge clk);
                #1;

                wr_en = 1'b0;

                $display("[%0t] WRITE: %h", $time, data);
            end
            else begin
                $display("[%0t] WRITE BLOCKED - FIFO FULL", $time);
            end
        end
    endtask


    // ------------------------------------
    // READ TASK
    // ------------------------------------
    task read_data;
        begin
            @(posedge clk);

            if (!empty) begin
                rd_en = 1'b1;

                @(posedge clk);
                #1;

                rd_en = 1'b0;

                $display("[%0t] READ : %h", $time, dout);
            end
            else begin
                $display("[%0t] READ BLOCKED - FIFO EMPTY", $time);
            end
        end
    endtask


    // ------------------------------------
    // WAVEFORM DUMP
    // ------------------------------------
    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_sync_fifo);
    end

endmodule