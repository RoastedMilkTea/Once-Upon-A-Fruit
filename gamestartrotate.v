//this file is to rotate the word "finish" on the hex displays in the game end 
//screen. The word "finish" will rotate on the hex displays until the user exits


module gamestartrotate(
    input [0:0] KEY,
    input CLOCK_50,
    output [6:0] HEX5,
    output [6:0] HEX4,
    output [6:0] HEX3,
    output [6:0] HEX2,
    output [6:0] HEX1,
    output [6:0] HEX0
);
    // 50,000,000 in binary is 26 bits
    reg [25:0] clock_counter;
    reg [25:0] slow_counter; // a counter for slow enable
    reg [2:0] digit_count; // changed to 3 bits to count from 0 to 5
    reg [3:0] shift_reg [5:0];
    
    wire enable;
    wire slow_enable;
    
    assign enable = (clock_counter == 26'd49999999); // largest decimal num
    assign slow_enable = (slow_counter == 26'd49999999); // slow enable signal
    
    // clock counter
    always @(posedge CLOCK_50 or negedge KEY[0])
    begin
        if (!KEY[0])
            clock_counter <= 26'd0; // set to 0
        else if (enable)
            clock_counter <= 26'd0; // also set to 0 
        else
            clock_counter <= clock_counter + 1'd1; // count up
    end
    
    // slow counter
    always @(posedge CLOCK_50 or negedge KEY[0])
    begin
        if (!KEY[0])
            slow_counter <= 26'd0; // set to 0
        else if (slow_enable)
            slow_counter <= 26'd0; // also set to 0 
        else
            slow_counter <= slow_counter + 1'd1; // count up
    end
    
    // display counter and shift register
    always @(posedge CLOCK_50 or negedge KEY[0])
    begin
        if (!KEY[0]) begin
            digit_count <= 3'd0; // set display to 0 
            shift_reg[0] <= 4'd5; // start with blank
            shift_reg[1] <= 4'd2; // N
            shift_reg[2] <= 4'd1; // I
            shift_reg[3] <= 4'd4; // G
            shift_reg[4] <= 4'd3; // E
            shift_reg[5] <= 4'd0; // B
        end else if (slow_enable) begin
            if (digit_count == 3'd5)
            digit_count <= 3'd0; // count back to 0 from 5
            else
            digit_count <= digit_count + 1'd1; // count up
            
            // rotating the shift register
            shift_reg[5] <= shift_reg[4];
            shift_reg[4] <= shift_reg[3];
            shift_reg[3] <= shift_reg[2];
            shift_reg[2] <= shift_reg[1];
            shift_reg[1] <= shift_reg[0];
            shift_reg[0] <= shift_reg[5];
        end
    end
    
    seven_segmentstartphase decoder0(.in(shift_reg[0]), .hex(HEX0));
    seven_segmentstartphase decoder1(.in(shift_reg[1]), .hex(HEX1));
    seven_segmentstartphase decoder2(.in(shift_reg[2]), .hex(HEX2));
    seven_segmentstartphase decoder3(.in(shift_reg[3]), .hex(HEX3));
    seven_segmentstartphase decoder4(.in(shift_reg[4]), .hex(HEX4));
    seven_segmentstartphase decoder5(.in(shift_reg[5]), .hex(HEX5));
    
endmodule

module seven_segmentstartphase(
   input [3:0] in,
   output reg [6:0] hex
);
   always @(*) begin
       case(in)
           4'd0: hex = 7'b0000011;  // B
           4'd1: hex = 7'b1111001;  // I
           4'd2: hex = 7'b1001000; // N
           4'd3: hex = 7'b0000110; // E
           4'd4: hex = 7'b0010000; //G
			  4'd5: hex = 7'b1111111; //blank
       endcase
   end
endmodule