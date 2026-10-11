`timescale 1ns/1ps
module tb_brick_breaker;
 reg clk=0, rst=0, ps2_clk=1, ps2_dat=1;
 wire [7:0] r,g,b;
 wire hs,vs,pclk,blank,sync;
 brick_breaker dut(clk,rst,ps2_clk,ps2_dat,r,g,b,hs,vs,pclk,blank,sync);
 always #10 clk=~clk;
 task expect_state;
 input [1:0] expected;
 begin
  #1;
  if (dut.controller.state !== expected) begin
   $display("FAIL state: expected %0d got %0d",expected,dut.controller.state);
   $fatal(1);
  end
 end
 endtask
 // Drive a real PS/2 frame, LSB first, odd parity.
 task send_ps2;
 input [7:0] code;
 reg [10:0] bits;
 integer i;
 begin
  bits={1'b1,~(^code),code,1'b0};
  for(i=0;i<11;i=i+1) begin
   ps2_dat=bits[i]; #3000; ps2_clk=0; #3000; ps2_clk=1; #3000;
  end
  ps2_dat=1; #3000;
 end
 endtask
 initial begin
  #100; rst=1; expect_state(0);
  if (dut.datapath.bricks!==18'h3ffff) $fatal(1,"Reset bricks failed");
  send_ps2(8'h5A); // Enter make
  if (!dut.controller.start_latched) $fatal(1,"Enter key not latched");
  // Accelerate game-frame events without waiting for a full VGA frame.
  force dut.frame_tick=1'b1;
  @(posedge clk); #1;
  release dut.frame_tick;
  expect_state(1);
  if (dut.datapath.bricks!==18'h3ffff) $fatal(1,"Initialization failed");
  // Check paddle motion through keyboard decoding.
  send_ps2(8'h1C); // A make
  if (!dut.left_down) $fatal(1,"A make not decoded");
  force dut.frame_tick=1'b1;
  @(posedge clk); #1;
  release dut.frame_tick;
  if (dut.paddle_x!==272) $fatal(1,"Paddle did not move left");
  send_ps2(8'hF0); send_ps2(8'h1C);
  if (dut.left_down) $fatal(1,"A break not decoded");
  // Force all bricks cleared and check state transition.
  force dut.datapath.bricks=18'h0;
  force dut.frame_tick=1'b1;
  @(posedge clk); #1;
  release dut.frame_tick;
  expect_state(2);
  release dut.datapath.bricks;
  $display("PASS: reset, PS/2 start, game state, paddle motion, PS/2 release, win");
  $finish;
 end
 initial begin #5000000; $fatal(1,"Timeout"); end
endmodule
