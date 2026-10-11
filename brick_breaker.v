// Independent Verilog-2001 educational reconstruction (not original coursework).
// 50 MHz input, 640x480 VGA timing at 25 MHz, PS/2 scan-code set 2.
// A / left arrow: move left; D / right arrow: move right; Space: start/restart.
// Requires board-specific pin assignments and hardware verification.
module brick_breaker(
    input wire CLOCK_50, RESET_N, PS2_CLK, PS2_DAT,
    output wire [7:0] VGA_R, VGA_G, VGA_B,
    output wire VGA_HS, VGA_VS, VGA_CLK, VGA_BLANK_N, VGA_SYNC_N
);
    wire [9:0] h, v;
    wire frame_tick;
    wire active_video;
    reg [7:0] pixel_r, pixel_g, pixel_b;
    vga_adapter display_adapter(
        .CLOCK_50(CLOCK_50), .RESET_N(RESET_N),
        .pixel_r(pixel_r), .pixel_g(pixel_g), .pixel_b(pixel_b),
        .pixel_x(h), .pixel_y(v), .frame_tick(frame_tick),
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_CLK(VGA_CLK),
        .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N)
    );

    wire [7:0] scan_code;
    wire scan_valid;
    ps2_receiver keyboard(CLOCK_50, RESET_N, PS2_CLK, PS2_DAT, scan_code, scan_valid);
    reg left_down, right_down, start_pending, break_prefix, extended_prefix;
    always @(posedge CLOCK_50 or negedge RESET_N) begin
        if (!RESET_N) begin
            left_down <= 0; right_down <= 0; start_pending <= 0;
            break_prefix <= 0; extended_prefix <= 0;
        end else begin
            if (frame_tick && start_pending) start_pending <= 0;
            if (scan_valid) begin
                if (scan_code == 8'hF0) break_prefix <= 1;
                else if (scan_code == 8'hE0) extended_prefix <= 1;
                else begin
                    if (scan_code == 8'h1C || (extended_prefix && scan_code == 8'h6B))
                        left_down <= !break_prefix;
                    if (scan_code == 8'h23 || (extended_prefix && scan_code == 8'h74))
                        right_down <= !break_prefix;
                    if (scan_code == 8'h29 && !break_prefix) start_pending <= 1;
                    break_prefix <= 0;
                    extended_prefix <= 0;
                end
            end
        end
    end

    localparam [1:0] READY=2'd0, PLAYING=2'd1, WON=2'd2, LOST=2'd3;
    localparam integer PADDLE_W=84, PADDLE_Y=445, BALL_S=8;
    localparam integer BRICK_X=56, BRICK_Y=58, BRICK_W=88, BRICK_H=22, BRICK_GAP=8;
    reg [1:0] state;
    reg [9:0] paddle_x, ball_x;
    reg [8:0] ball_y;
    reg signed [3:0] dx, dy;
    reg [17:0] bricks;
    integer nx, ny, px, r, c, idx;
    reg [17:0] next_bricks;
    reg hit_brick;
    always @(posedge CLOCK_50 or negedge RESET_N) begin
        if (!RESET_N) begin
            state <= READY; paddle_x <= 278; ball_x <= 316; ball_y <= 420;
            dx <= 2; dy <= -2; bricks <= 18'h3ffff;
        end else if (frame_tick) begin
            if (start_pending && state != PLAYING) begin
                state <= PLAYING; paddle_x <= 278; ball_x <= 316; ball_y <= 420;
                dx <= 2; dy <= -2; bricks <= 18'h3ffff;
            end else if (state == PLAYING) begin
                px = paddle_x;
                if (left_down && !right_down) px = px - 6;
                else if (right_down && !left_down) px = px + 6;
                if (px < 0) px = 0;
                if (px > 640-PADDLE_W) px = 640-PADDLE_W;
                paddle_x <= px;
                nx = ball_x + dx;
                ny = ball_y + dy;
                if (nx < 0 || nx > 640-BALL_S) begin
                    dx <= -dx;
                    nx = (nx < 0) ? 0 : 640-BALL_S;
                end
                if (ny < 0) begin dy <= -dy; ny = 0; end
                if (dy > 0 && ny+BALL_S >= PADDLE_Y && ball_y+BALL_S <= PADDLE_Y &&
                    nx+BALL_S > px && nx < px+PADDLE_W) begin
                    dy <= -dy; ny = PADDLE_Y-BALL_S;
                end
                next_bricks = bricks;
                hit_brick = 0;
                for (r=0; r<3; r=r+1) begin
                    for (c=0; c<6; c=c+1) begin
                        idx = r*6+c;
                        if (!hit_brick && bricks[idx] &&
                            nx+BALL_S/2 >= BRICK_X+c*(BRICK_W+BRICK_GAP) &&
                            nx+BALL_S/2 < BRICK_X+c*(BRICK_W+BRICK_GAP)+BRICK_W &&
                            ny+BALL_S/2 >= BRICK_Y+r*(BRICK_H+BRICK_GAP) &&
                            ny+BALL_S/2 < BRICK_Y+r*(BRICK_H+BRICK_GAP)+BRICK_H) begin
                            next_bricks[idx] = 0;
                            hit_brick = 1;
                        end
                    end
                end
                bricks <= next_bricks;
                if (hit_brick) dy <= -dy;
                ball_x <= nx; ball_y <= ny;
                if (ny > 479) state <= LOST;
                else if (next_bricks == 0) state <= WON;
            end
        end
    end

    reg paddle_pixel, ball_pixel, brick_pixel;
    integer pr, pc;
    always @* begin
        paddle_pixel = (h >= paddle_x && h < paddle_x+PADDLE_W &&
                        v >= PADDLE_Y && v < PADDLE_Y+12);
        ball_pixel = (h >= ball_x && h < ball_x+BALL_S &&
                      v >= ball_y && v < ball_y+BALL_S);
        brick_pixel = 0;
        for (pr=0; pr<3; pr=pr+1)
            for (pc=0; pc<6; pc=pc+1)
                if (bricks[pr*6+pc] &&
                    h >= BRICK_X+pc*(BRICK_W+BRICK_GAP) &&
                    h < BRICK_X+pc*(BRICK_W+BRICK_GAP)+BRICK_W &&
                    v >= BRICK_Y+pr*(BRICK_H+BRICK_GAP) &&
                    v < BRICK_Y+pr*(BRICK_H+BRICK_GAP)+BRICK_H)
                    brick_pixel = 1;
        pixel_r = 0; pixel_g = 0; pixel_b = 0;
        if (VGA_BLANK_N) begin
            pixel_r = 8'h12; pixel_g = 8'h13; pixel_b = 8'h25;
            if (brick_pixel) begin VGA_R=8'hE0; VGA_G=8'h75; VGA_B=8'h86; end
            if (paddle_pixel) begin VGA_R=8'h65; VGA_G=8'hDD; VGA_B=8'hCB; end
            if (ball_pixel) begin VGA_R=8'hFF; VGA_G=8'hFF; VGA_B=8'hFF; end
            if (state == WON) begin VGA_R=8'h13; VGA_G=8'h75; VGA_B=8'h52; end
            if (state == LOST) begin VGA_R=8'h80; VGA_G=8'h20; VGA_B=8'h38; end
        end
    end
endmodule

module ps2_receiver(
    input wire clk, reset_n, ps2_clk, ps2_dat,
    output reg [7:0] data,
    output reg valid
);
    reg [2:0] clk_sync, dat_sync;
    reg [3:0] count;
    reg [10:0] shift;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_sync <= 3'b111; dat_sync <= 3'b111; count <= 0;
            shift <= 0; data <= 0; valid <= 0;
        end else begin
            clk_sync <= {clk_sync[1:0], ps2_clk};
            dat_sync <= {dat_sync[1:0], ps2_dat};
            valid <= 0;
            if (clk_sync[2:1] == 2'b10) begin
                shift[count] <= dat_sync[2];
                if (count == 10) begin
                    count <= 0;
                    if (shift[0] == 0 && dat_sync[2] == 1 && (^shift[9:1]) == 1'b1) begin
                        data <= shift[8:1];
                        valid <= 1;
                    end
                end else count <= count + 1'b1;
            end
        end
    end
endmodule
