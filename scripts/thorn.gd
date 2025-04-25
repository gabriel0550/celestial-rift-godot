extends Area2D

@export var damage_amount: int = 1
var can_damage: bool = true

func _ready() -> void:
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)
	# Make sure the area doesn't have physical collision
	collision_layer = 0
	collision_mask = 1  # Only detect layer 1 (player)
	
	# Debug message to check if the area has shapes for damage detection
	var has_collision_shapes = false
	for child in get_children():
		if child is CollisionShape2D:
			has_collision_shapes = true
			break
	
	if not has_collision_shapes:
		print("WARNING: Area2D needs CollisionShape2D nodes as direct children for damage detection!")
	else:
		print("Area2D collision shapes are set up correctly")
		
	# Debug message to check if the timer exists
	if $DamageCooldown == null:
		print("WARNING: DamageCooldown timer not found!")
	else:
		print("DamageCooldown timer found and set up correctly")
		# Connect the timer's timeout signal if not already connected
		if not $DamageCooldown.timeout.is_connected(_on_damage_cooldown_timeout):
			$DamageCooldown.timeout.connect(_on_damage_cooldown_timeout)
			print("Timer timeout signal connected")

func _on_body_entered(body: Node2D) -> void:
	print("Body entered damage area: ", body.name)
	# Check if the body that entered is the player and we can damage
	if body.is_in_group("player") and can_damage:
		print("Player entered damage area and can take damage")
		# Get the player's take_damage function and call it
		if body.has_method("take_damage"):
			body.take_damage()
			can_damage = false
			print("Damage applied, starting cooldown")
			# Start a timer to allow damage again
			if $DamageCooldown:
				$DamageCooldown.start()
				print("Cooldown timer started")
			else:
				print("WARNING: DamageCooldown timer not found!")
		else:
			print("WARNING: Body has no take_damage method!")
	else:
		print("Body is not player or can't take damage yet (can_damage = ", can_damage, ")")

func _on_damage_cooldown_timeout() -> void:
	can_damage = true
	print("Damage cooldown finished, can damage again") 
