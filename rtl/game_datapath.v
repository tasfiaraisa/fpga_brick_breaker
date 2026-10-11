module game_datapath(input wire clk, reset_n, init_game, step_game,
 input wire left_down, right_down,
 output reg [9:0] ball_x, output reg [8:0] ball_y,
 output reg [9:0] paddle_x, output reg [17:0] bricks,
 output wire won, lost);
 localparam integer PW=84, PY=445, BS=8;
 localparam integer BX=56, BY=58, BW=88, BH=22, GAP=8;
 reg signed [3:0] dx,dy;
 integer px,nx,ny,r,c,idx;
 reg [17:0] next_bricks;
 reg hit;
 reg next_lost, next_won;
 reg bounce_x, bounce_y;
 // Collision evaluation is combinational datapath logic.
 always @* begin
  px=paddle_x;
  if (left_down && !right_down) px=px-6;
  else if (right_down && !left_down) px=px+6;
  if (px<0) px=0;
  if (px>640-PW) px=640-PW;
  nx=ball_x+dx; ny=ball_y+dy;
  bounce_x=(nx<0 || nx>640-BS);
  bounce_y=(ny<0);
  if (nx<0) nx=0;
  else if (nx>640-BS) nx=640-BS;
  if (ny<0) ny=0;
  if (dy>0 && ny+BS>=PY && ball_y+BS<=PY && nx+BS>px && nx<px+PW) begin
   ny=PY-BS; bounce_y=1;
  end
  next_bricks=bricks;
  hit=0;
  for (r=0;r<3;r=r+1)
   for (c=0;c<6;c=c+1) begin
    idx=r*6+c;
    if (!hit && bricks[idx] &&
        nx+BS/2>=BX+c*(BW+GAP) && nx+BS/2<BX+c*(BW+GAP)+BW &&
        ny+BS/2>=BY+r*(BH+GAP) && ny+BS/2<BY+r*(BH+GAP)+BH) begin
     next_bricks[idx]=0; hit=1;
    end
   end
  if (hit) bounce_y=1;
  next_lost=(ny>479);
  next_won=(next_bricks==0);
 end
 assign lost=step_game && next_lost;
 assign won=step_game && next_won;
 always @(posedge clk or negedge reset_n) begin
  if (!reset_n || init_game) begin
   paddle_x<=278; ball_x<=316; ball_y<=420;
   dx<=2; dy<=-2; bricks<=18'h3ffff;
  end else if (step_game) begin
   paddle_x<=px; ball_x<=nx; ball_y<=ny; bricks<=next_bricks;
   if (bounce_x) dx<=-dx;
   if (bounce_y) dy<=-dy;
  end
 end
endmodule
