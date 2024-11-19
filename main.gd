extends Node2D

@export var grid_size: Vector2i = Vector2i(4,4)  # n x m 格子数量
@export var cell_size: Vector2 = Vector2(64, 64)    # 每个格子的大小

var template_cell = preload("res://cell.tscn").instantiate()

# 存储气体网格和精灵
var cells = []

# Define an EPSILON value for small mass comparisons
var EPSILON = 0.0001

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
			cell.x = y
			cell.y = x
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

# 交换相同类型物质的质量
func exchange_substance_mass(cell1, cell2):
	if cell1.type == cell2.type and cell1.type != "Solid":
		var total_mass = cell1.mass + cell2.mass
		var new_mass = total_mass / 2
		cell1.set_mass(new_mass)
		cell2.set_mass(new_mass)

# 交换元素的通用函数
func swap_elements(a_row, a_col, b_row, b_col):
	cells[a_row][a_col].swap(cells[b_row][b_col])

# 基于密度交换气体位置
func substance_density_swap(row, col, neighbor_row, neighbor_col):
	var cell1 = cells[row][col]
	var cell2 = cells[neighbor_row][neighbor_col]

	if cell1.type != "Gas" or cell2.type != "Gas":
		return

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

# 液体下落并填充缺少的质量
func fall_liquid(current_cell, below_cell):
	var density_threshold = template_cell.substance_densities["Water"]
	var missing_mass = density_threshold - below_cell.mass
	if missing_mass > 0:
		# 填满正下方格子
		var fill_mass = min(current_cell.mass, missing_mass)
		below_cell.set_mass(below_cell.mass + fill_mass)
		current_cell.set_mass(current_cell.mass - fill_mass)

# 检查8个邻居是否有气体
func find_gas_neighbor(row, col) -> Node:
	for r in range(row - 1, row + 2):
		for c in range(col - 1, col + 2):
			if r >= 0 and r < grid_size.y and c >= 0 and c < grid_size.x and (r != row or c != col):
				var neighbor_cell = cells[r][c]
				if neighbor_cell.phase == "Gas":
					return neighbor_cell
	return null

func liquid_behavior(row, col):
	var below_row = row + 1
	var above_row = row - 1  # 正上方
	var left_col = col - 1
	var right_col = col + 1
	var cell_left = 		 cells[row][left_col] if left_col >= 0 else null
	var cell_right = 		 cells[row][right_col] if right_col < grid_size.x else null

	var current_cell = cells[row][col]
	var above_cell = cells[above_row][col] if (above_row >= 0) else null
	var below_cell = cells[below_row][col] if (below_row < grid_size.y) else null

	# 使用 find_gas_neighbor 函数来检查邻居是否有气体
	var gas_cell = find_gas_neighbor(row, col)

	# 如果找到气体，平分质量并更改类型
	if current_cell.mass < EPSILON and gas_cell:
		var gas_type = gas_cell.type
		current_cell.set_type(gas_type)
		current_cell.set_phase("Gas")
		exchange_substance_mass(current_cell, gas_cell)

	# 如果上方是液体，调用fall_liquid
	elif above_cell and above_cell.phase == "Liquid":
		fall_liquid(above_cell, current_cell)
		return

	# 处理下方格子，如果下方有液体
	elif below_cell and below_cell.phase == "Liquid":
		fall_liquid(current_cell, below_cell)

	# 下方是气体，进行交换
	elif below_cell and below_cell.phase == "Gas":
		swap_elements(row, col, below_row, col)
		return

	# 检查左边
	if cell_left:
		if cell_left.phase == "Liquid":
			exchange_substance_mass(current_cell, cell_left)
		elif cell_left.phase == "Gas":
			cell_left.set_phase(current_cell.phase)
			cell_left.set_type(current_cell.type)
			cell_left.set_mass(0)
			exchange_substance_mass(current_cell,cell_left)

	# 检查右边
	elif cell_right:
		if cell_right.phase == "Liquid":
			exchange_substance_mass(current_cell, cell_right)
		elif cell_right.phase == "Gas":
			cell_right.set_phase(current_cell.phase)
			cell_right.set_type(current_cell.type)
			cell_right.set_mass(0)
			exchange_substance_mass(current_cell,cell_right)

func _physics_process(delta):
	# 随机选择 N 个格子并根据物质类型进行处理
	var N = 7
	for i in range(N):
		var rand_row = randi() % grid_size.y
		var rand_col = randi() % grid_size.x
		var cell = cells[rand_row][rand_col]

		# 处理液体
		if cell.phase == "Liquid":
			liquid_behavior(rand_row, rand_col)
			
		# 处理气体
		elif cell.phase == "Gas":
			var neighbors = get_cell_neighbors(rand_row, rand_col)
			var neighbor = neighbors[randi() % neighbors.size()]
			var neighbor_row = neighbor.x
			var neighbor_col = neighbor.y

			var cell2 = cells[neighbor_row][neighbor_col]

			if cell.type == cell2.type:
				exchange_substance_mass(cell, cell2)
			else:
				substance_density_swap(rand_row, rand_col, neighbor_row, neighbor_col)
		
		# 固体不做处理，跳过
