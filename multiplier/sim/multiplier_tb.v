module multiplier_tb;

parameter N = 8;
parameter M = 4;

reg                 i_clk         ;
reg                 i_rst_n       ;
reg                 i_data_valid  ;
reg     [N-1:0]     i_mult1       ;
reg     [M-1:0]     i_mult2       ;
wire    [N+M-1:0]   o_result      ;
wire                o_result_valid;
wire                o_mult_ready  ;

initial begin
    i_clk = 1'b0;
    forever #10 i_clk = ~i_clk;
end

initial begin
    i_rst_n = 1'b0;
    #100 i_rst_n = 1'b1;
    mult_data_in(25,5);
    mult_data_in(16,10);
    mult_data_in(10,4);
    mult_data_in(15,7);
    mult_data_in(215,9);
    wait(o_result_valid);
    #100;
    $finish;
end


task mult_data_in ;  
    input [N-1:0]   mult1   ;
    input [M-1:0]   mult2   ;
    begin
        @(posedge i_clk )       ;
        wait(o_mult_ready)      ; 
        i_data_valid    = 1'b1  ;
        i_mult1         = mult1 ;
        i_mult2         = mult2 ;
        @(posedge i_clk )       ;
        i_data_valid    = 1'b0  ;
        i_mult1         = 0 ;
        i_mult2         = 0 ;
    end
endtask


multiplier #(
    .N                  (N),
    .M                  (M)
)multiplier_inst(
    .i_clk              (i_clk          ),
    .i_rst_n            (i_rst_n        ),
    .i_data_valid       (i_data_valid   ),
    .i_mult1            (i_mult1        ),   //i_mult1 * i_mult2
    .i_mult2            (i_mult2        ),
    .o_result           (o_result       ),
    .o_result_valid     (o_result_valid ),
    .o_mult_ready       (o_mult_ready   )    
);


endmodule