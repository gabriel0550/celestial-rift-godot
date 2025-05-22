extends CharacterBody2D

const SPEED = 50.0
const FOLLOW_RANGE = 100
const WALK_DISTANCE = 10.0
const ATTACK_COOLDOWN = 1.0
const DAMAGE_COOLDOWN = 2.0

@export var speed: float = 300.0
var direction: Vector2 = Vector2(1, 0)
var is_enemy_power: bool = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $Animation
@onready var attack_area = $AttackArea

var player: Node2D
var is_attacking = false
var attack_timer = 0.0
var damage_timer = 0.0
var walk_direction = 1
var walk_distance = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_following = false
var can_attack = true
var initial_y_position = 0.0

func _ready():
	player = get_node("/root/world-1/player")
	if player == null:
		print("Warning: Player not found!")
	add_to_group("enemy")
	
	initial_y_position = position.y
	animated_sprite.play("default")
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if player == null:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if damage_timer > 0:
		damage_timer -= delta

	var distance_to_player = position.distance_to(player.position)
	is_following = distance_to_player <= FOLLOW_RANGE

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			can_attack = true
		velocity.y = 0
	else:
		if is_following:
			if distance_to_player > 10.0:
				var dir = (player.position - position).normalized()
				velocity.x = dir.x * SPEED
			else:
				velocity.x = 0
			animated_sprite.flip_h = velocity.x < 0
		else:
			walk_distance += SPEED * delta * walk_direction
			if abs(walk_distance) >= WALK_DISTANCE:
				walk_direction *= -1
				animated_sprite.flip_h = walk_direction > 0
			velocity.x = SPEED * walk_direction

		if is_on_floor():
			initial_y_position = position.y

		if not is_attacking and animated_sprite.animation != "default" and not animated_sprite.is_playing():
			animated_sprite.play("default")

	self.velocity = velocity
	move_and_slide()

func set_direction(dir: Vector2) -> void:
	direction = dir

func set_is_enemy_power(value: bool) -> void:
	is_enemy_power = value



func take_damage():
	print("Inimigo tomou dano!")
	queue_free()

func _attack():
	print("Enemy attacking")
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	can_attack = false
	velocity.x = 0
	velocity.y = 0
	initial_y_position = position.y
	animated_sprite.play("attack")

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and not is_attacking and can_attack:
		if body.has_method("take_damage") and damage_timer <= 0:
			body.take_damage()
			damage_timer = DAMAGE_COOLDOWN
			_attack()


func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		is_attacking = false
		can_attack = true

func _on_animation_finished(anim_name):
	if animated_sprite.animation == "attack":
		animated_sprite.play("default")
