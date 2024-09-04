`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2024 15:05:35
// Design Name: 
// Module Name: data_buffer_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*
  here I am settting the count limit up to memory depth 
  so wr_pointer also increment up to that
  as fifo full condition asserted when counter reaches to memory depth.
*/
`define clk_period 10;
module data_buffer_tb();
   parameter data_bits = 512;
   parameter address_bits = 10;
   parameter mem_depth = 1024; // buffer size 1KB

  reg clk;
  reg  resetn;
  
  //slave pins // receving the data from master // writing
  reg fifo_wr_en;
  reg [data_bits - 1:0]fifo_rxdata;
  
  wire fifo_rd_en;
  wire [data_bits - 1:0]fifo_txdata;
  
  reg  [address_bits - 1 :0] address_input;


/*
  Instantiating the module
  
*/

data_buffer # 
(
  .data_bits (data_bits),
  .address_bits (address_bits),
  .mem_depth(mem_depth)
)

dut (
  .clk(clk),
  .resetn(resetn),
  
  //slave pins // receving the data from master // writing
 .fifo_wr_en(fifo_wr_en),
 .fifo_rxdata(fifo_rxdata),
 .fifo_txdata(fifo_txdata),
 .address_input(address_input)
 
);

/*
  reg clk;
  reg  resetn;
  reg fifo_wr_en;
  reg [data_bits - 1:0]fifo_rxdata;
    reg  [address_bits - 1 :0] address_input;
*/
integer i;
always #10 clk = ~clk;

initial begin

clk = 1'b0;
resetn = 1'b0;
fifo_wr_en = 1'b0;
address_input = 0;
fifo_rxdata = 0;
repeat (5) @(posedge clk); 

resetn = 1'b1;

for (i= 0; i <= 1025  ; i = i+1) 
begin
@(posedge clk);

fifo_wr_en = 1'b1;
//output_fifodata = input_fifodata ;
address_input = i;
//fifo_rxdata =  $random;

//@ (posedge clk);  // This i am removing because it lead to one another clock cycle latency
end



/*
for read enable
*/

for ( i =  0 ;  i<= 1025 ; i= i+1) 
@(posedge clk);
begin
fifo_wr_en = 1'b0;
address_input = i;
fifo_rxdata = 0;
end

#10 $finish;
end

endmodule

