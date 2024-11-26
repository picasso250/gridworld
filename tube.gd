extends Node2D

@export var x = 0
@export var y = 0


func _draw():
	# 设置绘制颜色为蓝色
	draw_rect(Rect2(Vector2(0, 0), Vector2(64, 32)), Color(0, 0, 1, 1)) 

func _ready():
	pass
