extends Node2D

@export var grid_size: Vector2i = Vector2i(4, 4)  # n x m grid size
@export var cell_size: Vector2 = Vector2(64, 64)  # Each cell size

# Stores the tube grid
var tubes = []

func _ready():
	var template_tube = $Tube as Control
	# Initialize grid data
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			# Use the tube template to initialize each grid element
			var tube = template_tube.duplicate() 

			# Set the position and scale of the tube
			tube.position = Vector2(x, y) * cell_size
			tube.visible = true
			tube.set_show_center_circle(false)
			tube.x = y
			tube.y = x
			tube.material = template_tube.material.duplicate()
			add_child(tube)

			# Add the newly created tube to the tubes grid
			row.append(tube)

		tubes.append(row)
