// 160x120, 3-bit palette-index ROM scaled 4x to VGA 640x480.
// Generated from the original Brick Breaker title-screen screenshot.
module start_screen_rom(input wire [14:0] address, output wire [2:0] pixel);
 reg [2:0] mem [0:19199];
 initial $readmemh("start_screen.mem", mem);
 assign pixel=(address<19200) ? mem[address] : 3'd0;
endmodule
