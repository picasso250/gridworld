extends Control

@export var type: String = "Oxygen"
@export var phase: String = "Gas"  # 三相状态（气液固）
@export var mass: float = 50.0
@export var merged_shader: ShaderMaterial  # 合并后的Shader
@export var x = 0
@export var y = 0

# 气体和液体类型及其颜色与密度
var substance_types = ["Oxygen", "Carbon Dioxide", "Nitrogen", "Water"]

# 三相状态及其可能的物质类型
var phase_types = {
	"Gas": ["Oxygen", "Carbon Dioxide", "Nitrogen"],
	"Liquid": ["Water"],  # 只有水可以是液态
	"Solid": ["Solid"],    # 只有 "Solid" 作为固态
	"Vacuum": ["Vacuum"]          # 新增的真空相，没有物质
}

var substance_colors = {
	"Oxygen": Color(0.5, 0.5, 1),        # Soft blue
	"Carbon Dioxide": Color(0.2, 0.2, 0.2),  # Dark gray-black
	"Nitrogen": Color(0.4, 0.6, 0.4),   # Soft green-gray
	"Solid": Color(0.5, 0.5, 0.5),      # Gray (unchanged)
	"Water": Color(0, 0.5, 1),           # Blue for water
	"Vacuum": Color(0.9, 0.9, 0.9)       # Light gray for vacuum (empty/void look)
}

var substance_densities = {
	"Oxygen": 1.429,
	"Carbon Dioxide": 1.977,
	"Nitrogen": 1.2506,
	"Water": 997.0                      # Density of water in g/L
}

func _ready():
	var texture_rect = get_node("TextureRect")
	texture_rect.material = merged_shader.duplicate()

	update_visuals()
	set_mass_display()
	tooltip_text = _get_tooltip_()

# 随机设置物质类型和相位
func randomize_substance():
	# 随机选择一个相位
	var new_phase = phase_types.keys()[randi() % phase_types.keys().size()]
	
	# 从该相位支持的物质中随机选择一种类型
	var new_type = phase_types[new_phase][randi() % phase_types[new_phase].size()]
	
	# 设置新的相位和类型
	phase = new_phase
	type = new_type
	
	# 随机质量（根据类型和相位设置合理范围）
	# 气体一般质量较小，液体和固体可能更重
	if new_phase == "Gas":
		set_mass(randf_range(1.0, 100.0))  # 轻质量
	elif new_phase == "Liquid":
		set_mass(randf_range(10.0, 1000.0))  # 中等质量
	elif new_phase == "Solid":
		set_mass(randf_range(50.0, 500.0))  # 较高质量
	elif new_phase == "Vacuum":
		set_mass(0)  # Vacuum has no mass, so set to 0
		
	update_visuals()
	tooltip_text = _get_tooltip_()
	set_mass_display()

# 设置物质类型
func set_type(new_type: String):
	if type != new_type:
		type = new_type
		update_visuals()	
		tooltip_text = _get_tooltip_()

# 设置物质的三相状态（气、液、固）
func set_phase(new_phase: String):
	if phase != new_phase:
		phase = new_phase
		update_visuals()	
		tooltip_text = _get_tooltip_()

func set_phase_and_type(new_phase: String, new_type: String):
	type = new_type
	phase = new_phase
	update_visuals()	
	tooltip_text = _get_tooltip_()

# 设置质量
func set_mass(new_mass: float):
	mass = new_mass
	set_mass_display()
	update_visuals()

# 更新质量显示
func set_mass_display():
	# 假设有一个 Label 节点来显示质量
	var label = get_node("MarginContainer/Label")
	label.text = str(round(mass))

# 更新显示内容
func update_visuals():
	var texture_rect = get_node("TextureRect")
	
	# 根据相位选择不同的显示效果
	if phase == "Liquid":
		# 对于液体，传递液体量
		texture_rect.material.set_shader_parameter("type", 1)  # 设置相位为液体
		texture_rect.material.set_shader_parameter("liquid_amount", mass / substance_densities["Water"])
		texture_rect.material.set_shader_parameter("liquid_color", substance_colors[type])  # 设置液体颜色
	elif phase == "Solid":
		# 对于固体，传递固体颜色
		texture_rect.material.set_shader_parameter("type", 0)  # 设置相位为固体
		texture_rect.material.set_shader_parameter("solid_color", substance_colors[type])
	elif phase == "Vacuum":
		# 对于真空，传递真空颜色
		texture_rect.material.set_shader_parameter("type", 3)  # 设置相位为真空
		# texture_rect.material.set_shader_parameter("solid_color", substance_colors["Vacuum"])  # 真空的颜色
	else:  # 默认气态
		# 对于气体，传递气体颜色
		texture_rect.material.set_shader_parameter("type", 2)  # 设置相位为气体
		texture_rect.material.set_shader_parameter("gas_color", substance_colors[type])

func _get_tooltip_():
	return type + "\n" + phase + "\n质量：" + str(mass) + "\n位置: (" + str(x) + ", " + str(y) + ")"

# 交换属性（直接赋值，不调用 set_* 方法）
func swap(other_instance: Node):
	if other_instance == null:
		print("Error: Provided instance is null.")
		return
	
	# 交换属性（直接赋值，不调用 set_* 方法）
	var temp_type = type
	var temp_phase = phase
	var temp_mass = mass
	var temp_shader = get_node("TextureRect").material  # Save the shader material

	type = other_instance.type
	phase = other_instance.phase
	mass = other_instance.mass
	get_node("TextureRect").material = other_instance.get_node("TextureRect").material  # Update the material to the swapped instance's material

	other_instance.type = temp_type
	other_instance.phase = temp_phase
	other_instance.mass = temp_mass
	other_instance.get_node("TextureRect").material = temp_shader  # Restore the original material to the other instance

	# 统一更新视觉效果和其他必要状态
	update_visuals()
	set_mass_display()
	tooltip_text = _get_tooltip_()
	
	other_instance.update_visuals()
	other_instance.set_mass_display()
	other_instance.tooltip_text = other_instance._get_tooltip_()

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			set_phase("Liquid")
			set_type("Water")
			set_mass(substance_densities["Water"])
