extends Area2D

@export var damage_amount: int = 1
var can_damage: bool = true
var damage_cooldown: Timer = null

func _ready() -> void:
	# Conecta o sinal body_entered
	body_entered.connect(_on_body_entered)
	
	# Define máscara de colisão para detectar somente o jogador (layer 1)
	collision_layer = 0
	collision_mask = 1
	
	# Verifica se há CollisionShape2D
	var has_collision_shapes := false
	for child in get_children():
		if child is CollisionShape2D:
			has_collision_shapes = true
			break
	if not has_collision_shapes:
		print("⚠️ WARNING: Area2D precisa de CollisionShape2D como filho direto!")
	else:
		print("✅ CollisionShape2D detectado")

	# Tenta acessar o Timer chamado "DamageCooldown"
	damage_cooldown = get_node_or_null("DamageCooldown")
	if damage_cooldown:
		print("✅ DamageCooldown encontrado")
		if not damage_cooldown.timeout.is_connected(_on_damage_cooldown_timeout):
			damage_cooldown.timeout.connect(_on_damage_cooldown_timeout)
			print("🔁 Sinal timeout do timer conectado")
	else:
		print("⚠️ WARNING: Timer 'DamageCooldown' não encontrado como filho!")

func _on_body_entered(body: Node2D) -> void:
	print("🔍 Body entrou na armadilha: ", body.name)
	
	# Aplica dano se for o jogador e estiver liberado
	if body.is_in_group("player") and can_damage:
		print("✅ Jogador detectado e pode receber dano")
		if body.has_method("take_damage"):
			body.take_damage()
			can_damage = false
			print("💥 Dano aplicado! Iniciando cooldown...")
			if damage_cooldown:
				damage_cooldown.start()
				print("🕒 Timer iniciado")
			else:
				print("⚠️ Timer de cooldown não existe, dano infinito possível!")
		else:
			print("❌ 'take_damage' não encontrado no corpo!")
	else:
		print("⛔ Corpo não é jogador ou ainda está no cooldown (can_damage = ", can_damage, ")")

func _on_damage_cooldown_timeout() -> void:
	can_damage = true
	print("✅ Cooldown encerrado, pode causar dano novamente")
