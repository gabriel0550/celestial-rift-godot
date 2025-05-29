extends Node

func _ready():
	print("InitGameOver initializing...")
	fix_game_over()
	
func fix_game_over():
	await get_tree().process_frame  # Wait for scene to fully initialize
	
	var current_scene = get_tree().current_scene
	print("Fixing Game Over UI in scene: " + current_scene.name)
	
	# Try to find UI node
	if not current_scene.has_node("UI"):
		print("Creating UI node in " + current_scene.name)
		var ui = CanvasLayer.new()
		ui.name = "UI"
		ui.layer = 10
		current_scene.add_child(ui)
	
	var ui = current_scene.get_node("UI")
	
	# Check if GameOver exists
	if not ui.has_node("GameOver"):
		print("GameOver not found, creating new instance")
		var game_over_scene = load("res://scenes/GameOver.tscn")
		if game_over_scene:
			var game_over = game_over_scene.instantiate()
			ui.add_child(game_over)
		else:
			print("Error: Could not load GameOver scene")
			return
	
	var game_over = ui.get_node("GameOver")
	
	# Make sure GameOver is properly set up
	if game_over:
		# Check which script to apply based on world
		var script_path = "res://scripts/game_over.gd"
		if current_scene.name == "world_2":
			script_path = "res://scripts/world_2_game_over.gd"
			
		var script = load(script_path)
		if script:
			game_over.set_script(script)
			print("Applied " + script_path + " to GameOver")
		
		# Hide it initially
		game_over.visible = false
		
		# Connect restart button if it exists
		if game_over.has_node("RestartButton"):
			var restart_button = game_over.get_node("RestartButton")
			
			# Disconnect any existing connections
			if restart_button.is_connected("pressed", Callable(game_over, "_on_restart_button_pressed")):
				restart_button.disconnect("pressed", Callable(game_over, "_on_restart_button_pressed"))
			
			# Connect button
			restart_button.connect("pressed", Callable(game_over, "_on_restart_button_pressed"))
			print("RestartButton signal connected")
			
			# Verify button properties
			restart_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			restart_button.focus_mode = Control.FOCUS_ALL
			restart_button.disabled = false
		else:
			print("Error: RestartButton not found in GameOver")
			
		# Initialize UI
		if game_over.has_method("show_game_over"):
			game_over.show_game_over()
			game_over.visible = false
			
		print("Game Over UI fixed successfully in " + current_scene.name)