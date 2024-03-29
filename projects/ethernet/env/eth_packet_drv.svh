//----------------
//Packet driver class
//----------------
typedef e_pckt_c;
class eth_packet_drv_c;

  //Use a virtual interface that points to same interface
  virtual interface eth_sw_if  rtl_intf;

  //Use a mailbox to receive packets from generator
  mailbox mbx_input;

  function new (mailbox mbx, virtual interface eth_sw_if intf);
     mbx_input = mbx;
     this.rtl_intf = intf;
  endfunction

  //Implement a function that can drive the design interface signals
  //as per the packet fields
  task run;
    e_pckt_c pack;
    forever begin
      mbx_input.get(pack);
      $display("packet_drv::Got packet = %s", pack.to_string());
      //Get the packet SA and accordingly drive on port A or port B
      if(pack.src_addr == `PORTA_ADDR) begin
        drive_pack_portA(pack);
      end else if(pack.src_addr == `PORTB_ADDR) begin
        drive_pack_portB(pack);
      end else begin
        $display("Packets SRC neither A not B and hence dropping");
      end
    end
  endtask

  task drive_pack_portA(e_pckt_c pack);
    //Drive signals as per protocol on that packet
    int count;
    int numDwords;
    bit[31:0] cur_dword;
    count=0;
    numDwords= pack.pack_size_bytes/4;
    $display("packet_drv::drive_pack_portA: numDwords=%0d ",numDwords);
    forever @(posedge rtl_intf.clk) begin
      if(!rtl_intf.portAStall) begin
         rtl_intf.eth_drv_cb.inSopA <=1'b0;
         rtl_intf.eth_drv_cb.inEopA <=1'b0;
         cur_dword[7:0] = pack.pack_full[4*count];
         cur_dword[15:8] = pack.pack_full[4*count+1];
         cur_dword[23:16] = pack.pack_full[4*count+2];
         cur_dword[31:24] = pack.pack_full[4*count+3];
         $display("time=%t packet_drv::drive_pack_portA:count=%0d cur_dword=%h",$time,count,cur_dword);
         if(count==0) begin
           rtl_intf.eth_drv_cb.inSopA <=1'b1;
           rtl_intf.eth_drv_cb.inDataA <= cur_dword;
           count = count+1;
         end else if (count== numDwords-1) begin
           rtl_intf.eth_drv_cb.inEopA <=1'b1;
           rtl_intf.eth_drv_cb.inDataA <= cur_dword;
           count = count+1;
         end else if (count== numDwords) begin
           count =0;
           break;
         end else begin
           rtl_intf.eth_drv_cb.inDataA <= cur_dword;
           count= count+1;
         end
      end
    end
  endtask

  task drive_pack_portB(e_pckt_c pack);
    //Drive signals as per protocol on that packet
    int count;
    int numDwords;
    bit[31:0] cur_dword;
    count=0;
    numDwords= pack.pack_size_bytes/4;
    $display("packet_drv::drive_pack_portB: numDwords=%0d ",numDwords);
    forever @(posedge rtl_intf.clk) begin
      if(!rtl_intf.portBStall) begin
         rtl_intf.eth_drv_cb.inSopB <=1'b0;
         rtl_intf.eth_drv_cb.inEopB <=1'b0;
         cur_dword[7:0] = pack.pack_full[4*count];
         cur_dword[15:8] = pack.pack_full[4*count+1];
         cur_dword[23:16] = pack.pack_full[4*count+2];
         cur_dword[31:24] = pack.pack_full[4*count+3];
         if(count==0) begin
           rtl_intf.eth_drv_cb.inSopB <=1'b1;
           rtl_intf.eth_drv_cb.inDataB <= cur_dword;
           count++;
         end else if (count== numDwords-1) begin
           rtl_intf.eth_drv_cb.inEopB <=1'b1;
           rtl_intf.eth_drv_cb.inDataB <= cur_dword;
           count++;
         end else if (count== numDwords) begin
           break;
         end else begin
           rtl_intf.eth_drv_cb.inDataB <= cur_dword;
           count++;
         end
      end
    end
  endtask

endclass
