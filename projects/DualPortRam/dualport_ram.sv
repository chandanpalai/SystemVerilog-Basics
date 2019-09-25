/*Synchronous dual port RAM
uninitialized memory contents
one port for read and write each
one port for data in and data out each
*/

module dp_ram(
              input  logic           clk       ,       // clk
              input  logic  [7:0]    d_in     ,       // input data
              output logic  [7:0]    d_out    ,       // Output data
              input  logic           write_en    ,       // 1 => write port enabled
              input  logic  [7:0]   write_addr ,     // Memory Write port address
              input  logic           read_en,            // 1 => read port enabled
              input  logic  [7:0]    read_addr       // Memory Read port address
              );
 

//Memory array 
logic [7:0] mem [255:0];
 
//If enabled, write to the memory array
always @ (posedge clk)
begin
  if(write_en)                      //Write port
    mem[write_addr] = d_in;
  if(read_en)                       //Read port
    d_out = mem[read_addr];
end
 
endmodule
