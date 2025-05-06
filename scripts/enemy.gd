extends CharacterBody2D

const SPEED = 100.0
const ATTACK_RANGE = 200.0
const WALK_DISTANCE = 50.0
const ATTACK_COOLDOWN = 3.0

@export var power_scene: PackedScene
var player: Node2D
var is_attacking = false
var attack_timer = 0.0
var walk_direction = 1
var walk_distance = 0.0

# Health system
var max_health = 5
var current_health = max_health

# Get gravity from project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Find the player node
	player = get_node("/root/world-1/player")
	if player == null:
		print("Warning: Player not found!")
	# Add enemy to the enemy group
	add_to_group("enemy")
	# Play idle animation by default
	$AnimationPlayer.play("idle")
	# Connect animation finished signal only if not already connected
	if not $AnimationPlayer.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		$AnimationPlayer.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if player == null:
		return
		
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Calculate distance to player
	var distance_to_player = position.distance_to(player.position)
	print("Distance to player: ", distance_to_player)
	
	# If player is within attack range, start attacking
	if distance_to_player <= ATTACK_RANGE and not is_attacking:
		print("Player in range, starting attack!")
		is_attacking = true
		attack_timer = ATTACK_COOLDOWN
		cast_powers()
	
	# Handle attack cooldown
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			print("Attack cooldown finished")
	
	# Walk back and forth when not attacking
	if not is_attacking:
		walk_distance += SPEED * delta * walk_direction
		if abs(walk_distance) >= WALK_DISTANCE:
			walk_direction *= -1
		
		velocity.x = SPEED * walk_direction
		move_and_slide()
		# Play walk animation if moving, idle if not
		if abs(velocity.x) > 0:
			if $AnimationPlayer.current_animation != "walk":
				$AnimationPlayer.play("walk")
		else:
			if $AnimationPlayer.current_animation != "idle":
				$AnimationPlayer.play("idle")
	else:
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")

func cast_powers() -> void:
	if power_scene == null:
		print("Error: Power scene not set!")
		return
	
	print("Casting powers!")
	# Define the positions for the 5 powers relative to the enemy
	var power_positions = [
		Vector2(-30, 0),  # Left
		Vector2(30, 0),   # Right
		Vector2(-20, -20), # Up-left
		Vector2(20, -20)   # Up-right
	]
	
	# Create and position each power
	for pos in power_positions:
		var power = power_scene.instantiate()
		get_parent().add_child(power)
		# Position the power relative to the enemy's position
		power.position = position + pos
		# Set the power's direction to move towards the player
		power.direction = (player.position - position).normalized()
		# Mark this as an enemy power
		power.is_enemy_power = true

func take_damage() -> void:
	current_health -= 1
	print("Enemy took damage! Current health: ", current_health)
	if current_health > 0:
		$AnimationPlayer.play("take_hit")
	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy died!")
	$AnimationPlayer.play("death")
	set_physics_process(false) # Stop movement and actions

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		queue_free() 
