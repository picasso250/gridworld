extends Node2D

@export var x = 0
@export var y = 0
@export var pipe_width = 64 # 水管宽度
@export var pipe_length = 32 # 水管长度

func _draw():
	# 设置绘制颜色为蓝色
	draw_rect(Rect2(Vector2(0, 0), Vector2(pipe_width, pipe_length)), Color(0, 0, 1, 1))

func _ready():
	pass
