module sync_fifo_ptr #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire [WIDTH-1:0] din,
    input wire rd_en,
    output reg [WIDTH-1:0] dout,
    output wire full,
    output wire empty
);


    localparam  ADDR_W = $clog2(DEPTH);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_W-1:0] wr_ptr, rd_ptr;

    // NEXT POINTER LOGIC
    wire [ADDR_W-1:0] wr_ptr_next = (wr_ptr == DEPTH - 1) ? 0 : wr_ptr + 1;
    wire [ADDR_W-1:0] rd_ptr_next = (rd_ptr == DEPTH - 1) ? 0 : rd_ptr + 1;

    // DETECT EMPTY AND FULL CONDITIONS
    assign empty = (wr_ptr == rd_ptr);
    assign full = (wr_ptr_next == rd_ptr);

    // WRITE OPERATION
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr <= wr_ptr_next;
        end
    end

    // READ OPERATION
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            dout <= 0;
        end else if (rd_en && !empty) begin
            dout <= mem[rd_ptr];
            rd_ptr <= rd_ptr_next;
        end
    end

endmodule