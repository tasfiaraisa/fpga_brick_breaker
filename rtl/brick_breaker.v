// Top-level: DE1-SoC 50 MHz clock, active-low reset, PS/2, 640x480 VGA.
module brick_breaker(
 input wire CLOCK_50, RESET_N, PS2_CLK, PS2_DAT,
 output wire [7:0] VGA_R, VGA_G, VGA_B,
 output wire VGA_HS, VGA_VS, VGA_CLK, VGA_BLANK_N, VGA_SYNC_N
);
 wire [9:0] x, y;
 wire frame_tick, active;
 vga_timing timing(CLOCK_50, RESET_N, x, y, frame_tick, active,
                   VGA_HS, VGA_VS, VGA_CLK, VGA_BLANK_N, VGA_SYNC_N);
 wire left_down, right_down, start_event;
 ps2_keyboard keyboard(CLOCK_50, RESET_N, PS2_CLK, PS2_DAT,
                       left_down, right_down, start_event);
 wire [1:0] state;
 wire init_game, step_game;
 wire won, lost;
 game_logic controller(CLOCK_50, RESET_N, frame_tick, start_event, won, lost,
                       state, init_game, step_game);
 wire [9:0] ball_x, paddle_x;
 wire [8:0] ball_y;
 wire [17:0] bricks;
 game_datapath datapath(CLOCK_50, RESET_N, init_game, step_game,
                       left_down, right_down, ball_x, ball_y, paddle_x, bricks, won, lost);
 vga_paint renderer(x, y, active, state, ball_x, ball_y, paddle_x, bricks,
                    VGA_R, VGA_G, VGA_B);
endmodule
