extends Node2D

@export var speed: float = 100.0  # Speed of movement
@export var distance: float = 40.0  # Distance to move left and right
@export var start_direction: int = 1  # 1 for right, -1 for left

var start_position: Vector2
var current_direction: int

func _ready():
	start_position = position
	current_direction = start_direction

func _process(delta):
	# Calculate movement
	var movement = Vector2(speed * current_direction * delta, 0)
	position += movement
	
	# Check if we need to change direction
	if abs(position.x - start_position.x) >= distance:
		current_direction *= -1  # Reverse direction 
