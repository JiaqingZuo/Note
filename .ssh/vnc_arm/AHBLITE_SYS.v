//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT (“LICENCE?) IS A LEGAL AGREEMENT BETWEEN      //
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  //
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   //
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  //
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   //
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   //
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    //
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                //
//                                                                              //
//ARM hereby grants to you, subject to the terms and conditions of this Licence,//
//a non-exclusive, worldwide, non-transferable, copyright licence only to       //
//redistribute and use in source and binary forms, with or without modification,//
//for academic purposes provided the following conditions are met:              //
//a) Redistributions of source code must retain the above copyright notice, this//
//list of conditions and the following disclaimer.                              //
//b) Redistributions in binary form must reproduce the above copyright notice,  //
//this list of conditions and the following disclaimer in the documentation     //
//and/or other materials provided with the distribution.                        //
//                                                                              //
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     //
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     //
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR //
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE //
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, //
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    //
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.//
//////////////////////////////////////////////////////////////////////////////////


module AHBLITE_SYS(
	//CLOCKS & RESET
	input		wire				HCLK,
	input		wire				HRESETn, 
	input       wire               btn,
	input       wire               rx,
	//TO BOARD LEDs
	output    	wire	[7:0]    	LED,
	output      wire   [6:0]       seg,
    output      wire   [7:0]       an,
    output      wire               dp,
    output      wire               tx,
    output      wire               hs,
    output      wire               vs,
    output      wire  [11:0]       rgb
);
 
//AHB-LITE SIGNALS 
//Gloal Signals

//Address, Control & Write Data Signals
wire [31:0]		    HADDR;
wire [31:0]		    HWDATA;
wire 				HWRITE;
wire [1:0] 		    HTRANS;
wire [2:0] 		    HBURST;
wire 				HMASTLOCK;
wire [3:0] 		    HPROT;
wire [2:0] 		    HSIZE;
//Transfer Response & Read Data Signals
wire [31:0] 	    HRDATA;
wire 				HRESP;
wire 				HREADY;

//SELECT SIGNALS
wire [3:0] 		    MUX_SEL;

wire 				HSEL_MEM;
wire 				HSEL_LED;
wire               HSEL_SEG7;
wire               HSEL_TIMER;
wire               HSEL_UART;
wire               HSEL_VGA;

//SLAVE READ DATA
wire [31:0] 	    HRDATA_MEM;
wire [31:0] 	    HRDATA_LED;
wire [31:0]        HRDATA_SEG7;
wire [31:0]        HRDATA_TIMER;
wire [31:0]        HRDATA_UART;
wire [31:0]        HRDATA_VGA;
//SLAVE HREADYOUT
wire 				HREADYOUT_MEM;
wire 				HREADYOUT_LED;
wire               HREADYOUT_SEG7;
wire               HREADYOUT_TIMER;
wire               HREADYOUT_UART;
wire               HREADYOUT_VGA;
//CM0-DS Sideband signals
wire 				LOCKUP;
wire 				TXEV;
wire 				SLEEPING;
wire [15:0]		    IRQ;
wire               Int;
wire               Int_timer;
wire               Int_uart;
wire               LOCK;

wire                HSEL_IMG1;
wire [31:0] 	     HRDATA_IMG1;
wire                HREADYOUT_IMG1;

wire                HSEL_IMG2;
wire [31:0] 	     HRDATA_IMG2;
wire                HREADYOUT_IMG2;

wire                HSEL_IMG3;
wire [31:0] 	     HRDATA_IMG3;
wire                HREADYOUT_IMG3;

wire                HSEL_IMGF;
wire [31:0] 	     HRDATA_IMGF;
wire                HREADYOUT_IMGF;


//SYSTEM GENERATES NO ERROR RESPONSE
assign 			HRESP = 1'b0;

//CM0-DS INTERRUPT SIGNALS  
assign 			IRQ = {13'b0000_0000_0000_0,Int_uart,Int_timer,Int};
//assign 			LED[7] = LOCKUP;

// Clock divider, divide the frequency by two, hence less time constraint 

// INST_TAG_END ------ End INSTANTIATION Template ---------
              
//AHBLite MASTER --> CM0-DS
pb_debounce Inst_pb_debounce(
    .clk(HCLK),
    .resetn(HRESETn),
    .pb_in(btn),
    .pb_out(),
    .pb_tick(Int)
  );
  
CORTEXM0DS u_cortexm0ds (
	//Global Signals
	.HCLK        (HCLK),
	.HRESETn     (HRESETn),
	//Address, Control & Write Data	
	.HADDR       (HADDR[31:0]),
	.HBURST      (HBURST[2:0]),
	.HMASTLOCK   (HMASTLOCK),
	.HPROT       (HPROT[3:0]),
	.HSIZE       (HSIZE[2:0]),
	.HTRANS      (HTRANS[1:0]),
	.HWDATA      (HWDATA[31:0]),
	.HWRITE      (HWRITE),
	//Transfer Response & Read Data	
	.HRDATA      (HRDATA[31:0]),			
	.HREADY      (HREADY),					
	.HRESP       (HRESP),					

	//CM0 Sideband Signals
	.NMI         (1'b0),
	.IRQ         (IRQ[15:0]),
	.TXEV        (),
	.RXEV        (1'b0),
	.LOCKUP      (LOCKUP),
	.SYSRESETREQ (),
	.SLEEPING    ()
);

//Address Decoder 

AHBDCD uAHBDCD (
	.HADDR(HADDR[31:0]),
	 
	.HSEL_S0(HSEL_MEM),
	.HSEL_S1(HSEL_LED),
	.HSEL_S2(HSEL_SEG7),
	.HSEL_S3(HSEL_TIMER),
	.HSEL_S4(HSEL_UART),
	.HSEL_S5(HSEL_VGA),
	.HSEL_S6(),
	.HSEL_S7(),
	.HSEL_S8(),
	.HSEL_S9(),
	.HSEL_S10(HSEL_IMG1),
	.HSEL_S11(HSEL_IMG2),
	.HSEL_S12(HSEL_IMG3),
	.HSEL_S13(HSEL_IMGF),
	.HSEL_NOMAP(HSEL_NOMAP),
	 
	.MUX_SEL(MUX_SEL[3:0])
);

//Slave to Master Mulitplexor

AHBMUX uAHBMUX (
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.MUX_SEL(MUX_SEL[3:0]),
	 
	.HRDATA_S0(HRDATA_MEM),
	.HRDATA_S1(HRDATA_LED),
	.HRDATA_S2(HRDATA_SEG7),
	.HRDATA_S3(HRDATA_TIMER),
	.HRDATA_S4(HRDATA_UART),
	.HRDATA_S5(HRDATA_VGA),
	.HRDATA_S6(32'd0),
	.HRDATA_S7(32'd0),
	.HRDATA_S8(32'd0),
	.HRDATA_S9(32'd0),
	.HRDATA_S10(HRDATA_IMG1),
	.HRDATA_S11(HRDATA_IMG2),
	.HRDATA_S12(HRDATA_IMG3),
	.HRDATA_S13(HRDATA_IMGF),
	.HRDATA_NOMAP(32'hDEADBEEF),
	 
	.HREADYOUT_S0(HREADYOUT_MEM),
	.HREADYOUT_S1(HREADYOUT_LED),
	.HREADYOUT_S2(HREADYOUT_SEG7),
	.HREADYOUT_S3(HREADYOUT_TIMER),
	.HREADYOUT_S4(HREADYOUT_UART),
	.HREADYOUT_S5(HREADYOUT_VGA),
	.HREADYOUT_S6(1'b1),
	.HREADYOUT_S7(1'b1),
	.HREADYOUT_S8(1'b1),
	.HREADYOUT_S9(1'b1),
	.HREADYOUT_S10(HREADYOUT_IMG1),
	.HREADYOUT_S11(HREADYOUT_IMG2),
	.HREADYOUT_S12(HREADYOUT_IMG3),
	.HREADYOUT_S13(HREADYOUT_IMGF),
	.HREADYOUT_NOMAP(1'b1),
    
	.HRDATA(HRDATA[31:0]),
	.HREADY(HREADY)
);

// AHBLite Peripherals

//AHBLite Slave 
AHB2MEM uAHB2MEM (
	//AHBLITE Signals
	.HSEL(HSEL_MEM),
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.HREADY(HREADY),     
	.HADDR(HADDR),
	.HTRANS(HTRANS[1:0]), 
	.HWRITE(HWRITE),
	.HSIZE(HSIZE),
	.HWDATA(HWDATA[31:0]), 
	
	.HRDATA(HRDATA_MEM), 
	.HREADYOUT(HREADYOUT_MEM)
	//Sideband Signals
	
);

AHB2IMG1 uAHB2IMG1 (
	//AHBLITE Signals
	.HSEL(HSEL_IMG1),
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.HREADY(HREADY),     
	.HADDR(HADDR),
	.HTRANS(HTRANS[1:0]), 
	.HWRITE(HWRITE),
	.HSIZE(HSIZE),
	.HWDATA(HWDATA[31:0]), 
	
	.HRDATA(HRDATA_IMG1), 
	.HREADYOUT(HREADYOUT_IMG1)
	//Sideband Signals
	
);

AHB2IMG2 uAHB2IMG2 (
	//AHBLITE Signals
	.HSEL(HSEL_IMG2),
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.HREADY(HREADY),     
	.HADDR(HADDR),
	.HTRANS(HTRANS[1:0]), 
	.HWRITE(HWRITE),
	.HSIZE(HSIZE),
	.HWDATA(HWDATA[31:0]), 
	
	.HRDATA(HRDATA_IMG2), 
	.HREADYOUT(HREADYOUT_IMG2)
	//Sideband Signals
	
);

AHB2IMG3 uAHB2IMG3 (
	//AHBLITE Signals
	.HSEL(HSEL_IMG3),
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.HREADY(HREADY),     
	.HADDR(HADDR),
	.HTRANS(HTRANS[1:0]), 
	.HWRITE(HWRITE),
	.HSIZE(HSIZE),
	.HWDATA(HWDATA[31:0]), 
	
	.HRDATA(HRDATA_IMG3), 
	.HREADYOUT(HREADYOUT_IMG3)
	//Sideband Signals
	
);

AHB2IMGF uAHB2IMGF (
	//AHBLITE Signals
	.HSEL(HSEL_IMGF),
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.HREADY(HREADY),     
	.HADDR(HADDR),
	.HTRANS(HTRANS[1:0]), 
	.HWRITE(HWRITE),
	.HSIZE(HSIZE),
	.HWDATA(HWDATA[31:0]), 
	
	.HRDATA(HRDATA_IMGF), 
	.HREADYOUT(HREADYOUT_IMGF)
	//Sideband Signals
	
);

//AHBLite Slave 
AHB2LED uAHB2LED (
	//AHBLITE Signals
	.HSEL(HSEL_LED),
	.HCLK(HCLK), 
	.HRESETn(HRESETn), 
	.HREADY(HREADY),     
	.HADDR(HADDR),
	.HTRANS(HTRANS[1:0]), 
	.HWRITE(HWRITE),
	.HSIZE(HSIZE),
	.HWDATA(HWDATA[31:0]), 
	
	.HRDATA(HRDATA_LED), 
	.HREADYOUT(HREADYOUT_LED),
	//Sideband Signals
	.LED(LED[7:0])
);
//AHBLite Slave seg7
AHB7SEGDEC uAHB7SEGDEC(
    .HSEL(HSEL_SEG7),
	.HCLK(HCLK),
    .HRESETn(HRESETn),
	.HREADY(HREADY),
	.HADDR(HADDR),
	.HTRANS(HTRANS[1:0]),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
	.HWDATA(HWDATA[31:0]),
	.HREADYOUT(HREADYOUT_SEG7), 
	.HRDATA(HRDATA_SEG7),
    .seg(seg),
    .an(an),
    .dp(dp)
  );
//AHBLite Slave timer
AHBTIMER Inst_AHBTIMER(
      .HCLK(HCLK),
      .HRESETn(HRESETn),
      .HADDR(HADDR),
      .HWDATA(HWDATA),
      .HTRANS(HTRANS[1:0]),
      .HWRITE(HWRITE),
      .HSEL(HSEL_TIMER),
      .HREADY(HREADY),
      .HRDATA(HRDATA_TIMER),
      .HREADYOUT(HREADYOUT_TIMER),
      .timer_irq(Int_timer)
  );
//AHBLite Slave UART
AHBUART Inst_AHBUART(
      .HCLK(HCLK),
      .HRESETn(HRESETn),
      .HADDR(HADDR),
      .HTRANS(HTRANS),
      .HWDATA(HWDATA),
      .HWRITE(HWRITE),
      .HREADY(HREADY),
      .HREADYOUT(HREADYOUT_UART),
      .HRDATA(HRDATA_UART),
      .HSEL(HSEL_UART),
      .RsRx(rx), 
      .RsTx(tx), 
      .uart_irq(Int_uart)
  );
AHBVGA Inst_AHBVGA(
      .HCLK(HCLK),
      .HRESETn(HRESETn),
      .HADDR(HADDR),
      .HWDATA(HWDATA),
      .HREADY(HREADY),
      .HWRITE(HWRITE),
      .HTRANS(HTRANS),
      .HSEL(HSEL_VGA),
      .HRDATA(HRDATA_VGA),
      .HREADYOUT(HREADYOUT_VGA),
      .hsync(hs),
      .vsync(vs),
      .rgb(rgb)
  );
endmodule
