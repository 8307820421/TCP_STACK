# TCP_STACK_IN_Verilog
Here I have developed the axis_write module with testbench
Here I have also developed the axis_read module with testbench
Here I also developed the data buffer module with test bench

# The TCP packet builder is left  for building :
Problem statement : 
1) How to configure the src port , dest port at transport layer does we assigned randomly if  it is coming from
   externally then how it will assigned inside the TCP module.
2) We are building the packets so it means we need to set the sequence number and ack number manually ?
3) Also after build up the packet we are finding the checksum for error detection and do  we are focussing on to develop the CRC check also ?
4) Or By developing the Checksum at TCP stack we will check our stack is working fine or data tranasfer to MAC . This all process will happened at TX side?

# concept of window size in TCP header :-
  The window size plays a crucial role for handling the large amount of data in bytes with respect to your buffer depth. The window size is of 16 bits so the maximum supoortable width is 
  (2^16 = 65535). But in case of HFT application the window size can be scaled up to many bytes based upon the requirement as per RFC 9293 documentation of TCP protocol . So, there are 
  the two formula to caluate the window size and your window size also inform to RX how much buffer size is left like in wireshark you can see when you tried to capture the packets.

 # So , the formula is :
      window size ( maxmium bits ) = buffer_depth * ( data_bits / 8) ;
              let buffer depth == 1024
                  data bits == 512
                  then total window size depth = 65535 .

   # The window size is changeable based upon how much bytes of data acquired by the input data to fill the buffer size.
            *lets say the buffer is filled with 64 bytes
                 ->then window size is = ( 65535 - 64 ) == 65471 (left for next bytes of data depending upon input).

   # There is another option to scale the window size if required :
        officially the window size is 16 bits hence maximum it will be 65535
              but , we can scale the window size by scaling factor.
                   suppose , you have scaling factor is 8,
                      then , effective_window size  = base window size * 2(^8) = 65535 *256 = 524,280 bytes.
  This allows the TCP receiver to handle a much larger window size than the default 65,535 bytes.  
 # The scalingin verilog is done by shifiting opertation (left shift) : 
      always @(*) begin
        effective_window_size = base_window_size << window_scale_factor; 
      end
 // Compute the effective window size with scaling
 // Shift left by scaling factor (2^S)
