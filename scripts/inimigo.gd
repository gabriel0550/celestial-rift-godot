extends CharacterBody2D


const SPEED = 0.0
@onready var ray: RayCast2D = $Ray

@onready var animation: AnimationPlayer = $AnimationPlayer

@export var direction := -10

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta




	if direction:
		velocity.x = direction * SPEED * delta

	move_and_slide()
