/******************************************************************************
*     Project:  Transilvania University of Brasov
*	Departament:  Electronics & Computers
*      Author:  Dan NICULA (DN)
*       Email:  dan.nicula@unitbv.ro
*   File name:  lcdPowerUp.v
* Description:  Power-up sequencer
* Date			     Author		Notes
* Dec. 3, 2007		DN		  initial version
* Jan 13, 2018		DN		  Code review
******************************************************************************/

//              lcdPowerUp
//             +----------+
//             |          |--> rq_o
//             |          |<-- ack_i         
//             |          |               
//             |          |               
//             |          |--> rqRs_o
//             |          |--> rqRw_o        
//             |          |--> rqData_o[3:0] 
//             |          |--> rqDel_o[17:0] 
//  clk_i   -->|          |
//  reset_i -->|          |--> powerUp_o
//             |          |
//             +----------+

module lcdPowerUp(
input		      clk_i       ,
input		      reset_i     ,
output reg		rq_o        ,
input		      ack_i       ,
output		    rqRs_o      ,
output		    rqRw_o      ,
output[3:0]	  rqData_o    ,
output[17:0]	rqDel_o     ,
output reg		powerUp_o   
);

localparam	noCmd_p       = 12        ;
localparam	noPwrUpCnt_p  = 4_150_000 ; // initial delay 83ms / 20ns

reg[23:0]	            powerUpCnt          ; 
reg		                workProgress        ;
reg[3:0]	            crtIdx              ;

wire[(1+1+4+18)-1:0] powerUpCmd[noCmd_p:0];
wire[(1+1+4+18)-1:0] crtCmd               ;

// Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles.
// Wait 4.1 ms or longer, which is 205,000 clock cycles at 50 MHz.
assign powerUpCmd[0] = {2'b00, 4'b0011, 18'd205000};	
// Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles.
// Wait 100 us or longer, which is 5,000 clock cycles at 50 MHz.
assign powerUpCmd[1] = {2'b00, 4'b0011, 18'd5000};
// Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles.
// Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
assign powerUpCmd[2] = {2'b00, 4'b0011, 18'd2000};
// Write SF_D<11:8> = 0x2, pulse LCD_E High for 12 clock cycles.
// Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
assign powerUpCmd[3] = {2'b00, 4'b0010, 18'd2000};

// Issue a Function Set command, 0x28, to configure the display for operation on the
// Spartan-3E Starter Kit board.
assign powerUpCmd[4] = {2'b00, 4'b0010, 18'd50};
assign powerUpCmd[5] = {2'b00, 4'b1000, 18'd2000};
// Issue an Entry Mode Set command, 0x06, to set the display to automatically
// increment the address pointer.
assign powerUpCmd[6] = {2'b00, 4'b0000, 18'd50};
assign powerUpCmd[7] = {2'b00, 4'b0110, 18'd2000};
// Issue a Display On/Off command, 0x0C, to turn the display on and disables the
// cursor and blinking.
assign powerUpCmd[8] = {2'b00, 4'b0000, 18'd50};
assign powerUpCmd[9] = {2'b00, 4'b1100, 18'd2000};
// Finally, issue a Clear Display command. Allow at least 1.64 ms (82,000 clock cycles)
// after issuing this command.
assign powerUpCmd[10] = {2'b00, 4'b0000, 18'd50};
assign powerUpCmd[11] = {2'b00, 4'b0001, 18'd82000};
// end
assign powerUpCmd[12] = {2'b00, 4'b0000, 18'd0};

always @(posedge clk_i or posedge reset_i)
if (reset_i)	crtIdx <= 'b0; else
if (ack_i)	  crtIdx <= crtIdx + 1;

assign crtCmd = powerUpCmd[crtIdx];

assign rqRs_o   = crtCmd[23]    ;
assign rqRw_o   = crtCmd[22]    ;
assign rqData_o = crtCmd[21:18] ;
assign rqDel_o  = crtCmd[17:0]  ;

always @(posedge clk_i or posedge reset_i)
if (reset_i)			                    rq_o <= 1'b0; else
if (ack_i) 				                    rq_o <= 1'b0; else
if ((crtIdx<noCmd_p) & workProgress)	rq_o <= 1'b1;


always @(posedge clk_i or posedge reset_i)
if (reset_i)				                  powerUp_o <= 1'b1; else
if (ack_i & (crtIdx == (noCmd_p-1)))	powerUp_o <= 1'b0;

always @(posedge clk_i or posedge reset_i)
if (reset_i)		powerUpCnt <= noPwrUpCnt_p; else
                powerUpCnt <= powerUpCnt - 1;
                
always @(posedge clk_i or posedge reset_i)
if (reset_i)		        workProgress <= 1'b0; else
if (powerUpCnt == 'b0)	workProgress <= 1'b1;

endmodule // lcdPowerUp
