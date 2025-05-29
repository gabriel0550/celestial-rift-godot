extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var poder_scene: PackedScene
@export var max_hearts: int = 3

var current_hearts: int = max_hearts
var is_dead: bool = false
var has_power_stone = false
var can_attack := true
var can_fire_attack := true
var facing_right: bool = true
var is_flashing: bool = false
var flash_timer: float = 0.0

const FLASH_DURATION: float = 0.5
const FLASH_INTERVAL: float = 0.1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var fire_attack_cooldown := 1.0

var hearts_ui: Control = null
var game_over_screen: Control = null
var animated_sprite: AnimatedSprite2D
var attack_area: Area2D = null
var attack_timer: Timer = null
var fire_attack_timer: Timer = null

func _ready() -> void:
	add_to_group("player")
	animated_sprite = $AnimatedSprite2D
	attack_area = $AttackArea

	var current_scene = get_tree().current_scene
	var ui_node = current_scene.get_node_or_null("UI")

	if ui_node:
		hearts_ui = ui_node.get_node_or_null("HeartsUI")
		game_over_screen = ui_node.get_node_or_null("GameOver")

		if current_scene.name in ["world_2", "world_3"]:
			has_power_stone = true
			print(current_scene.name + " detectado - Pedra do poder ativada!")
	else:
		print("UI não encontrada na cena atual")

	update_hearts_ui()

	attack_timer = Timer.new()
	attack_timer.wait_time = 0.6
	attack_timer.one_shot = true
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	add_child(attack_timer)

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
	if direction != 0:
		facing_right = direction > 0
		animated_sprite.scale.x = 1 if facing_right else -1
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 6 * delta)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("ui_attack"):
		if can_fire_attack:
			soltar_poder()
			animated_sprite.play("attack")
			can_fire_attack = false
			fire_attack_timer.start()

	if Input.is_action_just_pressed("ui_sword_attack") and can_attack:
		atacar_com_espada()

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
			animated_sprite.modulate = Color(1, 1, 1)
		else:
			var flash_value = sin(flash_timer * PI / FLASH_INTERVAL) > 0
			animated_sprite.modulate = Color(2, 2, 2) if flash_value else Color(1, 1, 1)

func take_damage() -> void:
	if is_dead:
		return

	current_hearts -= 1
	update_hearts_ui()
	is_flashing = true
	flash_timer = 0.0

	if current_hearts <= 0:
		die()

func heal() -> void:
	if is_dead or current_hearts >= max_hearts:
		return

	current_hearts += 1
	update_hearts_ui()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO

	var current_scene = get_tree().current_scene

	if current_scene.name == "world_2":
		var go_ui = current_scene.get_node_or_null("UI/GameOver")
		if go_ui:
			go_ui.visible = true
			if go_ui.has_method("show_game_over"):
				go_ui.call("show_game_over")
			go_ui.process_mode = Node.PROCESS_MODE_ALWAYS
			return

	if current_scene.has_node("UI/GameOver"):
		var go_ui = current_scene.get_node("UI/GameOver")
		go_ui.visible = true
		if go_ui.has_method("show_game_over"):
			go_ui.call("show_game_over")
		return

	if get_node_or_null("/root/GameOverManager"):
		get_node("/root/GameOverManager").show_game_over()
		return

	if get_node_or_null("/root/GameManager"):
		get_node("/root/GameManager").show_game_over()
		return

	var game_over_ui = find_game_over_ui()
	if game_over_ui:
		game_over_screen = game_over_ui
		game_over_screen.visible = true
		if game_over_screen.has_method("show_game_over"):
			game_over_screen.call("show_game_over")
	else:
		var ui_layer = find_ui_layer()
		if ui_layer:
			var game_over_scene = load("res://scenes/GameOver.tscn")
			var instance = game_over_scene.instantiate()
			ui_layer.add_child(instance)
			instance.visible = true
			if instance.has_method("show_game_over"):
				instance.call("show_game_over")
		else:
			print("Erro: UI layer não encontrada")

func update_hearts_ui() -> void:
	if hearts_ui and hearts_ui.has_method("update_hearts"):
		hearts_ui.call("update_hearts", current_hearts)

func find_game_over_ui() -> Control:
	var scene = get_tree().current_scene
	if scene.has_node("UI/GameOver"):
		return scene.get_node("UI/GameOver")
	return null

func find_ui_layer() -> Node:
	var scene = get_tree().current_scene
	if scene.has_node("UI"):
		return scene.get_node("UI")

	print("Criando nova UI layer")
	var new_ui = CanvasLayer.new()
	new_ui.name = "UI"
	new_ui.layer = 10
	scene.add_child(new_ui)
	return new_ui

func soltar_poder() -> void:
	if not has_power_stone or not poder_scene:
		print("Poder não disponível")
		return

	var poder = poder_scene.instantiate()
	get_parent().add_child(poder)
	poder.position = position + Vector2(10 * sign(animated_sprite.scale.x), -40)

	if poder.has_method("set_direction"):
		poder.call("set_direction", Vector2(sign(animated_sprite.scale.x), 0))
	if poder.has_method("set_is_enemy_power"):
		poder.call("set_is_enemy_power", false)

func collect_power_stone() -> void:
	has_power_stone = true

func atacar_com_espada() -> void:
	if not can_attack:
		return

	can_attack = false
	animated_sprite.play("sword_attack")

	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.call("take_damage")

	attack_timer.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true
	animated_sprite.play("idle")

func _on_fire_attack_timer_timeout() -> void:
	can_fire_attack = true
