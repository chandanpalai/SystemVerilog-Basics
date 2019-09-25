//-----------------------------
//Packet generator class
//-----------------------------
typedef e_pckt_c;
class eth_packet_gen_c;

  //Implement a random member for number of packets to be generated
  int num_packs;

  //Use a mail box and put these generated packets into that
  //This mailbox will be later used by the driver
  mailbox mbx_out;

  function new (mailbox mbx);
    mbx_out =  mbx;
  endfunction

  //Method
  task run;
    e_pckt_c pack;
    num_packs = 2; // $urandom_range(2,3);
    for (int i=0; i < num_packs; i++) begin
      //Create packet , randomize and put to mailbox
      pack = new();
`ifdef NO_RANDOMIZE
      pack.build_custom_random();
`else
      assert(pack.randomize());
`endif
      mbx_out.put(pack);
    end
  endtask

endclass
