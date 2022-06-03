/******************************************************************************
*     Project:  Transilvania University of Brasov
*	Departament:  Electronics & Computers
*      Author:  Dan NICULA (DN)
*       Email:  dan.nicula@unitbv.ro
*   File name:  lcdSendNibble.v
* Description:  Request a command and send one nibble on 4 wires.
* Date			     Author		Notes
* Dec. 3, 2007		DN		  initial version
* Jan 13, 2018		DN		  Code review
******************************************************************************/
//                          lcdSendNibble
//                         +----------+
//   rq_i               -->|          |
//   ack_o              <--|          |--> lcdE_o    
//                         |          |--> lcdRs_o   
//                         |          |--> lcdRw_o 
//   rqRs_i             -->|          |
//   rqRw_i             -->|          |--> lcdData_o[3:0] 
//   rqData_i[3:0]      -->|          |
//   rqDel_i[17:0]      -->|          |
//              clk_i   -->|          |
//              reset_i -->|          |
//                         |          |
//                         +----------+

module lcdSendNibble(
input		            clk_i       ,
input		            reset_i     ,
input		            rq_i        ,
output reg		      ack_o       ,
input		            rqRs_i      ,
input		            rqRw_i      ,
input[3:0]	        rqData_i    ,
input[17:0]	        rqDel_i     ,
output reg 	        lcdE_o      ,
output reg	        lcdRs_o     ,
output reg		      lcdRw_o     ,
output	reg  [3:0]   lcdData_o
);

reg[14:0]	    shReg       ;
reg		        reR         ;
reg		        startBreak  ;
reg[17:0]	    countBreak  ;

//              11111
//    012345678901234
//E  ___|----------|__
//RS _|-------------|_
//RW _|-------------|_

always @(posedge clk_i or posedge reset_i)
if (reset_i)	    reR <= 1'b0; else
                  reR <= rq_i;
always @(posedge clk_i or posedge reset_i)
if (reset_i)	    shReg <= 'b0; else
if (rq_i & ~reR)  shReg <= 'b1; else		// _|- rq_i
                  shReg <= (shReg << 1);
always @(posedge clk_i or posedge reset_i)
if (reset_i)	    startBreak <= 1'b0; else
                  startBreak <= shReg[14];
always @(posedge clk_i or posedge reset_i)
if (reset_i)	    lcdE_o <= 1'b0; else
                  lcdE_o <=(|shReg[13:2]);
always @(posedge clk_i or posedge reset_i)
if (reset_i)	    lcdRs_o <= 1'b0; else
                  lcdRs_o <=(|shReg[14:0]) & rqRs_i;
always @(posedge clk_i or posedge reset_i)
if (reset_i)	    lcdRw_o <= 1'b0; else
                  lcdRw_o <=(|shReg[14:0]) & rqRw_i;
always @(posedge clk_i or posedge reset_i)
if (reset_i)		  lcdData_o <= 4'b0; else
if (|shReg[14:0])	lcdData_o <= rqData_i; else
                  lcdData_o <= 4'b0; 

always @(posedge clk_i or posedge reset_i)
if (reset_i)		  countBreak <= 'd0; else
if (startBreak)		countBreak <= rqDel_i; else
if (|countBreak)  countBreak <= countBreak - 1;

always @(posedge clk_i or posedge reset_i)
if (reset_i)		  ack_o <= 1'b0; else
                  ack_o <= (countBreak == 'd1);

endmodule // lcdSendNibble
