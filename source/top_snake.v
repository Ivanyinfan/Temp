//����ģ��
module top_snake
(
	input CLK,
	input RSTn,
	
	input left,
	input right,
	input up,
	input down,

	output hsync,
	output vsync,
	output clk_25M,
	output [2:0]color_out,
	output [6:0]seg_out,
	output [3:0]sel
	
);

/***************************************************************************/
	wire left_key_press,right_key_press,up_key_press,down_key_press;
	wire [1:0]snake;
	wire [9:0]x_pos;
	wire [9:0]y_pos;
	wire [5:0]apple_x;
	wire [4:0]apple_y;
	wire [5:0]head_x;
	wire [5:0]head_y;
	
	wire add_cube;
	wire[1:0]game_status;
	wire hit_wall;
	wire hit_body;
	wire die_flash;
	wire restart;
	wire [6:0]cube_num;
	
/***************************************************************************/
/***************************************************************************/

	
	Game_Ctrl_Unit U2
	(
		.CLK_50M(CLK),
		.RSTn(RSTn),
		.key1_press(left_key_press),
		.key2_press(right_key_press),
		.key3_press(up_key_press),
		.key4_press(down_key_press),
		.game_status(game_status),
		.hit_wall(hit_wall),
		.hit_body(hit_body),
		.die_flash(die_flash),
		.restart(restart)
		
	);
		
/***************************************************************************/
/***************************************************************************/
	
	
		Snake_Eatting_Apple U3
	(
		.CLK_50M(CLK),
		.RSTn(RSTn),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube)
	
	);
	
	
/***************************************************************************/
/***************************************************************************/
	
	Snake U4
	(
		.CLK_50M(CLK),
		.RSTn(RSTn),
		.left_press(left_key_press),
		.right_press(right_key_press),
		.up_press(up_key_press),
		.down_press(down_key_press),
		.snake(snake),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube),
		.game_status(game_status),
		.cube_num(cube_num),
		.hit_body(hit_body),
		.hit_wall(hit_wall),
		.die_flash(die_flash)
	);
	
	
	
	
	
	
	
	
/***************************************************************************/
/***************************************************************************/
	
	
	VGA_Control U5
	(
		.CLK_50M(CLK),
		.RSTn(RSTn),
		.hsync(hsync),
		.vsync(vsync),
		.snake(snake),
		.color_out(color_out),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.clk_25M(clk_25M)
	
	);
	
	
/***************************************************************************/
/***************************************************************************/
	Key U6
	(
		.CLK_50M(CLK),
		.RSTn(RSTn),
		.left(left),
		.right(right),
		.up(up),
		.down(down),
		.left_key_press(left_key_press),
		.right_key_press(right_key_press),
		.up_key_press(up_key_press),
		.down_key_press(down_key_press)
	
	);
	
/***************************************************************************/
/***************************************************************************/
	Seg_Display U7
	(
		.CLK_50M(CLK),
		.RSTn(RSTn),	
		.add_cube(add_cube),
		.seg_out(seg_out),
		.sel(sel)
	
	);
	
	
	
	
/***************************************************************************/
/***************************************************************************/




	
	
	endmodule
	
	
	
	
	
	
	
	
/***************************************************************************/
