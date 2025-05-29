extends Node

func _ready():
	print("World 2 GameOver Fix running")
	fix_game_over()
	
func fix_game_over():
	await get_tree().process_frame  # Wait for scene to fully initialize
	
	var current_scene = get_tree().current_scene
	if current_scene.name != "world_2":
		print("Not in world_2, exiting fix")
		return
		
	print("Fixing GameOver in world_2...")
	
	# Check if UI exists
	if not current_scene.has_node("UI"):
		print("Error: UI node not found in world_2")
		return
		
	var ui = current_scene.get_node("UI")
		# Check if GameOver exists
	if not ui.has_node("GameOver"):
		print("Error: GameOver node not found in UI")
		return
		
	var game_over = ui.get_node("GameOver")
	
	# REPLACE GAMEOVER WITH WORLD_2 SPECIFIC VERSION
	# Remove the existing GameOver
	var old_game_over_pos = game_over.get_position()
	game_over.queue_free()
	
	# Load our World 2 specific GameOver
	var world2_game_over_scene = load("res://scenes/GameOver_world_2.tscn")
	if world2_game_over_scene:
		var new_game_over = world2_game_over_scene.instantiate()
		new_game_over.position = old_game_over_pos
		ui.add_child(new_game_over)
		game_over = new_game_over
		print("Replaced GameOver with World 2 specific version")
	else:
		print("Error: Could not load GameOver_world_2.tscn")
		return
	
	# Check if RestartButton exists
	if not game_over.has_node("RestartButton"):
		print("Error: RestartButton not found in GameOver")
		return
		
	var restart_button = game_over.get_node("RestartButton")
	
	# Apply our custom world_2 GameOver script
	var script = load("res://scripts/world_2_game_over.gd")
	if script:
		game_over.set_script(script)
		print("Custom world_2_game_over script applied")
	else:
		print("Error: Could not load world_2_game_over.gd script")
		
		# Fallback to standard game_over script
		script = load("res://scripts/game_over.gd")
		if script:
			game_over.set_script(script)
			print("Fallback to standard game_over script")
		# Make sure it's initially hidden
	game_over.visible = false
	
	# Connect signals - Make sure to disconnect any existing connections first to avoid duplicates
	var restart_button = game_over.get_node_or_null("RestartButton")
	if restart_button:
		# Adjust button size
		restart_button.add_theme_font_size_override("font_size", 48)  # Increased from 36
		restart_button.custom_minimum_size = Vector2(220, 60)
		
		# Adjust button position if needed
		var button_pos = restart_button.position
		restart_button.position = Vector2(button_pos.x, button_pos.y + 30)  # Move down slightly
		
		# Disconnect existing connections if any exist
		if restart_button.is_connected("pressed", Callable(game_over, "_on_restart_button_pressed")):
			restart_button.disconnect("pressed", Callable(game_over, "_on_restart_button_pressed"))
		
		# Connect the signal
		restart_button.connect("pressed", Callable(game_over, "_on_restart_button_pressed"))
		print("RestartButton signal reconnected successfully")
		
		# Debug info
		restart_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		print("Button is visible: " + str(restart_button.visible))
		print("Button is disabled: " + str(restart_button.disabled))
	
	# Check GameOverImage and resize it
	if game_over.has_node("GameOverImage"):
		var game_over_image = game_over.get_node("GameOverImage")
		# Make the image texture larger
		var current_rect = game_over_image.get_rect()
		game_over_image.custom_minimum_size = Vector2(current_rect.size.x * 1.2, current_rect.size.y * 1.2)
		print("Adjusted GameOverImage size")
	
	# Ensure the GameOver UI is properly initialized
	game_over.show_game_over()
	game_over.visible = false  # Hide it again after initialization
	
	print("GameOver in world_2 fixed successfully")
