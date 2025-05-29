extends Node

# Game Over scene resource
var game_over_scene_resource = preload("res://scenes/GameOver.tscn")
var game_over_instance = null
var current_world = null

func _ready():
	print("GameOverManager ready")
	
	# Connect to scene change signals to detect world transitions
	get_tree().root.connect("ready", Callable(self, "_on_scene_ready"))

func _on_scene_ready():
	current_world = get_tree().current_scene
	print("Scene changed to: " + str(current_world.name if current_world else "unknown"))
	
	# Check if this is a world scene and ensure Game Over UI is properly set up
	if current_world and (current_world.name.begins_with("world") or current_world.name.begins_with("world_")):
		print("Detected world scene: " + current_world.name)
		setup_game_over_ui()

func setup_game_over_ui():
	# Find or create UI layer
	var ui_layer = find_or_create_ui_layer()
	
	if ui_layer:
		# Check if GameOver already exists in UI layer
		if ui_layer.has_node("GameOver"):
			game_over_instance = ui_layer.get_node("GameOver")
			game_over_instance.visible = false
			print("Using existing GameOver in " + current_world.name)
		else:
			# Create new GameOver instance
			game_over_instance = game_over_scene_resource.instantiate()
			game_over_instance.visible = false
			ui_layer.add_child(game_over_instance)
			print("Added GameOver UI to " + current_world.name)

func find_or_create_ui_layer():
	if not current_world:
		return null
		
	# Check if UI layer exists
	if current_world.has_node("UI"):
		return current_world.get_node("UI")
	
	# Create new UI layer
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UI"
	ui_layer.layer = 10  # Higher layer to ensure it's on top
	current_world.add_child(ui_layer)
	print("Created new UI layer in " + current_world.name)
	
	return ui_layer

func show_game_over():
	# Ensure we have the game over UI
	if not game_over_instance:
		setup_game_over_ui()
		
	# Show the game over UI
	if game_over_instance and game_over_instance.has_method("show_game_over"):
		game_over_instance.show_game_over()
		print("Game Over UI activated")
	else:
		print("Error: Game Over instance not available")
