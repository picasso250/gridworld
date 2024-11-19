extends Node2D

@export var grid_size: Vector2i = Vector2i(8, 8)  # n x m 格子数量
@export var cell_size: Vector2 = Vector2(64, 64)    # 每个格子的大小

var template_cell = preload("res://cell.tscn").instantiate()

# 存储气体网格和精灵
var cells = []

func _ready():
	# 初始化网格数据
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			# 使用 Grid.gd 提供的接口来初始化每个网格元素
			var cell = template_cell.duplicate() as Control
			cell.randomize_substance()

			# 设置格子的位置和材质
			cell.position = Vector2(x, y) * cell_size
			cell.scale = cell_size / Vector2(128, 128)  # 适配网格尺寸
			cell.visible = true
			add_child(cell)

			# 将新创建的单元格添加到 cells 中
			row.append(cell)

		cells.append(row)

# 获取邻居格子
func get_cell_neighbors(row, col):
	var neighbors = []
	for r in range(row - 1, row + 2):
		for c in range(col - 1, col + 2):
			if r >= 0 and r < grid_size.y and c >= 0 and c < grid_size.x and (r != row or c != col):
				neighbors.append(Vector2(r, c))
	return neighbors

# 交换相同类型气体的质量
func exchange_substance_mass(row, col, neighbor_row, neighbor_col):
	var cell1 = cells[row][col]
	var cell2 = cells[neighbor_row][neighbor_col]

	if cell1.type == cell2.type and cell1.type != "Solid":
		var total_mass = cell1.mass + cell2.mass
		var new_mass = total_mass / 2
		cell1.set_mass(new_mass)
		cell2.set_mass(new_mass)

# 交换元素的通用函数
func swap_elements(a_row, a_col, b_row, b_col):
	cells[a_row][a_col].swap(cells[b_row][b_col])

# 密度基于交换气体位置
func substance_density_swap(row, col, neighbor_row, neighbor_col):
	var cell1 = cells[row][col]
	var cell2 = cells[neighbor_row][neighbor_col]

	if cell1.type == "Solid" or cell2.type == "Solid":
		return  # 固体不交换

	if row == neighbor_row:  # 同行
		swap_elements(row, col, neighbor_row, neighbor_col)
		return

	if cell1.type != cell2.type:  # 不同气体
		var density1 = template_cell.substance_densities[cell1.type]
		var density2 = template_cell.substance_densities[cell2.type]

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
			var cell = cells[y][x]
			row += cell.type + " "
		print(row)

# 辅助函数：过滤邻居格子
func filter_liquid_neighbors(neighbors):
	var liquid_neighbors = []
	for neighbor in neighbors:
		var cell = cells[neighbor.x][neighbor.y]
		if cell.type == "Water":
			liquid_neighbors.append(neighbor)
	return liquid_neighbors

# 液体运动规则
func liquid_behavior(row, col):
	var below_row = row + 1
	var above_row = row - 1  # 正上方
	if below_row >= grid_size.y:
		return  # 底部边界

	var current_cell = cells[row][col]
	var below_cell = cells[below_row][col]
	var above_cell = cells[above_row][col] if (above_row >= 0) else null

	# 如果当前格子的质量为 0 且正上方是气体，平分质量并更改类型
	if current_cell.mass == 0 and above_cell and above_cell.type != "Water" and above_cell.type != "Solid":
		var gas_type = above_cell.type
		current_cell.set_type(gas_type)
		current_cell.set_phase("Gas")
		var total_mass = above_cell.mass
		var avg_mass = total_mass / 2
		current_cell.set_mass(avg_mass)
		above_cell.set_mass(avg_mass)
		return

	# 处理下方格子，如果下方有水且其质量不足
	if below_cell.type == "Water":
		var density_threshold = template_cell.substance_densities["Water"]
		var missing_mass = density_threshold - below_cell.mass

		if missing_mass > 0:
			# 先填满正下方格子
			var fill_mass = min(current_cell.mass, missing_mass)
			below_cell.set_mass(below_cell.mass + fill_mass)
			current_cell.set_mass(current_cell.mass - fill_mass)
			return

	# 处理左右为水的情况，随机选择一个平分质量
	elif below_cell.type != "Water":
		var left_col = col - 1
		var right_col = col + 1
		var cell_left = null
		var cell_right = null

		if left_col >= 0:
			cell_left = cells[row][left_col]
		if right_col < grid_size.x:
			cell_right = cells[row][right_col]

		# 如果左右有水
		if cell_left and cell_right and cell_left.type == "Water" and cell_right.type == "Water":
			var total_mass = current_cell.mass + cell_left.mass + cell_right.mass
			var avg_mass = total_mass / 3
			# 平分质量
			current_cell.set_mass(avg_mass)
			cell_left.set_mass(avg_mass)
			cell_right.set_mass(avg_mass)
		elif cell_left and cell_left.type == "Water":
			var total_mass_left = current_cell.mass + cell_left.mass
			var avg_mass_left = total_mass_left / 2
			# 平分质量
			current_cell.set_mass(avg_mass_left)
			cell_left.set_mass(avg_mass_left)
		elif cell_right and cell_right.type == "Water":
			var total_mass_right = current_cell.mass + cell_right.mass
			var avg_mass_right = total_mass_right / 2
			# 平分质量
			current_cell.set_mass(avg_mass_right)
			cell_right.set_mass(avg_mass_right)
		return

	# 下方是气体，且不是水或固体，进行交换
	if below_cell.type != "Water" and below_cell.type != "Solid":
		swap_elements(row, col, below_row, col)
		return

# 在 _physics_process 中应用液体行为
func _physics_process(delta):
	# 随机选择 N 个格子并进行气体交换
	var N =8
	for i in range(N):
		var rand_row = randi() % grid_size.y
		var rand_col = randi() % grid_size.x
		var neighbors = get_cell_neighbors(rand_row, rand_col)
		var neighbor = neighbors[randi() % neighbors.size()]
		var neighbor_row = neighbor.x
		var neighbor_col = neighbor.y

		var cell1 = cells[rand_row][rand_col]
		var cell2 = cells[neighbor_row][neighbor_col]

		if cell1.type == cell2.type and cell1.type != "Solid":
			exchange_substance_mass(rand_row, rand_col, neighbor_row, neighbor_col)
		else:
			substance_density_swap(rand_row, rand_col, neighbor_row, neighbor_col)

	# 处理液体行为
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell = cells[y][x]
			if cell.type == "Water":
				liquid_behavior(y, x)
