`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.09.2024 10:10:11
// Design Name: 
// Module Name: axis_fifo_alternate
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
This fifois also a data buffer for wr and rd 
but here this data buffer also controll bram module for giving the address and enabling the read module
hence it acts as controller as well as buffer to transfer the data to next module (packet buffer).
*/

module data_buffer #(
   parameter mem_depth = 1024,// buffer size 1KB
   parameter data_bits = 512,
   parameter address_bits = 10
 )
(
  input wire clk,
  input wire resetn,
  
  //slave pins // receving the data from master // writing
  input wire fifo_wr_en,
  input wire [data_bits - 1:0] fifo_rxdata,  // receive from fifo
 
  
 // master pins // master sending the data to slave // reading
  output  reg  fifo_rd_en,
  output reg [data_bits - 1:0]fifo_txdata,
  
  // controlling bram address and rd_en
  input wire [address_bits - 1:0] address_input
 

    );
    
  integer i;
    
  reg [data_bits - 1 :0] mem [0:mem_depth - 1];

  reg [11:0] count ;
  // pointer wr and rd pointer
  reg [9:0] wr_ptr;  // write pointer required to point to the next data
  reg [9:0] rd_ptr;  // rd pointer required when m_axis_tready == 1'b1 then consumer read the data
  
  // full and empty signal of fifo
  wire fifo_full;     // count tends to last byte// deasserted during the write part
  wire fifo_empty;  // count  tends to 0 // deasserted during the read part
  
  // assigning the fifo full when the count == last byte of data (as count keep the track of data byte by byte
  
  //assign fifo_full = (count == (mem_depth-1)) ? 1'b1: 1'b0; // when reaches to last byte of data.
  assign fifo_full = (count == (mem_depth - 1 )) ? 1'b1: 1'b0; // when reaches to last byte of data.
  assign fifo_empty = (count == 0) ? 1'b1: 1'b0;
  
  
  // always block to set the reset logic
  
  always @ (posedge clk) 
  begin
  if (resetn == 1'b0 ) 
  begin
     wr_ptr <= 0;
     rd_ptr <= 0;
     count <= 0;
     // master pin
   fifo_rd_en <= 1'b0;
   fifo_txdata <= 0;

     
     // initialize the memory during reset set to 1'b0
     for (i = 0; i <=(mem_depth - 1) ; i =  i+1) 
     begin
        mem[i] <= 8'h00;

     end  
     
  end
  
  /// assigning the condition based upon slave input
  /*
    update the fifo memory and writing part
   if s_axis_tvalid is enable and fifo_full is low then  slave pins updated to memory contents.
   And wr_ptr will increment
   counter will also increment.
   writing part is done .
  */  
 else if ((fifo_wr_en == 1'b1) && (fifo_full == 1'b0))  
   begin
      mem[wr_ptr] <= fifo_rxdata;
      wr_ptr <=  wr_ptr + 1;
      count  <=  count + 1;
       fifo_rd_en <= 0;
       fifo_txdata<= 0;
   end
   
   /* Read data from the FIFO if it's not empty and mux is ready
      Here first scenario is that when m_axis_tready is high the data will be read
      count deccrase during reading the data
    */
    
 else if ((fifo_rd_en == 1'b1) && (fifo_empty == 1'b0))  
    begin
       fifo_txdata <= mem[rd_ptr]; 
        rd_ptr <= rd_ptr + 1;
        count <= count - 1; 
    end
    
  end

/*
 fifo rd_en active from packet buffer 
 but currently I am assgining it when when fifo_empty is 0.
 logic for rd_en although it is controolled  by another module
*/

 // Logic to assert fifo_rd_en when FIFO is not empty
  always @(*) 
  begin
    if (fifo_wr_en == 1'b0) 
    begin
      fifo_rd_en = 1'b1;
    end
    else 
    begin
      fifo_rd_en = 1'b0;
    end
  end


endmodule
