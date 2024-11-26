extends Node2D

@export var x = 0
@export var y = 0
@export var cell_width = 64 # 格子宽度
@export var pipe_width = 32 # 水管宽度
@export var pipe_thickness = 4 # 水管厚度
@export var is_horizontal = true # 是否为水平管道

func _draw():
	if is_horizontal:
		# 设置绘制土黄色的水平管壁
		draw_rect(Rect2(Vector2(0, 0), Vector2(cell_width, pipe_width)), Color(0.545, 0.271, 0.075, 1))
		# 设置绘制蓝色的水平水
		draw_rect(Rect2(Vector2(0, pipe_thickness), Vector2(cell_width, pipe_width - 2 * pipe_thickness)), Color(0, 0, 1, 1))
	else:
		# 设置绘制土黄色的竖直管壁
		draw_rect(Rect2(Vector2(0, 0), Vector2(pipe_width, cell_width)), Color(0.545, 0.271, 0.075, 1))
		# 设置绘制蓝色的竖直水
		draw_rect(Rect2(Vector2(pipe_thickness, 0), Vector2(pipe_width - 2 * pipe_thickness, cell_width)), Color(0, 0, 1, 1))

func _ready():
	pass
