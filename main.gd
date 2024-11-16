extends Node2D

@export var grid_size: Vector2i = Vector2i(10, 10)  # n x m 格子数量
@export var cell_size: Vector2 = Vector2(32, 32)   # 每个格子的大小
@export var shader: ShaderMaterial                 # Shader 材质

func _ready():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var sprite = Sprite2D.new()
			var texture = ImageTexture.new()  # 空白纹理
			texture.set_size_override(cell_size)
			sprite.texture = texture
			sprite.material = shader            # 应用 Shader
			sprite.position = Vector2(x, y) * cell_size
			sprite.scale = cell_size / Vector2(16, 16)  # 根据需要调整比例
			add_child(sprite)
