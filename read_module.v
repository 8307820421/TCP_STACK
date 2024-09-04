`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2024 12:54:07
// Design Name: 
// Module Name: read_module
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


module read_module 
#(
   parameter data_bits = 512,
   parameter address_bits = 10,
   parameter mem_depth = 1024
)
(
    input wire clk,
    input wire resetn,
    
     output wire start_rd_en,
    output reg [address_bits - 1:0] address_b,
    output reg [data_bits - 1:0] datain_b,
    output reg enb,
    output reg web,
    
    input wire [data_bits - 1:0] doutb,
    /*   The fifo_txdata moves to  data buffer as data coming from the read module*/
    output reg [data_bits - 1 :0] fifo_tx_data,
    /* 
      pins from the data buffer  //bram address act as input and going to the addressb for 
      accessing the address from the block memory generator
    */
    output wire [address_bits - 1 :0] address_input
);

integer i;
reg [511:0] mem [ 0 : 1024];
localparam idle = 2'b00;
localparam read_state = 2'b01;
localparam finish_state = 2'b10;
reg [1:0] state = idle, next_state = idle;
reg [3:0] counter;

always @ (posedge clk) 
begin
    if (resetn == 1'b0) 
    begin
       for ( i = 0; i<15; i= i+1) 
       begin
           mem[i] <= 511'b00;
       end

    end

   else begin
    case(state)

     idle : begin
     address_b <= 0;
     datain_b  <= 0;
     enb       <= 0; 
     web       <= 0;
     counter <= 0;
      if (start_rd_en == 1'b1) 
          next_state <= read_state;
      else
         next_state <= idle;
     end


    read_state : begin
         
        if (start_rd_en == 1'b1) 
        begin
          enb <= 1'b1;
          web <= 1'b0;
          address_b <= address_input;
          datain_b <= mem[address_b] ;
          fifo_tx_data <= datain_b; 
         end 
          
          else begin
           web <= 1'b1;
           next_state <= finish_state;
         end

    end
        
   finish_state : begin
    address_b <= 0;
    datain_b  <= 0;
     enb      <= 0; 
     web     <= 0;
    if (start_rd_en == 1'b0) 
        next_state <= idle;
    else
        next_state <= finish_state;
   end

endcase
 end
 end
 //assign dout_b =  (start_rd_en == 1'b1) ? mem[address_b] : 0;
 endmodule
