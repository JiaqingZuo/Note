`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/06/16 17:18:35
// Design Name: 
// Module Name: test
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


module test;
reg HCLK;
reg HRESETn;
wire [7:0] LED;
reg btn;
AHBLITE_SYS Inst_AHBLITE(
       .HCLK(HCLK),
       .HRESETn(HRESETn), 
       .LED(LED),
       .btn(btn)
    );
initial  
begin
  HCLK=0;
  HRESETn=0;
  btn=0;
  #100;
  HRESETn=1;
end
always 
begin
 HCLK=~HCLK;
 #20;
end 
endmodule
