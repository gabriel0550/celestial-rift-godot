extends CharacterBody2D

@export var speed = 100.0
@export var vertical_speed = 50.0
@export var change_direction_time = 1.5
@export var max_distance = 300.0  # Maximum distance from starting position
@export var vertical_range = 50.0  # How far up and down the enemy can fly
@export var min_height = 50.0  # Minimum height above floor

var timer = 0.0
var direction = Vector2.ZERO
var start_position = Vector2.ZERO
var current_position = Vector2.ZERO
var vertical_offset = 0.0
var vertical_direction = 1.0
var floor_position = 100.0

func _ready():
	print("inimigo_voador _ready() called")
	print("inimigo_voador initial global_position: ", global_position)
	# Store the starting position
	start_position = global_position
	current_position = start_position
	
	# Ensure the AnimatedSprite2D exists
	if not $AnimatedSprite2D:
		push_error("AnimatedSprite2D node not found!")
		return
		
	# Start playing the default animation
	$AnimatedSprite2D.play("default")
	print("Animation started")
	
	# Set initial random direction
	change_direction()
	print("Initial direction set: ", direction)
	
	# Get the floor position (assuming it's at y=0 or you can set it manually)
	floor_position = 0.0

func _physics_process(delta):
	print("_physics_process called")
	# Update timer
	timer += delta
	
	# Update current position
	current_position = global_position
	
	# Update vertical movement
	vertical_offset += vertical_speed * delta * vertical_direction
	if abs(vertical_offset) >= vertical_range:
		vertical_direction *= -1
	
	# Check if we've gone too far from start position
	if current_position.distance_to(start_position) > max_distance:
		# Calculate direction back towards start position
		direction = (start_position - current_position).normalized()
		timer = change_direction_time  # Force direction change next frame
	
	# Change direction when timer reaches change_direction_time
	if timer >= change_direction_time:
		change_direction()
		timer = 0.0
	
	# Calculate movement with vertical oscillation
	var horizontal_velocity = direction * speed
	var vertical_velocity = Vector2(0, vertical_speed * vertical_direction)
	
	# Combine horizontal and vertical movement
	velocity = horizontal_velocity + vertical_velocity
	
	# Add some randomness to the movement
	velocity += Vector2(
		randf_range(-10, 10),
		randf_range(-10, 10)
	)
	
	# Ensure we don't go below the floor
	if global_position.y < floor_position + min_height:
		velocity.y = abs(velocity.y)  # Force upward movement
	
	print("Calculated velocity: ", velocity)
	move_and_slide()

func change_direction():
	# Generate random direction (can be any angle)
	var random_angle = randf_range(0, 2 * PI)
	direction = Vector2(cos(random_angle), sin(random_angle))
	
	# Flip sprite based on movement direction
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false 
