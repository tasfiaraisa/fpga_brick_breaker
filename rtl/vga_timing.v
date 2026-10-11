// 25 MHz pixel enable derived from CLOCK_50; VGA 640x480 @ ~59.5 Hz.
module vga_timing(input wire clk, reset_n,
 output reg [9:0] x, y, output wire frame_tick, active,
 output wire hs, vs, pixel_clk, blank_n, sync_n);
 reg phase;
 always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin phase<=0; x<=0; y<=0; end
  else begin
   phase<=~phase;
   if (phase) begin
    if (x==799) begin x<=0; y <= (y==524) ? 0 : y+1'b1; end
    else x<=x+1'b1;
   end
  end
 end
 assign pixel_clk=phase;
 assign hs=~((x>=656)&&(x<752));
 assign vs=~((y>=490)&&(y<492));
 assign active=(x<640)&&(y<480);
 assign blank_n=active;
 assign sync_n=1'b0;
 assign frame_tick=phase && x==799 && y==524;
endmodule
