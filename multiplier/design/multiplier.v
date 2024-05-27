// -----------------------------------------------------------------------------
// Filename: multiplier.v
// Module: multiplier
// Author: Will Chen
// Contact: 
// Date Created: 2024-05-25
// Revision History:
//   2024-05-25 - Initial version
// Description:
//   This is a multiplier module. (i_mult1 * i_mult2 = o_result)
//   This module starts to work when the i_data_valid signal and the o_mult_ready signal are high at the same time. 
//   When o_result_valid is high, it means that the output result is valid.
//   The output of the module will be delayed by M+1 clock cycles
// -----------------------------------------------------------------------------

module multiplier #(
    parameter N = 4,
    parameter M = 4
)(
    input               i_clk           ,
    input               i_rst_n         ,
    input               i_data_valid    ,
    input   [N-1:0]     i_mult1         ,   //i_mult1 * i_mult2
    input   [M-1:0]     i_mult2         ,
    output  [N+M-1:0]   o_result        ,
    output              o_result_valid  ,
    output              o_mult_ready        
);


/*************** function ***************/
function integer clog2;
    input [31:0] number;
    begin
        for (clog2 = 0; number > 0; clog2 = clog2 + 1)
            number = number >> 1;
    end
endfunction

/*************** parameter ***************/
localparam CNT_WIDTH = clog2(M);

/*************** reg ***************/
reg [M+N-1:0]       r_mult1;
reg [M-1:0]         r_mult2;
reg [M+N-1:0]       r_mult_acc;
reg [N+M-1:0]       r_result;
reg                 r_result_valid;
reg                 r_mult_ready;
reg [CNT_WIDTH-1:0] r_mult_cnt;

/*************** wire ***************/
wire w_mult_active;

/*************** assign ***************/
assign o_result         = r_result;
assign o_result_valid   = r_result_valid;
assign o_mult_ready     = r_mult_ready;
assign w_mult_active    = i_data_valid & o_mult_ready;

/*************** always ***************/

// when the w_mult_active is high let the r_mult_ready be low,indicating that the multiplier is working
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_mult_ready <= 1'b1;
    end
    else if (w_mult_active) begin
        r_mult_ready <= 1'b0;
    end
    else if (r_result_valid) begin
        r_mult_ready <= 1'b1;
    end
    else begin
        r_mult_ready <= r_mult_ready;
    end
end

/*
        1 1 0 1（13）
        *   1 1（3）
    ----------------
        1 1 0 1
      1 1 0 1
----------------
    1 0 0 1 1 1（39）
*/
// achieve the multiplication logic,shift and add,when the r_mult_cnt == M, finish the multiplication

always @(posedge i_clk or i_rst_n) begin
    if (!i_rst_n) begin
        r_mult_cnt <= {CNT_WIDTH{1'b0}};
    end
    else if (r_result_valid) begin
        r_mult_cnt <= {CNT_WIDTH{1'b0}};
    end
    else if (!r_mult_ready) begin
        r_mult_cnt <= r_mult_cnt + 1'b1;
    end
    else begin
        r_mult_cnt <= r_mult_cnt;
    end
end


always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_mult1 <= {(M+N){1'b0}};
    end
    else if (w_mult_active) begin
        r_mult1 <= {{M{1'b0}},i_mult1};
    end
    else if (r_mult_cnt != M) begin
       r_mult1 <= r_mult1 << 1'b1; 
    end
    else begin
        r_mult1 <= {(M+N){1'b0}};
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_mult2 <= {M{1'b0}};
    end
    else if (w_mult_active) begin
        r_mult2 <= i_mult2;
    end
    else if (r_mult_cnt != M) begin
       r_mult2 <= r_mult2 >> 1'b1; 
    end
    else begin
        r_mult2 <= {M{1'b0}};
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_mult_acc <= {(M+N){1'b0}};
    end
    else if (w_mult_active) begin
        r_mult_acc <= {(M+N){1'b0}};
    end
    else if (r_mult_cnt != M) begin
       r_mult_acc <= r_mult2[0] ? (r_mult1 + r_mult_acc) : r_mult_acc;
    end
    else begin
        r_mult_acc <= {(M+N){1'b0}};
    end
end


/******************** output result ********************/
always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_result <= {(M+N){1'b0}};
    end
    else if (r_mult_cnt == M) begin
        r_result <= r_mult_acc;
    end
    else begin
        r_result <= r_result;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        r_result_valid <= 1'b0;
    end
    else if (r_mult_cnt == M) begin
        r_result_valid <= 1'b1;
    end
    else begin
        r_result_valid <= 1'b0;
    end
end

endmodule