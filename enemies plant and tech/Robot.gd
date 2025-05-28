extends CharacterBody2D

@export var speed: float = 100.0
@export var patrol_distance: float = 150.0

var direction: int = 1
var start_position: Vector2

func _ready():
	start_position = global_position

func _physics_process(delta):
	# Aplica gravidade
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	# Movimento horizontal de patrulha
	velocity.x = speed * direction
	move_and_slide()

	# Inverte direção se alcançar a borda da patrulha OU bater em uma parede
	if abs(global_position.x - start_position.x) >= patrol_distance or is_on_wall():
		direction *= -1

	# Atualiza animação e flip do sprite
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = direction < 0
		if not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("walk")
