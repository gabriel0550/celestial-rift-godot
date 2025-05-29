extends Control

signal restart_game

# Animation properties
var image_scale = Vector2(0.1, 0.1)
var target_scale = Vector2(1.5, 1.5)  # Increased from 1.0 to 1.5 for larger final size
var current_rotation = 0.0
var pulse_amount = 0.0
var pulse_speed = 5.0
var button_appear_timer = 0.0
var button_appear_delay = 1.5 # seconds before button appears
var show_button = false

# Particles
var particles = []
var max_particles = 30
var particle_speed = 50.0
var particle_colors = [
	Color(1, 0, 0, 0.8),  # Red
	Color(0.8, 0.1, 0.1, 0.8),  # Dark red
	Color(1, 0.5, 0, 0.8),  # Orange
	Color(0.8, 0, 0, 0.8)   # Blood red
]

func _ready():
	# Always ensure we start hidden
	visible = false
	print("World 2 GameOver initialized and hidden")
	
	if has_node("GameOverImage"):
		$GameOverImage.scale = image_scale
	if has_node("RestartButton"):
		$RestartButton.modulate.a = 0.0
		$RestartButton.visible = false
		# Increase button size
		$RestartButton.add_theme_font_size_override("font_size", 48)  # Increased from 36
		# Make button area larger
		$RestartButton.custom_minimum_size = Vector2(220, 60)
	
	# Initialize particles
	for i in range(max_particles):
		particles.append({
			"position": Vector2(randf_range(0, get_viewport_rect().size.x), 
								randf_range(0, get_viewport_rect().size.y)),
			"velocity": Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(20, 50),
			"size": randf_range(3, 8),
			"color": particle_colors[randi() % particle_colors.size()],
			"rotation": randf_range(0, TAU)
		})

func _process(delta):
	if not visible:
		return
		
	# Skip processing if required nodes are missing
	if not has_node("GameOverImage") or not has_node("RestartButton"):
		return
			# Image animation
	if image_scale.x < target_scale.x:
		image_scale = image_scale.lerp(target_scale, delta * 3.0)
		current_rotation = sin(Time.get_ticks_msec() / 100.0) * 0.05
		$GameOverImage.scale = image_scale
		$GameOverImage.rotation = current_rotation
	else:
		# Pulsing effect once full size is reached
		pulse_amount = sin(Time.get_ticks_msec() / 500.0) * 0.05
		$GameOverImage.scale = target_scale * (1.0 + pulse_amount)
	
	# Button appearance timer
	if not show_button:
		button_appear_timer += delta
		if button_appear_timer >= button_appear_delay:
			show_button = true
			$RestartButton.visible = true
	
	# Button fade-in
	if show_button and $RestartButton.modulate.a < 1.0:
		$RestartButton.modulate.a += delta * 0.8
		# Apply a slight bounce effect to the button
		$RestartButton.rotation = sin(Time.get_ticks_msec() / 300.0) * 0.05
		# Ensure button stays large even during animation
		$RestartButton.scale = Vector2(1.0, 1.0) * (1.0 + sin(Time.get_ticks_msec() / 400.0) * 0.05)
	
	# Update particles
	update_particles(delta)
	
	# Force redraw for particles
	queue_redraw()

func _draw():
	if not visible:
		return
		
	# Draw particles
	for particle in particles:
		draw_circle(particle.position, particle.size, particle.color)

func update_particles(delta):
	for particle in particles:
		particle.position += particle.velocity * delta
		particle.rotation += delta * 2.0
		
		# Wrap particles around screen
		var viewport_size = get_viewport_rect().size
		if particle.position.x < 0:
			particle.position.x = viewport_size.x
		elif particle.position.x > viewport_size.x:
			particle.position.x = 0
		if particle.position.y < 0:
			particle.position.y = viewport_size.y
		elif particle.position.y > viewport_size.y:
			particle.position.y = 0

func show_game_over():
	print("show_game_over called in World 2")
	visible = true
	
	# Reset animation state
	image_scale = Vector2(0.1, 0.1)
	button_appear_timer = 0.0
	show_button = false
	
	# Make sure we have the required nodes before accessing them
	if has_node("GameOverImage"):
		$GameOverImage.scale = image_scale
		# Adjust GameOverImage size to be larger
		var rect_size = $GameOverImage.get_rect().size
		$GameOverImage.custom_minimum_size = Vector2(rect_size.x * 1.5, rect_size.y * 1.5)
	else:
		print("Error: GameOverImage node not found")
		
	if has_node("RestartButton"):
		$RestartButton.modulate.a = 0.0
		$RestartButton.visible = false
		# Increase button size
		$RestartButton.add_theme_font_size_override("font_size", 48)  # Increased from 36
		# Make button area larger
		$RestartButton.custom_minimum_size = Vector2(220, 60)
	else:
		print("Error: RestartButton node not found")
		
	print("World 2 Game Over UI activated and made visible")

func _on_restart_button_pressed():
	print("Restart button pressed in world_2!")
	emit_signal("restart_game")
	
	# Ensure we reload the current scene
	var current_scene_path = get_tree().current_scene.scene_file_path
	print("Reloading scene: " + current_scene_path)
	
	# Two methods to ensure scene reload works
	get_tree().reload_current_scene()
	
	# Alternative approach in case the first one fails
	if get_tree().paused:
		get_tree().paused = false
