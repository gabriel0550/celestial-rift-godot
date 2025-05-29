extends Node

# This script will be loaded as an autoload singleton to ensure consistent Game Over UI behavior
# across all world scenes.

func _ready():
	print("GameOverInitializer ready")
	
	# Connect to tree changed signal to detect scene changes
	get_tree().connect("tree_changed", Callable(self, "_on_tree_changed"))
	
	# Initial check
	initialize_game_over_in_current_scene()

func _on_tree_changed():
	initialize_game_over_in_current_scene()

func initialize_game_over_in_current_scene():
	# Get current scene
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
		
	# Only process world scenes
	var scene_name = current_scene.name
	if not (scene_name == "world-1" or scene_name == "world_2" or scene_name == "world_3"):
		return
		
	print("Initializing GameOver in scene: " + scene_name)
	
	# Get UI layer
	var ui = null
	if current_scene.has_node("UI"):
		ui = current_scene.get_node("UI")
	else:
		# Create UI layer if needed
		ui = CanvasLayer.new()
		ui.name = "UI"
		current_scene.add_child(ui)
		print("Created new UI layer in " + scene_name)
	
	# Check if GameOver exists
	var game_over = null
	if ui.has_node("GameOver"):
		game_over = ui.get_node("GameOver")
		print("Found existing GameOver in " + scene_name)
		
		# Make sure it's hidden
		game_over.visible = false
	else:
		# Create GameOver if needed
		var game_over_scene = load("res://scenes/GameOver.tscn")
		if game_over_scene:
			game_over = game_over_scene.instantiate()
			ui.add_child(game_over)
			game_over.visible = false
			print("Created new GameOver in " + scene_name)
	
	# Apply the appropriate script based on world
	if game_over:
		var script_path = ""
		if scene_name == "world_2":
			script_path = "res://scripts/world_2_game_over.gd"
		else:
			script_path = "res://scripts/game_over.gd"
			
		var script = load(script_path)
		if script and (game_over.get_script() == null or game_over.get_script().resource_path != script_path):
			game_over.set_script(script)
			print("Applied " + script_path + " to GameOver")
