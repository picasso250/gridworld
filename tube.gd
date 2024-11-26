extends ColorRect

enum Direction { RIGHT, UP, LEFT, DOWN }
enum Movement { OUTWARD, INWARD }

@export var x: int = 0
@export var y: int = 0
@export var cell_size: float = 64
@export var pipe_width: float = 0.4
@export var draw_left_pipe: bool = true
@export var draw_right_pipe: bool = true
@export var draw_top_pipe: bool = true
@export var draw_bottom_pipe: bool = true
@export var debug: bool = false

@export var pipe_color: Color = Color(0.2, 0.1, 0.04, 1)
@export var water_color: Color = Color(0.2, 0.6, 1.0, 1)


var water_pos_init_center: Vector2 = Vector2(0.5, 0.5)
var water_pos: Vector2 = water_pos_init_center
@export var speed: float = 0.5  # The speed is now a float between 0 and 1
@export var animation_direction: Direction = Direction.RIGHT
@export var animation_movement: Movement = Movement.OUTWARD # Added parameter for inward/outward

func _ready():
	# Set initial shader parameters
	material.set_shader_parameter("pipe_size", pipe_width)
	#shader_material.set_shader_parameter("water_size", water_size)
	material.set_shader_parameter("pipe_color", pipe_color)
	material.set_shader_parameter("water_color", water_color)
	
	if animation_movement == Movement.OUTWARD:
		water_pos = water_pos_init_center
	else: # INWARD
		water_pos = get_edge_position(animation_direction)

func _draw():
	# We don't need to draw anything manually here anymore
	pass

func _process(delta):
	# Calculate the direction vector
	var direction_vector = get_direction_vector(animation_direction, animation_movement)
	
	# Adjust water position based on speed (directly moving within 0-1 range)
	water_pos += direction_vector * speed * delta

	# Check if the water has reached the boundary (0 to 1 range)
	if animation_movement == Movement.OUTWARD:
		if water_pos.x > 1 or water_pos.y > 1 or water_pos.x < 0 or water_pos.y < 0:
			water_pos = water_pos_init_center  # Reset to center if out of bounds
	else: # INWARD
		if abs(water_pos.x) < 0.05 and abs(water_pos.y) < 0.05:  # Close enough to center
			water_pos = get_edge_position(animation_direction)

	# Update water position in shader (no need to normalize, it's already 0-1)
	material.set_shader_parameter("water_center", water_pos)

func get_direction_vector(direction: Direction, movement: Movement):
	var base_vector = get_base_vector(direction)
	return base_vector * (1 if movement == Movement.OUTWARD else -1)

func get_base_vector(direction: Direction):
	match direction:
		Direction.RIGHT:
			return Vector2(1, 0)
		Direction.UP:
			return Vector2(0, -1)
		Direction.LEFT:
			return Vector2(-1, 0)
		Direction.DOWN:
			return Vector2(0, 1)
		_:
			return Vector2(0, 0)

func get_edge_position(direction: Direction):
	# Since the water_pos is already in range 0-1, this function might not be needed
	# unless it's for resetting or handling specific edge scenarios.
	match direction:
		Direction.RIGHT: return Vector2(1, 0.5)
		Direction.UP: return Vector2(0.5, -1)
		Direction.LEFT: return Vector2(-1, 0.5)
		Direction.DOWN: return Vector2(0.5, 1)
		_: return Vector2(0, 0)
