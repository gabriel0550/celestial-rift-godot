extends Control

func _ready():
	# Make sure the Control node fills the entire viewport
	anchor_right = 1
	anchor_bottom = 1
	
	# Hide the Game Over screen when the game starts
	hide()
	
	# Set up the Game Over message to be centered
	var game_over_image = $GameOverImage
	
	
	# Set up the Restart button
	var restart_button = $RestartButton
	if restart_button:
		# Position the button below the Game Over image
		# Make sure the button is mouse filter is set to stop
		restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		# Connect the button signal
		if not restart_button.pressed.is_connected(_on_restart_button_pressed):
			restart_button.pressed.connect(_on_restart_button_pressed)

func show_game_over():
	# Make sure this control node is on top of other UI elements
	show()
	move_to_front()

func _on_restart_button_pressed():
	print("Restart button pressed!")
	# Hide the Game Over screen
	hide()
	# Reload the current scene
	get_tree().reload_current_scene() 
