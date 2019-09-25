//--------------------
// packet class definition
//--------------------
class e_pckt_c;

  rand bit[31:0]  src_addr;
  rand bit[31:0]  dst_addr;
  rand byte pack_data[$];
  bit [31:0]  pack_crc;

  int pack_size_bytes;
  byte pack_full[$];

  constraint addr_c {
    src_addr inside {'hABCD, 'hBCBA};
    dst_addr inside {'hABCD, 'hBCBA};
  }

  constraint pack_data_c {
    pack_data.size() >= 4;
    pack_data.size() <= 32;
    pack_data.size()%4==0;
  }

  /*constraints for small/large/medium packets

  constraints for data patterns
  fixed pattern
  random pattern
  incrementing pattern
  TBD*/

 function new();
 endfunction

 //CAll this only for ModelSim/eda playground as randomize() is not supported by free simulators
 function void build_custom_random();
   int rand_num;
   rand_num=$urandom_range(0,3);
   case(rand_num)
     0: begin
       src_addr= 'hABCD; dst_addr='hBCBA;
     end
     1: begin
       src_addr= 'hABCD; dst_addr='hABCD;
     end
     2: begin
       src_addr= 'hBCBA; dst_addr='hABCD;
     end
     3: begin
       src_addr= 'hBCBA; dst_addr='hBCBA;
     end
   endcase
   fill_pack_data();
   post_randomize();
 endfunction

 function void fill_pack_data();
   int pack_data_size;
   pack_data_size = $urandom_range(8,24);
   //make it dword aligned (multiple of 4)
   pack_data_size = (pack_data_size >> 2) <<2;
   for(int i=0; i < pack_data_size;i++) begin
     pack_data.push_back($urandom());
   end
 endfunction

 function bit[31:0] compute_crc();
   //TBD
   return 'hABCDDEAD;
 endfunction

 function void post_randomize();
   pack_crc =  compute_crc();
   pack_size_bytes = pack_data.size() + 4+4+4; //data byes + 4B src +4B dest + 4B CRC
   for(int i=0; i < 4; i++) begin
       pack_full.push_back( dst_addr >> i*8);  //0 to 3 bytes DA
   end
   for(int i=0; i < 4; i++) begin
       pack_full.push_back(src_addr >> i*8); //4 to 7 bytes SA
   end
   //Actual Data bytes
   for(int i=0; i < pack_data.size; i++) begin
       pack_full.push_back(pack_data[i]);
   end
   for(int i=0; i < 4; i++) begin
       pack_full.push_back(pack_crc >> i*8); //last 4 bytes CRC
   end
 endfunction

 //return a string that prints all fields
 function string to_string();
   string msg;
   msg = $psprintf("sa=%x da=%x crc=%x",src_addr,dst_addr, pack_crc);
   return msg;
 endfunction

 function bit compare_pack(e_pckt_c pack);
   if((this.src_addr==pack.src_addr) &&
     (this.dst_addr==pack.dst_addr) &&
     (this.pack_crc==pack.pack_crc) &&
     is_data_match(this.pack_data, pack.pack_data)) begin
      return 1'b1;
   end
      return 1'b0;
 endfunction

 function bit is_data_match(byte data1[], byte data2[]);
   return 1'b1; //TBD
 endfunction

endclass : e_pckt_c
