extends Control

signal restart_game

# Animação da imagem
var image_scale = Vector2(0.1, 0.1)
var target_scale = Vector2(1.0, 1.0)
var current_rotation = 0.0
var pulse_amount = 0.0
var button_appear_timer = 0.0
var button_appear_delay = 1.5
var show_button = false

# Partículas
var particles = []
var max_particles = 30
var particle_colors = [
	Color(1, 0, 0, 0.8),
	Color(0.8, 0.1, 0.1, 0.8),
	Color(1, 0.5, 0, 0.8),
	Color(0.8, 0, 0, 0.8)
]

func _ready():
	visible = false

	# Inicializa escala e opacidade
	if $GameOverImage:
		$GameOverImage.scale = image_scale

	if $RestartButton:
		$RestartButton.modulate.a = 0.0
		$RestartButton.visible = false

		# Conecta o botão se não estiver conectado
		if not $RestartButton.pressed.is_connected(_on_restart_button_pressed):
			$RestartButton.pressed.connect(_on_restart_button_pressed)

	# Gera partículas
	for i in max_particles:
		particles.append({
			"position": Vector2(randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y)),
			"velocity": Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(20, 50),
			"size": randf_range(3, 8),
			"color": particle_colors[randi() % particle_colors.size()],
			"rotation": randf_range(0, TAU)
		})

func _process(delta):
	if not visible:
		return

	if $GameOverImage:
		if image_scale.x < target_scale.x:
			image_scale = image_scale.lerp(target_scale, delta * 3.0)
			current_rotation = sin(Time.get_ticks_msec() / 100.0) * 0.05
			$GameOverImage.scale = image_scale
			$GameOverImage.rotation = current_rotation
		else:
			pulse_amount = sin(Time.get_ticks_msec() / 500.0) * 0.05
			$GameOverImage.scale = target_scale * (1.0 + pulse_amount)

	if not show_button:
		button_appear_timer += delta
		if button_appear_timer >= button_appear_delay:
			show_button = true
			$RestartButton.visible = true

	if show_button and $RestartButton.modulate.a < 1.0:
		$RestartButton.modulate.a += delta * 0.8
		$RestartButton.rotation = sin(Time.get_ticks_msec() / 300.0) * 0.1

	update_particles(delta)
	queue_redraw()

func _draw():
	if not visible:
		return
	for particle in particles:
		draw_circle(particle.position, particle.size, particle.color)

func update_particles(delta):
	for particle in particles:
		particle.position += particle.velocity * delta
		particle.rotation += delta * 2.0

		var size = get_viewport_rect().size
		if particle.position.x < 0:
			particle.position.x = size.x
		elif particle.position.x > size.x:
			particle.position.x = 0
		if particle.position.y < 0:
			particle.position.y = size.y
		elif particle.position.y > size.y:
			particle.position.y = 0

func show_game_over():
	visible = true
	image_scale = Vector2(0.1, 0.1)
	button_appear_timer = 0.0
	show_button = false

	if $GameOverImage:
		$GameOverImage.scale = image_scale
	if $RestartButton:
		$RestartButton.modulate.a = 0.0
		$RestartButton.visible = false

	print("Tela de Game Over ativada")

func _on_restart_button_pressed():
	print("Botão de reiniciar pressionado")
	emit_signal("restart_game")

	# Reinicia a cena atual de forma segura
	var current_scene_path = get_tree().current_scene.scene_file_path
	if current_scene_path != "":
		get_tree().change_scene_to_file(current_scene_path)
	else:
		print("Erro: caminho da cena atual não encontrado")
