extends CharacterBody2D

const SPEED = 0.0
const ATTACK_COOLDOWN = 3.0  # Cooldown time in seconds
const ATTACK_DAMAGE = 1      # Damage per hit

@onready var animation: AnimationPlayer = $Animation
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

@export var direction := -10

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_attack = true
var attack_timer = 0.0
var is_attacking = false
var current_target = null

func _ready():
	# Connect the attack area signals
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	# Start with default animation
	animated_sprite.play("default")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle attack cooldown
	if not can_attack:
		attack_timer += delta
		if attack_timer >= ATTACK_COOLDOWN:
			can_attack = true
			attack_timer = 0.0

	# Handle movement
	if direction:
		velocity.x = direction * SPEED * delta

	move_and_slide()
