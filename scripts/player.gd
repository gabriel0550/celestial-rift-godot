extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
@export var poder_scene: PackedScene  # Cena do poder exportável
var has_power_stone = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	
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
	# Teste se a tecla está sendo reconhecida
   
	move_and_slide()

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
	poder.direction = sign(scale.x)

	print("Poder criado na posição:", poder.position)

# Função chamada pela Pedra do Poder
func collect_power_stone():
	has_power_stone = true
	print("Pedra do poder coletada!")
