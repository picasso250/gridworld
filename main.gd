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
	
# 根据物质类型处理不同的行为
func handle_vacuum(row, col):
	# 真空不做任何处理
	pass

func handle_air(row, col):
	var neighbors = get_cell_neighbors(row, col)
	var gas_neighbors = []
	for neighbor in neighbors:
		var neighbor_cell = cells[neighbor.x][neighbor.y]
		if neighbor_cell.phase == "Gas":
			gas_neighbors.append(neighbor)
	
	if gas_neighbors.size() > 0:
		var random_neighbor = gas_neighbors[randi() % gas_neighbors.size()]
		swap_elements(row, col, random_neighbor.x, random_neighbor.y)

func handle_liquid(row, col):
	var neighbors = get_cell_neighbors(row, col)
	var liquid_neighbors = []
	for neighbor in neighbors:
		var neighbor_cell = cells[neighbor.x][neighbor.y]
		if neighbor_cell.phase == "Liquid":
			liquid_neighbors.append(neighbor)
	
	if liquid_neighbors.size() > 0:
		var random_neighbor = liquid_neighbors[randi() % liquid_neighbors.size()]
		swap_elements(row, col, random_neighbor.x, random_neighbor.y)

func handle_solid(row, col):
	# 固体不做处理
	pass

# 处理单个格子的行为
func process_cell(row, col):
	var cell = cells[row][col]

	# 根据物质相，选择相应的处理函数
	if cell.phase == "Vacuum":
		handle_vacuum(row, col)
	elif cell.phase == "Air":
		handle_air(row, col)
	elif cell.phase == "Liquid":
		handle_liquid(row, col)
	elif cell.phase == "Solid":
		handle_solid(row, col)

func _physics_process(delta):
	# 随机选择 N 个格子并根据物质类型进行处理
	var N = 7
	for i in range(N):
		var rand_row = randi() % grid_size.y
		var rand_col = randi() % grid_size.x

		# 处理该格子
		process_cell(rand_row, rand_col)
