extends CharacterBody2D

@export var speed: float = 100.0
@export var patrol_distance: float = 150.0
@export var pause_time: float = 1.0

var direction: int = 1
var start_position: Vector2
var is_paused: bool = false
var is_chasing: bool = false
var is_dead: bool = false

var player: Node2D = null

func _ready():
	start_position = global_position
	$VisionArea.body_entered.connect(_on_body_entered)
	$VisionArea.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if is_dead:
		return

	if is_chasing and player:
		perseguir_jogador(delta)
	elif not is_paused:
		patrulhar(delta)

func patrulhar(delta):
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	velocity.x = speed * direction
	move_and_slide()

	if abs(global_position.x - start_position.x) >= patrol_distance or is_on_wall():
		pausar_patrulha()
		direction *= -1

	atualizar_animacao()

func pausar_patrulha():
	is_paused = true
	velocity.x = 0
	$AnimatedSprite2D.play("idle")
	await get_tree().create_timer(pause_time).timeout
	is_paused = false

func perseguir_jogador(delta):
	var to_player = player.global_position - global_position
	if to_player.length() > 10:
		direction = sign(to_player.x)
		velocity.x = speed * direction
	else:
		velocity.x = 0

	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	move_and_slide()

	atualizar_animacao()

func atualizar_animacao():
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = direction < 0
		if velocity.x == 0:
			$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("walk")  # Correção: toca sempre que está andando

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		is_chasing = true

func _on_body_exited(body):
	if body == player:
		player = null
		is_chasing = false

func take_damage():
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	print("Inimigo morreu!")

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished

	queue_free()
