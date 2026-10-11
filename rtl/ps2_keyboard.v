module ps2_keyboard(input wire clk, reset_n, ps2_clk, ps2_dat,
 output reg left_down, right_down, output reg start_event);
 wire [7:0] code;
 wire valid;
 ps2_receiver rx(clk,reset_n,ps2_clk,ps2_dat,code,valid);
 reg break_code, extended;
 always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
   left_down<=0; right_down<=0; start_event<=0; break_code<=0; extended<=0;
  end else begin
   start_event<=0;
   if (valid) begin
    if (code==8'hE0) extended<=1;
    else if (code==8'hF0) break_code<=1;
    else begin
     if (code==8'h1C || (extended && code==8'h6B)) left_down<=!break_code;
     if (code==8'h23 || (extended && code==8'h74)) right_down<=!break_code;
     if (code==8'h29 && !break_code) start_event<=1;
     break_code<=0; extended<=0;
    end
   end
  end
 end
endmodule

module ps2_receiver(input wire clk, reset_n, ps2_clk, ps2_dat,
 output reg [7:0] code, output reg valid);
 reg [2:0] cs, ds;
 reg [3:0] count;
 reg [10:0] bits_in;
 always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
   cs<=3'b111; ds<=3'b111; count<=0; bits_in<=0; code<=0; valid<=0;
  end else begin
   cs<={cs[1:0],ps2_clk}; ds<={ds[1:0],ps2_dat}; valid<=0;
   if (cs[2:1]==2'b10) begin
    bits_in[count]<=ds[2];
    if (count==10) begin
     count<=0;
     // 0 start, 8 data, odd parity, 1 stop.
     if (!bits_in[0] && ds[2] && (^bits_in[9:1])) begin
      code<=bits_in[8:1]; valid<=1;
     end
    end else count<=count+1'b1;
   end
  end
 end
endmodule
