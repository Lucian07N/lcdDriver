

//                          lcdDriver
//                         +----------+
//                  rq  -->|          |
//                  ack <--|          |--> lcd_e    
//                         |          |--> lcd_rs   
//                         |          |--> lcd_rw_n 
//   lcd_row            -->|          |--> db[3:0] 
//   lcd_column[5:0]    -->|          |
//   lcd_character[7:0] -->|          |
//               clk    -->|          |
//               rst    -->|          |
//                         |          |
//                         +----------+


module lcdDriver(
input		    clk               ,   // clock input, 50MHz
input		    rst           ,   // asynchronous reset active high
// client interface 
input		    rq                ,
output		  ack               ,
input		    lcd_row           ,
input[5:0]	lcd_column        ,
input[7:0]	lcd_character     ,
// LCD interface  
output		  lcd_e             ,
output		  lcd_rs            ,
output		  lcd_rw_n          ,
output[3:0]	db  
);	

wire		      rqPwup          ;
wire		      ackNibble       ;
wire		      rqByte          ;
wire		      rqRsByte        ;
wire		      rqRwByte       ;
wire[3:0]	    rqDataByte      ;
wire[17:0]	  rqDelByte       ;
wire		      rqRsPwr         ;
wire		      rqRwPwr	        ;
wire[3:0]	    rqDataPwr       ;
wire[17:0]	  rqDelPwr        ;
wire		      powerUp         ;
wire          ack_send_byte   ;
wire          ack_power_up    ;
wire          rq_send_nibble  ;
wire 		      rqRs	          ;
wire 		      rqRw	          ;
wire [3:0]	  rqData          ;
wire [17:0]   rqDel           ;


assign  ack_send_byte   =  ~powerUp & ackNibble             ;
assign  ack_power_up    =   powerUp & ackNibble             ;
assign  rq_send_nibble  =   powerUp ? rqPwup    : rqByte    ;
  
assign  rqRs		        =   powerUp ? rqRsPwr   : rqRsByte  ;
assign  rqRw		        =   powerUp ? rqRwPwr   : rqRwByte  ;
assign  rqData	        =   powerUp ? rqDataPwr : rqDataByte;
assign  rqDel 	        =   powerUp ? rqDelPwr  : rqDelByte ;

lcdSendByte UlcdSendByte(
	.clk_i		(clk		                ),
	.reset_i	(rst	                    ),
	.rq_o		(rqByte	                    ),
	.ack_i		(ack_send_byte              ),
	.rqRs_o		(rqRsByte	                ),
	.rqRw_o		(rqRwByte	                ),
	.rqData_o	(rqDataByte	                ),
	.rqDel_o	(rqDelByte	                ),
	.powerUp_i  (powerUp	                    ),
	// client
	.rq_i		  (rq		                  ),
	.ack_o		(ack		                ),
	.ads_i		({lcd_row, lcd_column}  ),
	.char_i		(lcd_character	        )
);

lcdPowerUp UlcdPowerUp(
	.clk_i		(clk		                ),
	.reset_i	(rst	                  ),
	.rq_o       (rqPwup	                ),
	.ack_i		(ack_power_up           ),
	.rqRs_o		(rqRsPwr	              ),
	.rqRw_o		(rqRwPwr	              ),
	.rqData_o	(rqDataPwr	            ),
	.rqDel_o	(rqDelPwr	              ), 
	.powerUp_o(powerUp	              )
);	

lcdSendNibble	UlcdSendNibble(
	.clk_i		(clk		                ),
	.reset_i	(rst	                  ),
	.rq_i		  (rq_send_nibble         ),
	.ack_o		(ackNibble	            ),	
	.rqRs_i		(rqRs	                  ),
	.rqRw_i		(rqRw	                  ),
	.rqData_i	(rqData                 ),
	.rqDel_i	(rqDel                  ),
	.lcdE_o		(lcd_e		              ),
	.lcdRs_o	(lcd_rs	                ),
	.lcdRw_o	(lcd_rw_n	              ),
	.lcdData_o(db	                    )
);			

endmodule // lcdDriver
