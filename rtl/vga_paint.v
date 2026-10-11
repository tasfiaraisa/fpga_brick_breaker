module vga_paint(input wire [9:0] x,y, input wire active,
 input wire [1:0] state, input wire [9:0] ball_x,
 input wire [8:0] ball_y, input wire [9:0] paddle_x,
 input wire [17:0] bricks,
 output reg [7:0] red,green,blue);
 localparam READY=2'd0, PLAYING=2'd1, WON=2'd2, LOST=2'd3;
 localparam integer BX=56,BY=58,BW=88,BH=22,GAP=8;
 wire [12:0] rom_address=(y[9:3]*13'd80)+x[9:3];
 wire splash_pixel;
 start_screen_rom splash(rom_address,splash_pixel);
 reg brick_pixel;
 integer r,c;
 wire paddle_pixel=(x>=paddle_x && x<paddle_x+84 && y>=445 && y<457);
 wire ball_pixel=(x>=ball_x && x<ball_x+8 && y>=ball_y && y<ball_y+8);
 always @* begin
  brick_pixel=0;
  for (r=0;r<3;r=r+1)
   for (c=0;c<6;c=c+1)
    if (bricks[r*6+c] && x>=BX+c*(BW+GAP) && x<BX+c*(BW+GAP)+BW &&
        y>=BY+r*(BH+GAP) && y<BY+r*(BH+GAP)+BH) brick_pixel=1;
  red=0;green=0;blue=0;
  if (active) begin
   red=8'h12;green=8'h13;blue=8'h25;
   if (state==READY) begin
    if (splash_pixel) begin red=8'hff;green=8'hd0;blue=8'h9c;end
   end else if (state==WON) begin
    red=8'h13;green=8'h75;blue=8'h52;
   end else if (state==LOST) begin
    red=8'h80;green=8'h20;blue=8'h38;
   end else begin
    if (brick_pixel) begin red=8'he0;green=8'h75;blue=8'h86;end
    if (paddle_pixel) begin red=8'h65;green=8'hdd;blue=8'hcb;end
    if (ball_pixel) begin red=8'hff;green=8'hff;blue=8'hff;end
   end
  end
 end
endmodule
