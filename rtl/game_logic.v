// State machine: READY -> PLAYING -> WON/LOST; space restarts.
module game_logic(input wire clk, reset_n, frame_tick, start_event, won, lost,
 output reg [1:0] state, output wire init_game, step_game);
 localparam READY=2'd0, PLAYING=2'd1, WON=2'd2, LOST=2'd3;
 reg start_latched;
 always @(posedge clk or negedge reset_n) begin
  if (!reset_n) start_latched<=0;
  else if (start_event) start_latched<=1;
  else if (frame_tick) start_latched<=0;
 end
 assign init_game=frame_tick && state!=PLAYING && (start_latched || start_event);
 assign step_game=frame_tick && state==PLAYING;
 always @(posedge clk or negedge reset_n) begin
  if (!reset_n) state<=READY;
  else if (init_game) state<=PLAYING;
  else if (step_game) begin
   if (lost) state<=LOST;
   else if (won) state<=WON;
  end
 end
endmodule
