extends Area2D

@export var speed: float = 300.0  
@export var direction: Vector2 = Vector2(1, 0)  
@export var sprite_texture: Texture  # Permite escolher a textura no editor
@export var is_enemy_power: bool = false  # Indica se é um poder do inimigo

func _ready() -> void:
	# Se tiver uma textura configurada, define no Sprite2D
	if sprite_texture:
		$Sprite2D.texture = sprite_texture
		
	# Conecta o sinal de área entrou
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Movimento do poder
	position += direction * speed * delta

	# Se sair do mapa, destrói o poder para evitar consumo de memória
	# Substitua os valores abaixo pelo tamanho real do seu mapa, se necessário
	var map_width = 5000
	var map_height = 600
	if position.x > map_width or position.x < 0 or \
	   position.y > map_height or position.y < 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_enemy_power:
		# Se for poder do inimigo, verifica se atingiu o jogador
		if body.is_in_group("player"):
			body.take_damage()
			queue_free()
	else:
		# Se for poder do jogador, verifica se atingiu um inimigo
		if body.is_in_group("enemy"):
			body.take_damage()
			queue_free()
