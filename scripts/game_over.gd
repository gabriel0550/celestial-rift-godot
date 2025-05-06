extends Control

func _ready():
	# Make sure the Control node fills the entire viewport
	anchor_right = 1
	anchor_bottom = 1
	offset_right = 0
	offset_bottom = 0
	
	# Hide the Game Over screen when the game starts
	hide()
	
	# Set up the Game Over message to be centered
	var game_over_image = $GameOverImage
	if game_over_image:
		game_over_image.anchor_left = 0.5
		game_over_image.anchor_right = 0.5
		game_over_image.anchor_top = 0.5
		game_over_image.anchor_bottom = 0.5
		game_over_image.position = Vector2(0, -50)  # Slightly above center
	
	# Set up the Restart button
	var restart_button = $RestartButton
	if restart_button:
		restart_button.anchor_left = 0.5
		restart_button.anchor_right = 0.5
		restart_button.anchor_top = 0.5
		restart_button.anchor_bottom = 0.5
		restart_button.position = Vector2(0, 50)  # Slightly below center
		# Make sure the button is mouse filter is set to stop
		restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		# Connect the button signal
		if not restart_button.pressed.is_connected(_on_restart_button_pressed):
			restart_button.pressed.connect(_on_restart_button_pressed)

func show_game_over():
	# Make sure this control node is on top of other UI elements
	show()
	move_to_front()
	
	# Get the viewport size
	var viewport_size = get_viewport_rect().size
	
	# Center the Game Over screen
	position = Vector2.ZERO
	size = viewport_size
	
	# Center the Game Over image and Restart button
	var game_over_image = $GameOverImage
	if game_over_image:
		game_over_image.position = Vector2(viewport_size.x / 2, viewport_size.y / 2 - 50)
	
	var restart_button = $RestartButton
	if restart_button:
		restart_button.position = Vector2(viewport_size.x / 2, viewport_size.y / 2 + 50)

func _on_restart_button_pressed():
	print("Restart button pressed!")
	# Hide the Game Over screen
	hide()
	# Reload the current scene
	get_tree().reload_current_scene() 
