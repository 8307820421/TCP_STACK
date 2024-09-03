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
`define clk_period 10;
module data_buffer_tb();
   parameter mem_depth = 1024;// buffer size 1KB
   parameter data_bits = 512;

  reg clk;
  reg  resetn;
  
  //slave pins // receving the data from master // writing
reg fifo_wr_en;
 wire [data_bits - 1:0]input_fifodata;
 reg  [data_bits - 1:0]output_fifodata;


/*
  Instantiating the module
  
*/

data_buffer # 
(
  .mem_depth(mem_depth),
  .data_bits (data_bits)
)

dut (
  .clk(clk),
  .resetn(resetn),
  
  //slave pins // receving the data from master // writing
  
 .fifo_wr_en(fifo_wr_en),
 .input_fifodata(input_fifodata),
 .output_fifodata(output_fifodata)
 
);

integer i;
always #10 clk = ~clk;

initial begin

clk = 1'b0;
resetn = 1'b0;
fifo_wr_en = 1'b0;
output_fifodata = 0;
repeat (5) @(posedge clk); 

resetn = 1'b1;

for (i= 0; i <= mem_depth - 1 ; i = i+1) 
begin
@(posedge clk);

fifo_wr_en = 1'b1;
//output_fifodata = input_fifodata ;  // This will use 
output_fifodata = $random ;          // taking to check the example
//@ (posedge clk);  // This i am removing because it lead to one another clock cycle latency
end
#10 $finish;
end

endmodule
