`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.09.2024 15:09:51
// Design Name: 
// Module Name: read_module_tb
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

module read_module_tb();
 parameter data_bits = 512;
 parameter address_bits = 10;
 parameter mem_depth = 1024;
 
 reg clk;
 reg resetn;
 wire start_rd_en;


wire [address_bits - 1:0] address_b;
wire [data_bits - 1:0] datain_b;
wire enb;
wire web;
    
 reg [data_bits - 1:0] doutb;
 wire [data_bits - 1 :0] fifo_tx_data;
    /* 
      pins from the data buffer  //bram address act as input and going to the addressb for 
      //accessing the address from the block memory generator
    */
 wire [address_bits - 1 :0] address_input;

/*
  instantiating the module
*/

read_module #(
.data_bits(data_bits),
.address_bits(address_bits) ,
.mem_depth(mem_depth) 
)
dut 
( 
 .clk(clk),
 .resetn(resetn),
 .start_rd_en(start_rd_en),
 .address_b (address_b),
 .datain_b (datain_b),
 .enb(enb),
 .web(web),
    
.doutb(doutb),
.fifo_tx_data(fifo_tx_data),
    /* 
      pins from the data buffer  //bram address act as input and going to the addressb for 
      //accessing the address from the block memory generator
    */
.address_input(address_input)
   
);

integer i;

always #10  clk = ~ clk;

initial begin
 clk = 0;
 resetn = 1'b0;
 doutb = 0;
 repeat(5) @(posedge clk);
 
 resetn = 1'b1;
 for ( i= 0;  i<= 1025 ; i= i+1) 
 begin
 @(posedge clk);
 
 doutb <= datain_b;
 
 end
 
 
#10 $finish;
end

endmodule
    
