/************************
******************************************************
*     Project:  Transilvania University of Brasov
*	Departament:  Electronics & Computers
*      Author:  Dan NICULA (DN)
*       Email:  dan.nicula@unitbv.ro
*   File name:  lcdSendByte.v
* Description:  Receives a request for a byte and issues requests for 2 nibbles.
*               Before the 2 data nibbles, a SET DD RAM Address is issued
* Date			     Author		Notes
* Dec. 3, 2007		DN		  initial version
* Jan 13, 2018		DN		  Code review
******************************************************************************/

//                lcdSendByte
//               +----------+
//    rq_i    -->|          |--> rq_o
//    ack_o   <--|          |<-- ack_i         
//               |          |               
//               |          |               
//               |          |--> rqRs_o
// ads_i[6:0] -->|          |--> rqRw_o        
// char_i[7:0]-->|          |--> rqData_o[3:0] 
//               |          |--> rqDel_o[17:0] 
//  clk_i     -->|          |
//  reset_i   -->|          |
//               |          |
//               +----------+

module lcdSendByte  (
input		            clk_i     ,
input		            reset_i   ,
output	reg         rq_o      ,
input		            ack_i     ,
output	            rqRs_o    ,
output	            rqRw_o    ,
output[3:0]	        rqData_o  ,
output[17:0]	      rqDel_o   ,
input		            powerUp_i ,
input		            rq_i      ,
output reg	        ack_o     ,
input[6:0]	        ads_i     ,
input[7:0]	        char_i    
);

localparam	noCmd_p = 4 ;

wire[(1+1+4+18)-1:0]  charCmd[noCmd_p:0];	// 23:0
wire[(1+1+4+18)-1:0]  crtCmd            ;

reg[2:0]	            crtIdx            ;

// Set DD RAM Address
assign charCmd[0] = {2'b00, 1'b1, ads_i[6:4], 18'd30};	
assign charCmd[1] = {2'b00, ads_i[3:0], 18'd2000};
// Write DD RAM
assign charCmd[2] = {2'b10, char_i[7:4], 18'd30};
assign charCmd[3] = {2'b10, char_i[3:0], 18'd2000};
// end
assign charCmd[4] = {2'b00, 4'b0, 18'd0};

always @(posedge clk_i or posedge reset_i)
if (reset_i)		        crtIdx <= 'b0; else
if (ack_i)		          crtIdx <= crtIdx + 1; else
if (crtIdx == noCmd_p)	crtIdx <= 'b0; 

assign crtCmd = charCmd[crtIdx];

assign rqRs_o   = crtCmd[23]    ;
assign rqRw_o   = crtCmd[22]    ;
assign rqData_o = crtCmd[21:18] ;
assign rqDel_o  = crtCmd[17:0]  ;

always @(posedge clk_i or posedge reset_i)
if (reset_i)			              rq_o <= 1'b0; else
if (ack_i) 			                rq_o <= 1'b0; else
if (~powerUp_i & rq_i & ~ack_o)	rq_o <= 1'b1;

always @(posedge clk_i or posedge reset_i)
if (reset_i)	  ack_o <= 1'b0; else
                ack_o <= ack_i & (crtIdx == (noCmd_p-1));

endmodule //lcdSendByte

