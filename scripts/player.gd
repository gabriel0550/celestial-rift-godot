extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
@export var poder_scene: PackedScene  # Cena do poder exportável
var has_power_stone = false

# Health system variables
@export var max_hearts: int = 3
var current_hearts: int = max_hearts
var is_dead: bool = false
var hearts_ui: Control = null
var game_over_screen: Control = null
var facing_right: bool = true  # Track which way the player is facing

# Damage effect variables
var is_flashing: bool = false
var flash_timer: float = 0.0
const FLASH_DURATION: float = 0.5  # Total duration of the flash effect
const FLASH_INTERVAL: float = 0.1  # Time between each flash
var animated_sprite: AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Add the player to the "player" group
	add_to_group("player")
	print("Player added to 'player' group")
	
	# Get the animated sprite node
	animated_sprite = $AnimatedSprite2D
	if animated_sprite == null:
		print("Warning: AnimatedSprite2D not found!")
	
	# Find the hearts UI in the scene
	hearts_ui = get_node("/root/world-1/UI/HeartsUI")
	if hearts_ui == null:
		print("Warning: HeartsUI not found!")
	else:
		print("HeartsUI found successfully")
		
	# Find the Game Over screen in the scene
	game_over_screen = get_node("/root/world-1/GameOver")
	if game_over_screen == null:
		print("Warning: Game Over screen not found! Make sure to add the GameOver scene to your world-1 scene")
	else:
		print("Game Over screen found successfully")
		
	# Update the hearts UI when the game starts
	update_hearts_ui()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO  # Stop all movement when dead
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Movimento lateral
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		# Flip the character instantly based on movement direction
		if direction < 0 and facing_right:
			scale.x = -1
			facing_right = false
		elif direction > 0 and not facing_right:
			scale.x = 1
			facing_right = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 6 * delta)  

	# Disparo de poder
	if Input.is_action_just_pressed("ui_attack"):
		print("Tecla pressionada!")
		soltar_poder()
   
	move_and_slide()
	
	# Update flash effect
	if is_flashing:
		flash_timer += delta
		if flash_timer >= FLASH_DURATION:
			is_flashing = false
			flash_timer = 0.0
			if animated_sprite:
				animated_sprite.modulate = Color(1, 1, 1)  # Reset to normal color
		else:
			# Flash effect
			if animated_sprite:
				var flash_value = sin(flash_timer * PI / FLASH_INTERVAL) > 0
				animated_sprite.modulate = Color(2, 2, 2) if flash_value else Color(1, 1, 1)

# Health system functions
func take_damage() -> void:
	if is_dead:
		print("Player is already dead, can't take damage")
		return
		
	current_hearts -= 1
	print("Player took damage! Current hearts: ", current_hearts)
	update_hearts_ui()
	
	# Start flash effect
	is_flashing = true
	flash_timer = 0.0
	
	if current_hearts <= 0:
		die()

func heal() -> void:
	if is_dead:
		print("Player is dead, can't heal")
		return
		
	if current_hearts < max_hearts:
		current_hearts += 1
		print("Player healed! Current hearts: ", current_hearts)
		update_hearts_ui()

func die() -> void:
	is_dead = true
	print("Player died!")
	# Stop all movement
	velocity = Vector2.ZERO
	
	# Show the Game Over screen
	if game_over_screen != null:
		print("Game Over screen found, attempting to show...")
		if game_over_screen.has_method("show_game_over"):
			game_over_screen.show_game_over()
			print("Game Over screen shown successfully")
		else:
			print("Error: Game Over screen doesn't have show_game_over method!")
	else:
		print("Error: Game Over screen is null! Check if the path is correct")

func update_hearts_ui() -> void:
	if hearts_ui != null:
		if hearts_ui.has_method("update_hearts"):
			hearts_ui.update_hearts(current_hearts)
		else:
			print("Warning: HeartsUI has no update_hearts method!")
	else:
		print("Warning: HeartsUI is null!")

# Função para criar e soltar o poder
func soltar_poder() -> void:
	if not has_power_stone:
		print("Você ainda não tem a Pedra do Poder!")
		return

	print("Tentando soltar o poder...")  
	
	if poder_scene == null:
		print("Erro: poder_scene não está definido! Por favor, defina a cena do poder no editor.")
		return

	var poder = poder_scene.instantiate()
	if poder == null:
		print("Erro ao instanciar o poder!")
		return

	# Get the parent node safely
	var parent = get_parent()
	if parent == null:
		print("Erro: Nó pai não encontrado!")
		return

	parent.add_child(poder)
	poder.position = position + Vector2(10 * sign(scale.x), -10)
	
	# Set the direction as a Vector2 based on player's facing direction
	if poder.has_method("set_direction"):
		poder.set_direction(Vector2(sign(scale.x), 0))
	if poder.has_method("set_is_enemy_power"):
		poder.set_is_enemy_power(false)  # Make sure it's marked as player's power

	print("Poder criado na posição:", poder.position)

# Função chamada pela Pedra do Poder
func collect_power_stone():
	has_power_stone = true
	print("Pedra do poder coletada!")
