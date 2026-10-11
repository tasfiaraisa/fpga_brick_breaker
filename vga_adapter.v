// Verilog-2001 VGA timing adapter for 640x480 @ ~60 Hz.
// 50 MHz board clock divided by two to generate a 25 MHz pixel clock.
// RGB inputs are provided by the game renderer at pixel_x/pixel_y.
// This is a scanout adapter, not a framebuffer or the course-provided vga_adapter.
module vga_adapter(
    input wire CLOCK_50,
    input wire RESET_N,
    input wire [7:0] pixel_r, pixel_g, pixel_b,
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y,
    output wire frame_tick,
    output wire [7:0] VGA_R, VGA_G, VGA_B,
    output wire VGA_HS, VGA_VS, VGA_CLK, VGA_BLANK_N, VGA_SYNC_N
);
    reg pixel_phase;
    reg [9:0] h_count, v_count;

    always @(posedge CLOCK_50 or negedge RESET_N) begin
        if (!RESET_N) begin
            pixel_phase <= 1'b0;
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            pixel_phase <= ~pixel_phase;
            if (pixel_phase) begin
                if (h_count == 10'd799) begin
                    h_count <= 10'd0;
                    if (v_count == 10'd524)
                        v_count <= 10'd0;
                    else
                        v_count <= v_count + 1'b1;
                end else begin
                    h_count <= h_count + 1'b1;
                end
            end
        end
    end

    assign pixel_x = h_count;
    assign pixel_y = v_count;
    assign frame_tick = pixel_phase && (h_count == 10'd799) && (v_count == 10'd524);
    assign VGA_CLK = pixel_phase;
    assign VGA_HS = ~((h_count >= 10'd656) && (h_count < 10'd752));
    assign VGA_VS = ~((v_count >= 10'd490) && (v_count < 10'd492));
    assign VGA_BLANK_N = (h_count < 10'd640) && (v_count < 10'd480);
    assign VGA_SYNC_N = 1'b0;
    assign VGA_R = VGA_BLANK_N ? pixel_r : 8'd0;
    assign VGA_G = VGA_BLANK_N ? pixel_g : 8'd0;
    assign VGA_B = VGA_BLANK_N ? pixel_b : 8'd0;
endmodule
