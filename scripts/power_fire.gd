extends Sprite2D

@export var speed: float = 300.0  
@export var direction: int = 1  
@export var sprite_texture: Texture  # Permite escolher a textura no editor

func _ready() -> void:
	# Se tiver uma textura configurada, define no Sprite2D
	if get_parent() != null:  # Se já existir na cena, remove
		print("Poder inicializado sem parent.")
	if sprite_texture:
		texture = sprite_texture
		
	else:
		print("Aqui foi") # Acessa o Sprite2D dentro do Poder

func _process(delta: float) -> void:
	# Movimento do poder
	position.x += speed * direction * delta

	# Se sair da tela, destrói o poder para evitar consumo de memória
	if position.x > get_viewport_rect().size.x or position.x < 0:
		queue_free()
