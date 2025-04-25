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

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Add the player to the "player" group
	add_to_group("player")
	print("Player added to 'player' group")
	
	# Find the hearts UI in the scene
	hearts_ui = get_node("/root/world-1/UI/HeartsUI")
	if hearts_ui == null:
		print("Warning: HeartsUI not found!")
	else:
		print("HeartsUI found successfully")
		
	# Find the Game Over screen in the scene
	game_over_screen = get_node("../GameOver")
	if game_over_screen == null:
		print("Warning: GameOver screen not found!")
	else:
		print("GameOver screen found successfully")
		
	# Update the hearts UI when the game starts
	update_hearts_ui()

func _physics_process(delta: float) -> void:
	if is_dead:
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
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 6 * delta)  

	# Disparo de poder
	if Input.is_action_just_pressed("ui_attack"):
		print("Tecla pressionada!")
		soltar_poder()
   
	move_and_slide()

# Health system functions
func take_damage() -> void:
	if is_dead:
		print("Player is already dead, can't take damage")
		return
		
	current_hearts -= 1
	print("Player took damage! Current hearts: ", current_hearts)
	update_hearts_ui()
	
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
	# Show the Game Over screen
	if game_over_screen != null and game_over_screen.has_method("show_game_over"):
		game_over_screen.show_game_over()
	else:
		print("Warning: Cannot show Game Over screen!")

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
		print("Erro: poder_scene não está definido!")
		return

	var poder = poder_scene.instantiate()
	if poder == null:
		print("Erro ao instanciar o poder!")
		return

	get_parent().add_child(poder)
	poder.position = position + Vector2(10 * sign(scale.x), -10)
	
	# Set the direction as a Vector2 based on player's facing direction
	poder.direction = Vector2(sign(scale.x), 0)
	poder.is_enemy_power = false  # Make sure it's marked as player's power

	print("Poder criado na posição:", poder.position)

# Função chamada pela Pedra do Poder
func collect_power_stone():
	has_power_stone = true
	print("Pedra do poder coletada!")
