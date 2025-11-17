module sync_fifo_cnt #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input wire              clk,
    input wire              rst_n,
    input wire              wr_en,
    input wire [WIDTH-1:0]  din,
    input wire              rd_en,
    output reg [WIDTH-1:0]  dout,
    output wire             full,
    output wire             empty
);

    localparam ADDR_W = $clog2(DEPTH);
    localparam CNT_W  = $clog2(DEPTH + 1);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_W-1:0] wr_ptr, rd_ptr;
    reg [CNT_W-1:0]  count;


    // NEXT POINTER LOGIC
    wire [ADDR_W-1:0] wr_ptr_next = (wr_ptr == DEPTH - 1) ? 0 : wr_ptr + 1;
    wire [ADDR_W-1:0] rd_ptr_next = (rd_ptr == DEPTH - 1) ? 0 : rd_ptr + 1;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);


    // MAIN LOGIC
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: begin // WRITE ONLY
                    mem[wr_ptr] <= din;
                    wr_ptr <= wr_ptr_next;
                    count <= count + 1;
                end
                2'b01: begin // READ ONLY
                    dout <= mem[rd_ptr];
                    rd_ptr <= rd_ptr_next;
                    count <= count - 1;
                end
                2'b11: begin // SIMULTANEOUS READ AND WRITE
                    mem[wr_ptr] <= din;
                    dout <= mem[rd_ptr];
                    wr_ptr <= wr_ptr_next;
                    rd_ptr <= rd_ptr_next;
                    count <= count;
                end
                default: begin
                    count <= count; 
                end
            endcase
        end

    end


endmodule