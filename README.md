# TCP_STACK_IN_Verilog
->Here I have developed the axis_write module with testbench

->Here I have also developed the axis_read module with testbench

->Here I also developed the data buffer module with test bench

->After this the transport layer or header structure tcp tx client FSM is created.(private to company).

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

 # TCP_Length for TCP header :- 
 The TCP length is not the integral part of the TCP header structure but it calcuates the  (TCP header + TCP payload data )length.
 The Header is constant if we are not including the options and padding field.
 But the TCP payload data is changing based upon the how much bytes of data receiving from kernel . Also, the payload data is tracked through the counter that plays a crucial role 
 to find the payload data bytes.
 The logic behind this :- 
tcp_length <= (tcp_headero_bits / 8) + (count * (data_bits / 8));

# Initialization: Set tcp_length to 0 during reset.
Update on Write: When new data is written to the FIFO, the tcp_length is updated to reflect the addition of that data.
Update on Read: When data is read from the FIFO, the tcp_length is recalculated to account for the remaining data.

# tcp_tx_length_reg <= (tcp_headero_bits / 8) + (count * (data_bits / 8));
  does tcp length calcualted based upon the data bits  if yes then why count is multiplied with this to calualted the tcp length?
# solution :
Yes, the tcp_length is calculated based on both the header size and the payload size (the data bits). Here's a breakdown of why the count is multiplied by data_bits / 8 in the calculation:
         tcp_tx_length_reg <= (tcp_headero_bits / 8) + (count * (data_bits / 8));

# 1. Header Length (tcp_headero_bits / 8):
      tcp_headero_bits represents the size of the TCP header in bits.Dividing by 8 converts this from bits to bytes.
      The header size is constant and doesn't change during data transmission.
# 2. Data Length (count * (data_bits / 8)):
     data_bits is the width of the data you're sending in each transaction (e.g., 256 bits). Dividing by 8 converts data_bits from bits to bytes, as the length in the TCP header is 
     expressed in bytes.count keeps track of how many chunks of data are stored in the FIFO. Each chunk is data_bits wide.
     By multiplying count by (data_bits / 8), you're calculating the total number of bytes of payload data in the TCP segment.

# Why Multiply by count?
  The count variable indicates how many chunks of data (of size data_bits) are currently in the FIFO buffer. Multiplying count by data_bits / 8 gives the total size of the data stored in 
  the FIFO in bytes.
# For example:
 If data_bits is 256 (which is 32 bytes), and count is 10, this means you have 10 chunks of 256 bits (32 bytes), so the total payload size is 10 * 32 = 320 bytes.
 The tcp_length in this case would be tcp_headero_bits / 8 + 320, where the first term represents the header size.
# Complete Picture:
  tcp_headero_bits / 8: This represents the constant size of the TCP header in bytes.
  count * (data_bits / 8): This gives the size of the variable-length payload in bytes.

Thus, the total tcp_length is the sum of the header and payload sizes, and it's updated dynamically based on how much data is in the FIFO (count).

# Summary:
You multiply by count to capture how much data (in bytes) is currently stored in the FIFO and is part of the TCP payload. Without multiplying by count, you'd only be accounting for one chunk of data, not the total payload length.

# The TCP length field itself will not increase in width. The TCP length, represented as a 16-bit value, remains fixed at 16 bits. The logic you're using calculates the value of the length, not the width.
--> Here's the key point:
1) The field size of tcp_length in the TCP header is always 16 bits, as defined by the TCP specification.
2) The value of tcp_length will vary based on how much data is in the packet (i.e., the header size plus the payload size), but it will be represented using 16 bits.

# Example:
If you calculate the length using this logic:
      tcp_tx_length_reg <= (tcp_headero_bits / 8) + (count * (data_bits / 8));

# Assume tcp_headero_bits is 160 bits (which is 20 bytes).
If count is 10 and data_bits is 256,
    then count * (data_bits / 8) would be 10 * 32 = 320 bytes.
   The total length is 20 (header) + 320 (payload) = 340 bytes. This 340 bytes will be stored in the 16-bit TCP length field.

# Important Note:
The value of tcp_length can range from 0 to 65535 (since it’s a 16-bit field), but the width (i.e., the number of bits used to represent it) is always 16 bits.

If the total size exceeds 65535 bytes, the value would overflow, but in typical TCP scenarios, the total size of a packet (header + payload) usually does not approach this limit due to network constraints like Maximum Transmission Unit (MTU).

# In summary:
The width of the tcp_length field stays 16 bits.
The value stored in the tcp_length field varies but is constrained to 16 bits, meaning it can range from 0 to 65535 bytes.

# If the total size exceeds 65535 bytes, the value would overflow, but in typical TCP scenarios, the total size of a packet (header + payload) usually does not approach this limit due to network constraints like Maximum Transmission Unit (MTU) can you explain this?
# solution : ->
  In TCP, the Maximum Transmission Unit (MTU) refers to the largest size of a packet (in bytes) that can be transmitted over a network link without needing fragmentation. This 
  limitation is enforced by the underlying data link layer (e.g., Ethernet) and effectively ensures that the total size of TCP segments (including both the header and the payload) 
  doesn't exceed a certain threshold.

# Explanation of MTU and TCP Packet Size Limits
# Typical MTU Values:
  The MTU varies depending on the type of network being used:
-> Ethernet (most common): The default MTU is 1500 bytes.
  This MTU includes the entire IP packet, which contains the TCP segment (header + payload).
  Other network types (like certain VPNs or older networks) may have different MTU values, but Ethernet's MTU of 1500 bytes is by far the most common in modern networks.

-> Total Packet Size: In the context of TCP over IP, a packet includes:
   The TCP header (typically 20 bytes but can be more if TCP options are present).
   The TCP payload (the data being transmitted).
   Relationship Between TCP Length and MTU: Even though the TCP length field (in the TCP header) can theoretically represent a value of up to 65535 bytes, the actual size of TCP packets 
   is almost always limited by the MTU.
   
# For example, on an Ethernet network with a 1500-byte MTU, the IP packet can be at most 1500 bytes.
   Of this 1500 bytes, the IP header takes 20 bytes (without options). This leaves 1480 bytes for the TCP segment (header + payload).
   If the TCP header is 20 bytes, this leaves 1460 bytes for the TCP payload.

# Why Packets Don’t Exceed 65535 Bytes:
Even though TCP can technically support packets as large as 65535 bytes (since the length field is 16 bits), the MTU limitation prevents packets from approaching this size in most cases.
Networks are configured to avoid sending packets that exceed the MTU because larger packets would have to be fragmented at the IP layer, which adds overhead and reduces efficiency.

# TCP Segment and Fragmentation:
  If a packet exceeds the MTU size, the IP layer has to fragment it into smaller pieces that fit within the MTU size.
  For example, if you try to send 20,000 bytes over a network with an MTU of 1500 bytes, the packet would need to be split into multiple fragments.

# Example of Packet Sizing in Practice:
 ->   Let’s say you want to send a 1000-byte payload.
 ->   The Ethernet MTU is 1500 bytes.
 ->   The IP header takes 20 bytes, and the TCP header takes 20 bytes.
 ->   The total packet size is 1040 bytes (20 bytes IP header + 20 bytes TCP header + 1000 bytes of data), which fits within the MTU, so it’s sent as a single packet.
->    If you wanted to send 70,000 bytes, which exceeds the 65535-byte limit in the TCP length field, it would need to be sent in multiple segments, each respecting the network’s MTU 
     limit.

# Summary:
 -> The TCP length field can hold values up to 65535 bytes, but in practice, the packet size (TCP header + data) is limited by the MTU of the network.
 
 -> The Ethernet MTU (1500 bytes) ensures that most TCP packets are much smaller than the theoretical 65535-byte limit.
 
 -> Fragmentation occurs if a packet size exceeds the MTU, but it’s usually avoided to improve network efficiency.
 
 -> The typical TCP packet size in most scenarios is around 1460 bytes of payload (MTU of 1500 bytes, minus 40 bytes for IP and TCP headers). Therefore, the maximum TCP length of 65535 
   bytes is rarely, if ever, reached in practical networks.




 
