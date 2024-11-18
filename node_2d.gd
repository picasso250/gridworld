extends Node2D

@export var shader: ShaderMaterial                # Shader 材质
@export var rows: int = 5                         # 行数 M
@export var columns: int = 5                      # 列数 N
@export var cell_size: Vector2 = Vector2(64, 64)  # 每个 Sprite2D 的大小

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_grid()

# 创建 M x N 的 Sprite2D 网格
func _generate_grid():
	for row in range(rows):
		for col in range(columns):
			var sprite = $Sprite2D.duplicate()
			sprite.material = shader.duplicate()
			add_child(sprite)
			
			# 设置位置
			sprite.position = Vector2(col * cell_size.x, row * cell_size.y)
			
			# 设置随机颜色
			var random_color = Vector4(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1), 1)
			sprite.material.set_shader_parameter("cell_color", random_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for child in get_children():
		if child is Sprite2D:
			var random_color = Vector4(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1), 1)
			child.material.set_shader_parameter("cell_color", random_color)
