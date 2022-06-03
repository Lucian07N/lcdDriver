

module regFile(

input        	  clk             , 
input        	  rst             , 
input        	  ack_lcd         , 
output reg  	  rq_lcd          , 
output reg  	  lcd_row         , 
output reg [5:0]  lcd_column      , 
output reg [7:0]  lcd_char          
);

reg  [3:0]	cnt;


//Modelare cnt
always @(posedge clk or posedge rst)
	if (rst) cnt <= 4'b0000; else
	if (ack_lcd)  cnt <= cnt + 1;  
	
//Modelare req_lcd
always @(posedge clk or posedge rst)
	if(rst) rq_lcd <= 1'b0; else
    if(ack_lcd) rq_lcd <= 1'b0; else 
	    rq_lcd <= 1'b1;
	
//Modelare lcd_row	
always @(posedge clk or posedge rst)
    if(rst)      lcd_row <= 1'b0; else 
		 lcd_row <= 1'b1;
	
//Modelare lcd_column	
always @(posedge clk or posedge rst)	
    if(rst) lcd_column <= 6'b00_0000;	else
		case(cnt)
		    4'b0001: lcd_column <= 6'b00_0001;
			4'b0010: lcd_column <= 6'b00_0010;
			4'b0011: lcd_column <= 6'b00_0011;
			4'b0100: lcd_column <= 6'b00_0100;
			4'b0101: lcd_column <= 6'b00_0101;
			4'b0110: lcd_column <= 6'b00_0110;
			default: lcd_column <= 6'b00_0000;
		endcase

//Modelare lcd_char			
always @(posedge clk or posedge rst)	
    if(rst) lcd_char <= 8'b0000_0000;	else	
	    case(lcd_column)
			6'b000001: lcd_char <= 8'b0100_1100;
			6'b000010: lcd_char <= 8'b0111_0101;
			6'b000011: lcd_char <= 8'b0110_0011;
			6'b000100: lcd_char <= 8'b0110_1001;
			6'b000101: lcd_char <= 8'b0110_0001;
			6'b000110: lcd_char <= 8'b0110_1110;
			default: lcd_char <= 8'b0010_0000;
		endcase
	
endmodule  