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

func _ready() -> void:
	add_to_group("player")
	print("Player added to 'player' group")

	animated_sprite = $AnimatedSprite2D
	attack_area = $AttackArea

	if animated_sprite == null:
		print("Warning: AnimatedSprite2D not found!")

	hearts_ui = get_node("/root/world-1/UI/HeartsUI")
	if hearts_ui == null:
		print("Warning: HeartsUI not found!")
	else:
		print("HeartsUI found successfully")

	game_over_screen = get_node("/root/world-1/GameOver")
	if game_over_screen == null:
		print("Warning: Game Over screen not found!")
	else:
		print("Game Over screen found successfully")

	update_hearts_ui()

	# Criar e configurar o Timer para ataque
	attack_timer = Timer.new()
	attack_timer.wait_time = 0.6  # Ajuste para a duração da animação de ataque
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	add_child(attack_timer)

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
		print("Tecla pressionada!")
		soltar_poder()
		if animated_sprite and not animated_sprite.is_playing():
			animated_sprite.play("attack")

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
	print("Player died!")
	velocity = Vector2.ZERO

	if game_over_screen != null:
		if game_over_screen.has_method("show_game_over"):
			game_over_screen.show_game_over()
		else:
			print("Error: Game Over screen doesn't have show_game_over method!")

func update_hearts_ui() -> void:
	if hearts_ui != null and hearts_ui.has_method("update_hearts"):
		hearts_ui.update_hearts(current_hearts)

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
	poder.position = position + Vector2(10 * sign(animated_sprite.scale.x), -10)

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
