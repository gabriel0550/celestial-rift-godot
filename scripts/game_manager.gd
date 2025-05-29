extends Node

var game_over_scene_resource = preload("res://scenes/GameOver.tscn")
var game_over_instance = null

func _ready():
	print("GameManager ready")

func show_game_over():
	# First try to find existing GameOver in the current world scene
	var existing_game_over = find_game_over_in_world()
	
	if existing_game_over:
		game_over_instance = existing_game_over
		print("Using existing GameOver UI in world scene")
	elif not game_over_instance:
		# If not found and not already created, create a new instance
		game_over_instance = game_over_scene_resource.instantiate()
		add_child(game_over_instance)
		print("GameOver UI created by GameManager")
	
	if game_over_instance.has_method("show_game_over"):
		game_over_instance.show_game_over()
		print("Game over animation started")
	else:
		print("Error: Game over method not found")

func find_game_over_in_world():
	# First check if we're in world_1
	var world = get_tree().current_scene
	
	# Try to find UI canvas layer
	var ui_layer = null
	if world.has_node("UI"):
		ui_layer = world.get_node("UI")
		
		# Check if UI has GameOver
		if ui_layer.has_node("GameOver"):
			return ui_layer.get_node("GameOver")
	
	return null

func clean_up():
	if game_over_instance:
		game_over_instance.queue_free()
		game_over_instance = null
