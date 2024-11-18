extends Node2D

@export var grid_size: Vector2i = Vector2i(11,11)  # n x m 格子数量
@export var cell_size: Vector2 = Vector2(64, 64)    # 每个格子的大小
@export var shader: ShaderMaterial                  # Shader 材质

# 气体和液体类型及其颜色与密度
var substance_types = ["Oxygen", "Carbon Dioxide", "Nitrogen", "Water"]
var substance_colors = {
	"Oxygen": Color(0.5, 0.5, 1),        # Soft blue
	"Carbon Dioxide": Color(0.2, 0.2, 0.2),  # Dark gray-black
	"Nitrogen": Color(0.4, 0.6, 0.4),   # Soft green-gray
	"Solid": Color(0.5, 0.5, 0.5),      # Gray (unchanged)
	"Water": Color(0, 0.5, 1)           # Blue for water
}
var substance_densities = {
	"Oxygen": 1.429,
	"Carbon Dioxide": 1.977,
	"Nitrogen": 1.2506,
	"Water": 997.0                      # Density of water in g/L
}

# 存储气体网格和精灵
var grid = []
var sprites = []
var labels = []  # 用于存储标签

# 初始化时创建网格数据
func _ready():
	var template_sprite = $Sprite2D
	template_sprite.visible = false  # 模板不可见

	# 初始化网格数据
	for y in range(grid_size.y):
		var row = []
		var sprite_row = []
		var label_row = []  # 用于每一行的标签
		for x in range(grid_size.x):
			row.append({
				"type": substance_types[randi() % substance_types.size()],
				"mass": randf_range(1, 100)
			})

			# 创建精灵
			var sprite = template_sprite.duplicate() as Sprite2D
			sprite.material = shader.duplicate() as ShaderMaterial  # 每个实例有独立材质
			sprite.position = Vector2(x, y) * cell_size
			sprite.scale = cell_size / Vector2(128, 128)  # 适配网格尺寸
			sprite.visible = true
			add_child(sprite)
			sprite_row.append(sprite)

			# 创建并初始化标签
			var label = Label.new()
			var mass = row[x]["mass"]
			label.text = str(round(mass))  # 显示四舍五入后的质量
			label.set_size(cell_size)  # 标签尺寸与格子一致
			label.align = HORIZONTAL_ALIGNMENT_CENTER
			label.valign = VERTICAL_ALIGNMENT_CENTER
			label.position = Vector2(x, y) * cell_size  # 对齐到网格位置
			add_child(label)
			label_row.append(label)

		grid.append(row)
		sprites.append(sprite_row)
		labels.append(label_row)

# 获取邻居格子
func get_cell_neighbors(row, col):
	var neighbors = []
	for r in range(row - 1, row + 2):
		for c in range(col - 1, col + 2):
			if r >= 0 and r < grid_size.y and c >= 0 and c < grid_size.x and (r != row or c != col):
				neighbors.append(Vector2(r, c))
	return neighbors

# 交换气体质量（同种气体）
func exchange_substance_mass(row, col, neighbor_row, neighbor_col):
	var gas1 = grid[row][col]
	var gas2 = grid[neighbor_row][neighbor_col]

	if gas1["type"] == gas2["type"] and gas1["type"] != "Solid":
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
func substance_density_swap(row, col, neighbor_row, neighbor_col):
	var gas1 = grid[row][col]
	var gas2 = grid[neighbor_row][neighbor_col]

	if gas1["type"] == "Solid" or gas2["type"] == "Solid":
		return  # 固体不交换

	if row == neighbor_row:  # 同行
		swap_elements(row, col, neighbor_row, neighbor_col)
		return

	if gas1["type"] != gas2["type"]:  # 不同气体
		var density1 = substance_densities[gas1["type"]]
		var density2 = substance_densities[gas2["type"]]

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
			row += grid[y][x]["type"] + " "
		print(row)

# 辅助函数：过滤邻居格子
func filter_liquid_neighbors(neighbors):
	var liquid_neighbors = []
	for neighbor in neighbors:
		var cell = grid[neighbor.x][neighbor.y]
		if cell["type"] == "Water":
			liquid_neighbors.append(neighbor)
	return liquid_neighbors

# 液体运动规则
func liquid_behavior(row, col):
	var below_row = row + 1
	if below_row >= grid_size.y:
		return  # 底部边界

	var gas1 = grid[row][col]
	var gas2 = grid[below_row][col]

	# 处理下方格子，如果下方有水且其质量不足
	if gas2["type"] == "Water":
		var target_cell = grid[below_row][col]
		var density_threshold = substance_densities["Water"]
		var missing_mass = density_threshold - target_cell["mass"]

		if missing_mass > 0:
			# 先填满正下方格子
			var fill_mass = min(gas1["mass"], missing_mass)
			target_cell["mass"] += fill_mass
			gas1["mass"] -= fill_mass
			missing_mass -= fill_mass

	# 处理左右为水的情况，随机选择一个平分质量
	elif gas2["type"] != "Water":
		var left_col = col - 1
		var right_col = col + 1
		var gas_left = null
		var gas_right = null

		if left_col >= 0:
			gas_left = grid[row][left_col]
		if right_col < grid_size.x:
			gas_right = grid[row][right_col]

		# 如果左右有水
		if gas_left and gas_right and gas_left["type"] == "Water" and gas_right["type"] == "Water":
			var total_mass = gas1["mass"] + gas_left["mass"] + gas_right["mass"]
			var avg_mass = total_mass / 3
			# 平分质量
			gas1["mass"] = avg_mass
			gas_left["mass"] = avg_mass
			gas_right["mass"] = avg_mass
		elif gas_left and gas_left["type"] == "Water":
			var total_mass_left = gas1["mass"] + gas_left["mass"]
			var avg_mass_left = total_mass_left / 2
			# 平分质量
			gas1["mass"] = avg_mass_left
			gas_left["mass"] = avg_mass_left
		elif gas_right and gas_right["type"] == "Water":
			var total_mass_right = gas1["mass"] + gas_right["mass"]
			var avg_mass_right = total_mass_right / 2
			# 平分质量
			gas1["mass"] = avg_mass_right
			gas_right["mass"] = avg_mass_right

	# 下方是气体，与其交换
	swap_elements(row, col, below_row, col)

# 在 _physics_process 中应用液体行为
func _physics_process(delta):
	debug_grid()
	# 随机选择 N 个格子并进行气体交换
	var N = 8
	for i in range(N):
		var rand_row = randi() % grid_size.y
		var rand_col = randi() % grid_size.x
		var neighbors = get_cell_neighbors(rand_row, rand_col)
		var neighbor = neighbors[randi() % neighbors.size()]
		var neighbor_row = neighbor.x
		var neighbor_col = neighbor.y

		var gas1 = grid[rand_row][rand_col]
		var gas2 = grid[neighbor_row][neighbor_col]

		if gas1["type"] == gas2["type"] and gas1["type"] != "Solid":
			exchange_substance_mass(rand_row, rand_col, neighbor_row, neighbor_col)
		else:
			substance_density_swap(rand_row, rand_col, neighbor_row, neighbor_col)

	# 处理液体行为
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if grid[y][x]["type"] == "Water":
				liquid_behavior(y, x)

	# 更新每个格子的颜色和质量显示
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var gas = grid[y][x]["type"]
			var color = substance_colors[gas]
			var sprite = sprites[y][x]
			var label = labels[y][x]  # 获取对应的标签
			sprite.material.set_shader_parameter("cell_color", color)
			label.text = str(round(grid[y][x]["mass"]))  # 更新标签的质量
