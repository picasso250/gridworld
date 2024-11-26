extends Node2D

@export var x = 0
@export var y = 0
@export var cell_width: float = 64 # 格子宽度
@export var pipe_width: float = 32 # 水管直径
@export var pipe_thickness: float = 4 # 水管壁厚度
@export var draw_left_pipe: bool = true # 是否画左半边的管道
@export var draw_right_pipe: bool = true # 是否画右半边的管道
@export var draw_top_pipe: bool = true # 是否画上半边的管道
@export var draw_bottom_pipe: bool = true # 是否画下半边的管道
@export var debug = false # 是否开启调试模式

# 参数化颜色
@export var pipe_color = Color(0.545, 0.271, 0.075, 1) # 管壁颜色 (土黄色)
@export var water_color = Color(0, 0, 1, 1) # 水的颜色 (蓝色)

func _draw():
	var water_size = pipe_width - pipe_thickness * 2 # 水的大小

	if draw_left_pipe:
		# 绘制左半边的管道
		draw_rect(Rect2(Vector2(-cell_width / 2, -pipe_width / 2), Vector2(cell_width / 2+pipe_width/2, pipe_width)), pipe_color)

	if draw_right_pipe:
		# 绘制右半边的管道
		draw_rect(Rect2(Vector2(-pipe_width / 2, -pipe_width / 2), Vector2(cell_width / 2+pipe_width / 2, pipe_width)), pipe_color)

	if draw_top_pipe:
		# 绘制上半边的管道
		draw_rect(Rect2(Vector2(-pipe_width / 2, -cell_width / 2), Vector2(pipe_width, cell_width / 2 + pipe_width / 2)), pipe_color)

	if draw_bottom_pipe:
		# 绘制下半边的管道
		draw_rect(Rect2(Vector2(-pipe_width / 2, -pipe_width / 2), Vector2(pipe_width, cell_width / 2 + pipe_width / 2)), pipe_color)

	# 绘制水：考虑管道壁的厚度
	draw_rect(Rect2(Vector2(-water_size / 2, -water_size / 2), Vector2(water_size, water_size)), water_color)

	if debug:
		# 绘制调试十字
		var cross_color = Color(0.8, 0.8, 0.8, 0.1) # 淡灰色
		draw_rect(Rect2(Vector2(-cell_width / 2, -pipe_width / 2), Vector2(cell_width, pipe_width)), cross_color)
		draw_rect(Rect2(Vector2(-pipe_width / 2, -cell_width / 2), Vector2(pipe_width, cell_width)), cross_color)

func _ready():
	pass
