extends Node2D

@export var x = 0
@export var y = 0
@export var cell_width = 64 # 格子宽度
@export var pipe_width = 32 # 水管宽度
@export var pipe_thickness = 4 # 水管厚度
@export var is_horizontal = true # 是否为水平管道
@export var debug = false # 是否开启调试模式

func _draw():
	var water_size = pipe_width 
	if is_horizontal:
		# 设置绘制土黄色的水平管壁
		draw_rect(Rect2(Vector2(0, 0), Vector2(cell_width, pipe_width)), Color(0.545, 0.271, 0.075, 1))
		# 设置绘制蓝色的水平水
		draw_rect(Rect2(Vector2(0, 0), Vector2(water_size, water_size)), Color(0, 0, 1, 1))
	else:
		# 设置绘制土黄色的竖直管壁
		draw_rect(Rect2(Vector2(0, 0), Vector2(pipe_width, cell_width)), Color(0.545, 0.271, 0.075, 1))
		# 设置绘制蓝色的竖直水
		draw_rect(Rect2(Vector2(0, 0), Vector2(water_size, water_size)), Color(0, 0, 1, 1))

	if debug:
		# 设置绘制调试十字
		var cross_color = Color(0.8, 0.8, 0.8, 0.5) # 淡灰色
		# 水平线
		draw_rect(Rect2(Vector2(0, 0), Vector2(cell_width, pipe_width)), cross_color)
		# 竖直线
		draw_rect(Rect2(Vector2(0, 0), Vector2(pipe_width, cell_width)), cross_color)

func _ready():
	pass
