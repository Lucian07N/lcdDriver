
//                     ipu_etapa5
//                  +----------+
//                  |          |--> vSync_o
//                  |          |--> hSync_o
//                  |          |
//                  |          |--> red_o
//                  |          |--> green_o
//                  |          |--> blue_o
//                  |          |
// clk_i         -->|          |
// reset_i       -->|          |
//                  +----------+

module ipu_etapa5(
input	clk     ,	// clock input, 50MHz
input	reset   ,	// reset active high
input   switch1  ,	// switch-ul care realizeaza comutarea imaginilor
input   switch2  ,	// switch-ul care realizeaza comutarea cu imaginea complementata
output  [3:0]   db      ,
output          lcd_e   ,   
output			lcd_rs  ,   
output 			lcd_rw_n    
);

wire [2:0]   imgProc_out;
wire          rq;
wire          ack;
wire 		  lcd_row;
wire [6:0]    lcd_column;
wire [7:0]    lcd_char;



lcdDriver lcdDrv(
.clk          (clk             ), 
.rst          (reset           ), 
.rq           (rq              ), 
.ack          (ack             ), 
.lcd_row      (lcd_row         ), 
.lcd_column   (lcd_column      ), 
.lcd_character(lcd_char        ), 
.lcd_e        (lcd_e           ),     
.lcd_rs       (lcd_rs		   ), 
.lcd_rw_n     (lcd_rw_n		   ), 
.db           (db			   )  
);

regFile regF(
.clk          (clk             ), 
.rst          (reset           ), 
.ack_lcd      (ack             ), 
.rq_lcd       (rq              ), 
.lcd_row      (lcd_row         ), 
.lcd_column   (lcd_column      ), 
.lcd_char     (lcd_char        )  
);

endmodule   