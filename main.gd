extends Node2D

@export var grid_size: Vector2i = Vector2i(11, 11)  # n x m 格子数量
@export var cell_size: Vector2 = Vector2(64, 64)   # 每个格子的大小
@export var shader: ShaderMaterial                  # Shader 材质

func _ready():
	# 创建模板 Sprite 节点
	var template_sprite = $Sprite2D
	template_sprite.visible = false  # 模板不可见

	# 创建格子节点
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var sprite = template_sprite.duplicate() as Sprite2D
			sprite.material = shader.duplicate() as ShaderMaterial  # 每个实例有独立材质
			sprite.material.set_shader_parameter("cell_color", Color(randf(), randf(), randf(), 1.0))  # 随机颜色
			sprite.position = Vector2(x, y) * cell_size
			sprite.visible = true  # 显示节点
			sprite.scale = cell_size/Vector2(128,128);
			add_child(sprite)
