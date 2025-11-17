`timescale 1ns/1ps
`include "sync_fifo_cnt.v"
module tb_sync_fifo_cnt;

    // Parameters
    localparam WIDTH = 8;
    localparam DEPTH = 8;

    // DUT signals
    reg clk;
    reg rst_n;
    reg wr_en;
    reg rd_en;
    reg [WIDTH-1:0] din;

    wire [WIDTH-1:0] dout;
    wire full;
    wire empty;

    // DUT instance
    sync_fifo_cnt #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    //-----------------------------------------
    // CLOCK
    //-----------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz clock
    end

    //-----------------------------------------
    // TASK: WRITE FIFO
    //-----------------------------------------
    task write_fifo(input [WIDTH-1:0] data);
    begin
        @(posedge clk);
        wr_en = 1;
        din   = data;
        @(posedge clk);
        wr_en = 0;
        din   = 0;
    end
    endtask

    initial begin
        $dumpfile("tb_sync_fifo_cnt.vcd");
        $dumpvars(0, tb_sync_fifo_cnt);
    end

    //-----------------------------------------
    // TASK: READ FIFO
    //-----------------------------------------
    task read_fifo();
    begin
        @(posedge clk);
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
    end
    endtask

    //-----------------------------------------
    // MAIN TEST
    //-----------------------------------------
    initial begin
        // Default values
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        //-------------------------------------
        // RESET
        //-------------------------------------
        rst_n = 0;
        repeat(3) @(posedge clk);
        rst_n = 1;

        $display("\n===== RESET DONE =====\n");

        //-------------------------------------
        // TEST 1: WRITE UNTIL FULL
        //-------------------------------------
        $display("===== TEST 1: WRITE UNTIL FULL =====");

        while (!full) begin
            write_fifo($urandom_range(0,255));
            #1;
            $display("WRITE din=%0d | full=%b empty=%b count≈?", 
                     dut.din, full, empty);
        end

        if (full)
            $display("FULL detected OK!\n");
        else
            $display("ERROR: FULL NOT detected!\n");

        //-------------------------------------
        // TEST 2: READ UNTIL EMPTY
        //-------------------------------------
        $display("===== TEST 2: READ UNTIL EMPTY =====");

        while (!empty) begin
            read_fifo();
            #1;
            $display("READ dout=%0d | full=%b empty=%b count≈?", 
                     dout, full, empty);
        end

        if (empty)
            $display("EMPTY detected OK!\n");

        //-------------------------------------
        // TEST 3: WRITE & READ same time
        //-------------------------------------
        $display("===== TEST 3: READ & WRITE SAME CYCLE =====");

        fork
            begin
                write_fifo(8'hAA);
                write_fifo(8'hBB);
            end
            begin
                #7; // delay cho overlap
                read_fifo();
                read_fifo();
            end
        join

        //-------------------------------------
        // FINISH
        //-------------------------------------
        $display("\n===== SIMULATION DONE =====\n");
        #20;
        $finish;
    end

endmodule
