extends Node

# Store reference to the GameOver instance
var game_over_instance = null

func _ready():
	# Wait a frame to ensure scene is fully loaded
	await get_tree().process_frame
	
	# Find the UI layer in the scene
	var ui_layer = find_ui_layer()
	if ui_layer:
		# Check if GameOver already exists
		if not ui_layer.has_node("GameOver"):
			# Create the GameOver instance
			var game_over_scene = load("res://scenes/GameOver.tscn")
			if game_over_scene:
				game_over_instance = game_over_scene.instantiate()
				game_over_instance.visible = false  # Ensure it starts hidden
				ui_layer.add_child(game_over_instance)
				print("GameOver UI added to scene and hidden")
			else:
				print("Failed to load GameOver scene")
		else:
			# Make sure existing GameOver is hidden
			game_over_instance = ui_layer.get_node("GameOver")
			if game_over_instance:
				game_over_instance.visible = false
				print("Existing GameOver UI found and hidden")
			else:
				print("Error: Referenced GameOver is null")
	else:
		print("UI layer not found in scene")
	
	# Monitor for player death
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Monitor player's death state
		print("Found player, will monitor death state")
	else:
		print("Player not found, GameOver UI may not trigger properly")

func find_ui_layer() -> Node:
	# Try to find UI in the current scene
	var current_scene = get_tree().current_scene
	
	# Check if we're in world-1
	if current_scene.name == "world-1" and current_scene.has_node("UI"):
		return current_scene.get_node("UI")
	
	# Check for other worlds
	if current_scene.has_node("UI"):
		return current_scene.get_node("UI")
	
	# Create UI layer if it doesn't exist
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UI"
	current_scene.add_child(ui_layer)
	print("Created new UI layer")
	return ui_layer
