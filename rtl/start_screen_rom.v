// 80x60 monochrome image, magnified 8x to cover 640x480.
// Inferred ROM initialized from start_screen.mem (4800 bytes, one bit/line).
module start_screen_rom(input wire [12:0] address, output wire pixel);
 reg [0:0] mem [0:4799];
 initial $readmemb("start_screen.mem",mem);
 assign pixel=(address<4800) ? mem[address] : 1'b0;
endmodule
