extends Node2D

@export var x = 0
@export var y = 0
@export var cell_width = 64 #格子宽度
@export var pipe_width = 32 # 水管宽度
@export var pipe_thickness = 4 # 水管厚度

func _draw():
	# 设置绘制土黄色的管壁
	draw_rect(Rect2(Vector2(0, 0), Vector2(cell_width, pipe_width)), Color(0.545, 0.271, 0.075, 1))
	# 设置绘制蓝色的水
	draw_rect(Rect2(Vector2(0, pipe_thickness), Vector2(cell_width, pipe_width - 2 * pipe_thickness)), Color(0, 0, 1, 1))

func _ready():
	pass
