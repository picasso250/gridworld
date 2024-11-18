extends Node2D

@export var grid_size: Vector2i = Vector2i(11,11)  # n x m 格子数量
@export var cell_size: Vector2 = Vector2(64, 64)   # 每个格子的大小
@export var shader: ShaderMaterial                  # Shader 材质

# 气体类型及其颜色与密度
var gas_types = ["Oxygen", "Carbon Dioxide", "Nitrogen"]
var gas_colors = {
	"Oxygen": Color(0.5, 0.5, 1),        # Soft blue
	"Carbon Dioxide": Color(0.2, 0.2, 0.2),  # Dark gray-black
	"Nitrogen": Color(0.4, 0.6, 0.4),   # Soft green-gray
	"Solid": Color(0.5, 0.5, 0.5)       # Gray (unchanged)
}
var gas_densities = {
	"Oxygen": 1.429,
	"Carbon Dioxide": 1.977,
	"Nitrogen": 1.2506
}  # g/L

# 存储气体网格和精灵
var grid = []
var sprites = []

# 初始化时创建网格数据
func _ready():
	var template_sprite = $Sprite2D
	template_sprite.visible = false  # 模板不可见

	# 初始化网格数据
	for y in range(grid_size.y):
		var row = []
		var sprite_row = []
		for x in range(grid_size.x):
			var gas_type = gas_types[randi() % gas_types.size()]  # 随机选择气体类型
			var gas_mass = randf_range(1, 100)  # 随机质量
			row.append({
				"gas": gas_type,
				"mass": gas_mass
			})
			
			var sprite = template_sprite.duplicate() as Sprite2D
			sprite.material = shader.duplicate() as ShaderMaterial  # 每个实例有独立材质
			sprite.position = Vector2(x, y) * cell_size
			sprite.scale = cell_size / Vector2(128, 128)  # 适配网格尺寸
			sprite.visible = true
			add_child(sprite)
			sprite_row.append(sprite)
		grid.append(row)
		sprites.append(sprite_row)

	# 创建一个固体十字
	var center_row = grid_size.y / 2
	var center_col = grid_size.x / 2
	var cross_size = int(grid_size.y / 2)

	for y in range(center_row - cross_size, center_row + cross_size + 1):
		for x in range(center_col - cross_size, center_col + cross_size + 1):
			if y == center_row or x == center_col:
				if y >= 0 and y < grid_size.y and x >= 0 and x < grid_size.x:
					grid[y][x]["gas"] = "Solid"
					grid[y][x]["mass"] = randf_range(1, 100)  # 固体质量随机


# 获取邻居格子
func get_neighbors(row, col):
	var neighbors = []
	for r in range(row - 1, row + 2):
		for c in range(col - 1, col + 2):
			if r >= 0 and r < grid_size.y and c >= 0 and c < grid_size.x and (r != row or c != col):
				neighbors.append(Vector2(r, c))
	return neighbors

# 交换气体质量（同种气体）
func exchange_gas_mass(row, col, neighbor_row, neighbor_col):
	var gas1 = grid[row][col]
	var gas2 = grid[neighbor_row][neighbor_col]

	if gas1["gas"] == gas2["gas"] and gas1["gas"] != "Solid":
		var total_mass = gas1["mass"] + gas2["mass"]
		var new_mass = total_mass / 2
		grid[row][col]["mass"] = new_mass
		grid[neighbor_row][neighbor_col]["mass"] = new_mass

# 交换元素的通用函数
func swap_elements(a_row, a_col, b_row, b_col):
	var temp = grid[a_row][a_col]
	grid[a_row][a_col] = grid[b_row][b_col]
	grid[b_row][b_col] = temp

# 密度基于交换气体位置
func density_based_swap(row, col, neighbor_row, neighbor_col):
	var gas1 = grid[row][col]
	var gas2 = grid[neighbor_row][neighbor_col]

	if gas1["gas"] == "Solid" or gas2["gas"] == "Solid":
		return  # 固体不交换

	if row == neighbor_row:  # 同行
		swap_elements(row, col, neighbor_row, neighbor_col)
		return

	if gas1["gas"] != gas2["gas"]:  # 不同气体
		var density1 = gas_densities[gas1["gas"]]
		var density2 = gas_densities[gas2["gas"]]

		if row < neighbor_row:
			if density1 > density2:
				swap_elements(row, col, neighbor_row, neighbor_col)
		elif row > neighbor_row:
			if density1 < density2:
				swap_elements(row, col, neighbor_row, neighbor_col)

func debug_grid():
	for y in range(grid_size.y):
		var row = ""
		for x in range(grid_size.x):
			row += grid[y][x]["gas"] + " "
		print(row)

func _physics_process(delta):
	# 随机选择 N 个格子并进行气体交换
	var N = 8
	for i in range(N):
		var rand_row = randi() % grid_size.y
		var rand_col = randi() % grid_size.x
		var neighbors = get_neighbors(rand_row, rand_col)
		var neighbor = neighbors[randi() % neighbors.size()]
		var neighbor_row = neighbor.x
		var neighbor_col = neighbor.y

		var gas1 = grid[rand_row][rand_col]
		var gas2 = grid[neighbor_row][neighbor_col]

		if gas1["gas"] == gas2["gas"] and gas1["gas"] != "Solid":
			exchange_gas_mass(rand_row, rand_col, neighbor_row, neighbor_col)
		else:
			density_based_swap(rand_row, rand_col, neighbor_row, neighbor_col)

	# 更新每个格子的颜色
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var gas = grid[y][x]["gas"]
			var color = gas_colors[gas]
			var sprite = sprites[y][x]
			sprite.material.set_shader_parameter("cell_color", color)
