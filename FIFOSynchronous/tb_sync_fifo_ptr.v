`timescale 1ns/1ps
`include "sync_fifo_ptr.v"
module tb_sync_fifo_ptr;

    // Parameters
    localparam WIDTH = 8;
    localparam DEPTH = 8;

    // DUT Signals
    reg clk;
    reg rst_n;
    reg wr_en;
    reg rd_en;
    reg [WIDTH-1:0] din;
    wire [WIDTH-1:0] dout;
    wire full;
    wire empty;

    // Instantiate DUT
    sync_fifo_ptr #(
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

    //---------------------------------------
    // CLOCK GENERATION
    //---------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock = 100MHz
    end

    //---------------------------------------
    // TASK: WRITE FIFO
    //---------------------------------------
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

    //---------------------------------------
    // TASK: READ FIFO
    //---------------------------------------
    task read_fifo();
    begin
        @(posedge clk);
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
    end
    endtask

    //---------------------------------------
    // MAIN TEST SEQUENCE
    //---------------------------------------
    initial begin
        // Initial values
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        // RESET
        rst_n = 0;
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display(">> RESET DONE\n");

        //-----------------------------------
        // TEST 1: WRITE UNTIL FULL
        //-----------------------------------
        $display(">> TEST 1: WRITE UNTIL FULL");
        repeat (DEPTH-1) begin
            write_fifo($random);
            #1;
            $display("WRITE: din=%0d, full=%b, empty=%b", din, full, empty);
        end

        if (full)
            $display("FIFO FULL detected correctly\n");
        else
            $display("ERROR: FIFO should be full but is not\n");

        //-----------------------------------
        // TEST 2: READ UNTIL EMPTY
        //-----------------------------------
        $display(">> TEST 2: READ UNTIL EMPTY");
        while (!empty) begin
            read_fifo();
            #1;
            $display("READ: dout=%0d, full=%b, empty=%b", dout, full, empty);
        end

        $display("FIFO EMPTY detected correctly\n");

        //-----------------------------------
        // TEST 3: WRITE + READ SAME TIME
        //-----------------------------------
        $display(">> TEST 3: READ & WRITE same cycle");

        fork
            begin
                write_fifo(8'hAA);
                write_fifo(8'hBB);
            end
            begin
                #7; // Delay để tạo tình huống read/write overlap
                read_fifo();
                read_fifo();
            end
        join

        //-----------------------------------
        // END SIMULATION
        //-----------------------------------
        $display(">> SIM DONE");
        #20;
        $finish;
    end

    initial begin
        $dumpfile("tb_sync_fifo_ptr.vcd");
        $dumpvars(0, tb_sync_fifo_ptr);
    end

endmodule
