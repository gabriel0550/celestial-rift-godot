extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var poder_scene: PackedScene
var has_power_stone = false

@export var max_hearts: int = 3
var current_hearts: int = max_hearts
var is_dead: bool = false
var hearts_ui: Control = null
var game_over_screen: Control = null
var facing_right: bool = true

var is_flashing: bool = false
var flash_timer: float = 0.0
const FLASH_DURATION: float = 0.5
const FLASH_INTERVAL: float = 0.1
var animated_sprite: AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attack_area: Area2D = null
var can_attack := true

var attack_timer: Timer = null

# Fire attack cooldown variables
var fire_attack_cooldown := 1.0 # seconds
var can_fire_attack := true
var fire_attack_timer: Timer = null

func _ready() -> void:
	add_to_group("player")
	print("Player added to 'player' group")

	animated_sprite = $AnimatedSprite2D
	attack_area = $AttackArea

	if animated_sprite == null:
		print("Warning: AnimatedSprite2D not found!")

	# Try to find HeartsUI in different world configurations and detect current world
	hearts_ui = get_node("/root/world-1/UI/HeartsUI")  # World 1 path
	if hearts_ui == null:
		hearts_ui = get_node("/root/world_2/UI/HeartsUI")  # World 2 path
		if hearts_ui != null:
			# Player is in world_2, enable power stone automatically
			has_power_stone = true
			print("World 2 detected - Power stone enabled!")
	if hearts_ui == null:
		hearts_ui = get_node("/root/world_3/UI/HeartsUI")  # World 3 path
		if hearts_ui != null:
			# Player is in world_3, enable power stone automatically  
			has_power_stone = true
			print("World 3 detected - Power stone enabled!")
	
	if hearts_ui == null:
		print("Warning: HeartsUI not found in any world!")
	else:
		print("HeartsUI found successfully")

	# Try to find GameOver screen in different world configurations
	print("Looking for Game Over screen in different worlds...")
	
	game_over_screen = get_node_or_null("/root/world-1/UI/GameOver")  # World 1 path
	if game_over_screen != null:
		print("Found GameOver in world-1")
	
	if game_over_screen == null:
		game_over_screen = get_node_or_null("/root/world_2/UI/GameOver")  # World 2 path
		if game_over_screen != null:
			print("Found GameOver in world_2")
	
	if game_over_screen == null:
		game_over_screen = get_node_or_null("/root/world_3/UI/GameOver")  # World 3 path
		if game_over_screen != null:
			print("Found GameOver in world_3")
	
	if game_over_screen == null:
		print("Warning: Game Over screen not found in any world!")
	else:
		print("Game Over screen found successfully")

	update_hearts_ui()

	# Criar e configurar o Timer para ataque
	attack_timer = Timer.new()
	attack_timer.wait_time = 0.6  # Ajuste para a duração da animação de ataque
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	add_child(attack_timer)

	# Criar e configurar o Timer para cooldown do ataque de fogo
	fire_attack_timer = Timer.new()
	fire_attack_timer.wait_time = fire_attack_cooldown
	fire_attack_timer.one_shot = true
	fire_attack_timer.connect("timeout", Callable(self, "_on_fire_attack_timer_timeout"))
	add_child(fire_attack_timer)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("ui_left", "ui_right")

	# Atualiza o flip sempre que houver direção diferente de zero
	if direction != 0:
		facing_right = direction > 0
		animated_sprite.scale.x = 1 if facing_right else -1


	# Movimento horizontal
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 6 * delta)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Ataque à distância (poder)
	if Input.is_action_just_pressed("ui_attack"):
		if can_fire_attack:
			print("Tecla pressionada!")
			soltar_poder()
			if animated_sprite and not animated_sprite.is_playing():
				animated_sprite.play("attack")
			can_fire_attack = false
			fire_attack_timer.start()
		else:
			print("Fire attack on cooldown!")

	# Ataque de espada (corpo a corpo)
	if Input.is_action_just_pressed("ui_sword_attack") and can_attack:
		atacar_com_espada()

	# Se não estiver atacando, atualiza animação de movimento
	if can_attack and (animated_sprite.animation != "sword_attack" and animated_sprite.animation != "attack"):
		if not is_on_floor():
			animated_sprite.play("jump")
		elif direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

	move_and_slide()

	if is_flashing:
		flash_timer += delta
		if flash_timer >= FLASH_DURATION:
			is_flashing = false
			flash_timer = 0.0
			if animated_sprite:
				animated_sprite.modulate = Color(1, 1, 1)
		else:
			if animated_sprite:
				var flash_value = sin(flash_timer * PI / FLASH_INTERVAL) > 0
				animated_sprite.modulate = Color(2, 2, 2) if flash_value else Color(1, 1, 1)

func take_damage() -> void:
	if is_dead:
		print("Player is already dead, can't take damage")
		return

	current_hearts -= 1
	print("Player took damage! Current hearts: ", current_hearts)
	update_hearts_ui()

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
	print("Player died! Current scene: " + get_tree().current_scene.name)
	velocity = Vector2.ZERO
	
	# WORLD 2 SPECIFIC FIX - Direct approach for world_2
	var current_scene = get_tree().current_scene
	if current_scene.name == "world_2":
		print("World 2 detected, using direct approach")
		
		if current_scene.has_node("UI/GameOver"):
			var world2_game_over = current_scene.get_node("UI/GameOver")
			world2_game_over.visible = true
			
			# Force show_game_over call
			if world2_game_over.has_method("show_game_over"):
				world2_game_over.call("show_game_over")
				print("Called show_game_over on world_2 GameOver")
			
			# Ensure particles work
			world2_game_over.process_mode = Node.PROCESS_MODE_ALWAYS
			
			return
	
	# GENERAL APPROACH - Try direct reference first
	if current_scene.has_node("UI/GameOver"):
		var direct_game_over = current_scene.get_node("UI/GameOver")
		print("Found GameOver directly in current world UI")
		
		direct_game_over.visible = true
		if direct_game_over.has_method("show_game_over"):
			direct_game_over.show_game_over()
			print("Showing GameOver using direct reference")
			return
	
	# Try autoloads
	if get_node_or_null("/root/GameOverManager") != null:
		get_node("/root/GameOverManager").show_game_over()
		print("Using GameOverManager for game over")
		return
		
	elif get_node_or_null("/root/GameManager") != null:
		get_node("/root/GameManager").show_game_over()
		print("Using GameManager for game over")
		return
	
	# Fallback methods
	print("Game managers not found, trying fallback methods")
	
	# Try to find existing GameOver screen in the world
	var game_over_ui = find_game_over_ui()
	
	# If we found a GameOver UI in the scene, use it
	if game_over_ui:
		game_over_screen = game_over_ui
		print("Using existing GameOver UI found by find_game_over_ui()")
		
		game_over_screen.visible = true
		if game_over_screen.has_method("show_game_over"):
			game_over_screen.show_game_over()
		else:
			print("Error: Game Over screen doesn't have show_game_over method!")
	else:
		# Final fallback - create a new Game Over UI
		var ui_layer = find_ui_layer()
		if ui_layer:
			var game_over_scene = load("res://scenes/GameOver.tscn")
			if game_over_scene:
				var game_over_instance = game_over_scene.instantiate()
				ui_layer.add_child(game_over_instance)
				game_over_screen = game_over_instance
				print("GameOver UI created as last resort")
				game_over_screen.visible = true
				
				if game_over_screen.has_method("show_game_over"):
					game_over_screen.show_game_over()
		else:
			print("Error: Couldn't find or create UI layer for GameOver!")

func find_ui_layer() -> Node:
	# Try to find UI in the current scene
	var current_scene = get_tree().current_scene
	
	# Check if we're in any world with UI node
	if current_scene and current_scene.has_node("UI"):
		return current_scene.get_node("UI")
	
	# If no UI layer exists and we need one, create it
	print("Creating new UI layer for Game Over screen")
	var new_ui_layer = CanvasLayer.new()
	new_ui_layer.name = "UI"
	new_ui_layer.layer = 10 # Higher layer to appear on top
	
	if current_scene:
		current_scene.add_child(new_ui_layer)
		return new_ui_layer
		
	return null

func update_hearts_ui() -> void:
	if hearts_ui != null and hearts_ui.has_method("update_hearts"):
		hearts_ui.update_hearts(current_hearts)
		
func find_game_over_ui() -> Control:
	var current_scene = get_tree().current_scene
	
	# Check for UI node in the scene
	if current_scene.has_node("UI"):
		var ui_layer = current_scene.get_node("UI")
		
		# Look for GameOver in UI
		if ui_layer.has_node("GameOver"):
			return ui_layer.get_node("GameOver")
	
	return null

func soltar_poder() -> void:
	if not has_power_stone:
		print("Você ainda não tem a Pedra do Poder!")
		return

	if poder_scene == null:
		print("Erro: poder_scene não está definido!")
		return

	var poder = poder_scene.instantiate()
	if poder == null:
		print("Erro ao instanciar o poder!")
		return

	var parent = get_parent()
	if parent == null:
		print("Erro: Nó pai não encontrado!")
		return

	parent.add_child(poder)
	poder.position = position + Vector2(10 * sign(animated_sprite.scale.x), -40)

	if poder.has_method("set_direction"):
		poder.set_direction(Vector2(sign(animated_sprite.scale.x), 0))
	if poder.has_method("set_is_enemy_power"):
		poder.set_is_enemy_power(false)

	print("Poder criado na posição:", poder.position)

func collect_power_stone():
	has_power_stone = true
	print("Pedra do poder coletada!")

func atacar_com_espada() -> void:
	if not can_attack:
		return

	can_attack = false
	if animated_sprite:
		animated_sprite.play("sword_attack")

	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage()

	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true
	if animated_sprite:
		animated_sprite.play("idle")

func _on_fire_attack_timer_timeout() -> void:
	can_fire_attack = true
