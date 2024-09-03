`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2024 14:45:57
// Design Name: 
// Module Name: data_buffer
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
 simple data buffer for tcp tx
 data coming from bram portB
 only writing the data to data buffer
*/

module data_buffer #(
   parameter mem_depth = 1024,// buffer size 1KB
   parameter data_bits = 512
 )
 
(
  input wire clk,
  input wire resetn,
  
  input wire fifo_wr_en,
  output reg [data_bits - 1:0]input_fifodata, // giving  the data to packet buffer
 
//  output  reg  fifo_rd_en,
  input  wire [data_bits - 1:0]output_fifodata  // receivng the data from read module

 

    );
    
  integer i;
    
  reg [data_bits - 1 :0] mem [0:mem_depth - 1];

  reg [11:0] count ;
  
  /*pointer wr and rd pointer
   write pointer required to point to the next data
   rd pointer required when m_axis_tready == 1'b1 then consumer read the data
  */
  reg [9:0] wr_ptr;  
  reg [9:0] rd_ptr;  
  
  /* full and empty signal of fifo
     count tends to last byte// deasserted during the write part
     count  tends to 0 // deasserted during the read part
  */
  wire fifo_full;     
  wire fifo_empty;  
  
  /* assigning the fifo full when the count == last byte of data 
  (as count keep the track of data byte by byte
   when reaches to last byte of data.*/
  
  assign fifo_full = (count == (mem_depth-1)) ? 1'b1: 1'b0; 
  //assign fifo_empty = (count == 0) ? 1: 1'b0;
  
  
  /* always block to set the reset logic */
  
  always @ (posedge clk) 
  begin
  if (resetn == 1'b0 ) 
  begin
  wr_ptr <= 0;
  rd_ptr <= 0;
  count <= 0;  
     /* initialize the memory during reset set to 1'b0 */
 for (i = 0; i <=mem_depth - 1 ; i =  i+1) 
     begin
        mem[i] <= 8'h00;

     end  
     
  end
  
 else if ((fifo_wr_en == 1'b1) && (fifo_full == 1'b0))  
   begin
      mem[wr_ptr] <= input_fifodata;
      wr_ptr <= wr_ptr + 1;
      count <= count + 1;
//     output_fifodata<= 0;
   end
    
  end

endmodule
