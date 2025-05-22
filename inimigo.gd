extends CharacterBody2D

const SPEED = 50.0
const ATTACK_RANGE = 50.0
const FOLLOW_RANGE = 200.0
const WALK_DISTANCE = 20.0
const ATTACK_COOLDOWN = 2.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $Animation
@onready var attack_area = $AttackArea

var player: Node2D
var is_attacking = false
var attack_timer = 0.0
var walk_direction = 1
var walk_distance = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_following = false
var can_attack = true
var initial_y_position = 0.0  # Store the initial Y position

func _ready():
	# Find the player node
	player = get_node("/root/world-1/player")
	if player == null:
		print("Warning: Player not found!")
	
	# Add enemy to the enemy group
	add_to_group("enemy")
	
	# Store initial Y position
	initial_y_position = position.y
	
	# Start with idle animation
	animated_sprite.play("default")
	
	# Connect the area signals
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	
	# Connect animation finished signal
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if player == null:
		return
		
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Calculate distance to player
	var distance_to_player = position.distance_to(player.position)
	
	# Check if player is within follow range
	is_following = distance_to_player <= FOLLOW_RANGE
	
	# Handle attack cooldown
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			can_attack = true
		# Maintain Y position during attack
		position.y = initial_y_position
		velocity.y = 0
	
	# Handle movement
	if not is_attacking:
		if is_following:
			# Follow player
			var direction = (player.position - position).normalized()
			velocity.x = direction.x * SPEED
			# Flip sprite based on movement direction
			animated_sprite.flip_h = velocity.x < 0
		else:
			# Walk back and forth when not following
			walk_distance += SPEED * delta * walk_direction
			if abs(walk_distance) >= WALK_DISTANCE:
				walk_direction *= -1
				# Flip the sprite when changing direction
				animated_sprite.flip_h = walk_direction > 0
			
			velocity.x = SPEED * walk_direction
		
		move_and_slide()
		
		# Update initial Y position when on floor
		if is_on_floor():
			initial_y_position = position.y
		
		# Play walk animation if not attacking and not already playing
		if not is_attacking and animated_sprite.animation != "default" and not animated_sprite.is_playing():
			animated_sprite.play("default")

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and can_attack:
		is_attacking = true
		attack_timer = ATTACK_COOLDOWN
		can_attack = false
		# Stop movement when attacking
		velocity.x = 0
		velocity.y = 0
		# Store current Y position
		initial_y_position = position.y
		# Deal damage to player
		if body.has_method("take_damage"):
			body.take_damage()
		# Play attack animation
		animated_sprite.play("attack")

func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		# Reset attack state when player leaves the area
		is_attacking = false
		can_attack = true

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		animated_sprite.play("default")
