//--------------
//Packet checker class
//--------------
typedef e_pckt_c ;
class e_pckt_chk_c ;

 /* //Use four mailboxes to see what packets goes in and comes out
 Mailbox 0 => packets seen on input port A
 Mailbox 1 => packets seen on input port B
 Mailbox 2 => packets seen on output port A
 Mailbox 3 => packets seen on output port B */
  mailbox mbx_in[4];

  //For each port - get  a packet form input port.
  //Then call Function 1 (generateExpectedpack)  and generate expected packets (Maintain 2 expected packet queue for 2 ports)

  //queue of expected packets on port A and B
  e_pckt_c exp_pack_A_q[$];
  e_pckt_c exp_pack_B_q[$];

  function new(mailbox mbx[4]);
    for(int i=0;i<4;i++) begin
      this.mbx_in[i] = mbx[i];
    end
  endfunction

  //--------------------
  //Main evaluation task
  //4 threads - 2 of them keeps getting packets on port A and processes them to generate expected packet in A/B queue
  //          - 2 of them keeps getting packets seen on output ports A and B and compares/checks agains expected packet Q
  //--------------------
  task run;
    $display("packet_chk::run() called");
      fork
         get_and_process_pack(0);
         get_and_process_pack(1);
         get_and_process_pack(2);
         get_and_process_pack(3);
      join_none
  endtask

  task get_and_process_pack(int port);
    e_pckt_c pack;
    $display("packet_chk::process_pack on port=%0d called", port);
    forever begin
      mbx_in[port].get(pack);
      $display("time=%0t packet_chk::got packet on port=%0d packet=%s",$time, port, pack.to_string());
      if(port <2) begin //input packets
        gen_exp_packet_q(pack);
      end else begin //output packets
        chk_exp_packet_q(port, pack);
      end
    end
  endtask

  function void gen_exp_packet_q(e_pckt_c pack);
    if(pack.dst_addr == `PORTA_ADDR) begin
        exp_pack_A_q.push_back(pack);
    end else if(pack.dst_addr == `PORTB_ADDR) begin
        exp_pack_B_q.push_back(pack);
    end else begin
        $error("Illegal Packet received");
    end
   endfunction

   function void chk_exp_packet_q(int port, e_pckt_c pack);
     e_pckt_c exp;
     if(port==2) begin
       exp = exp_pack_A_q.pop_front();
     end else if (port==3) begin
       exp = exp_pack_B_q.pop_front();
     end
     if(pack.compare_pack(exp)) begin
       $display("Packet on port 2 (output A) matches");
     end else begin
       $display("Packet on port 2 (output A) mismatches");
     end
   endfunction

endclass
