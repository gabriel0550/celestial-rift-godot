extends Node

func _ready():
	print("GameOver Debug Script running")
	check_game_over_nodes()
	
	# Wait a bit to let everything initialize
	await get_tree().create_timer(1.0).timeout
	check_game_over_nodes_again()

func check_game_over_nodes():
	print("Checking GameOver nodes...")
	var current_scene = get_tree().current_scene
	print("Current scene: " + current_scene.name)
	
	if current_scene.has_node("UI"):
		var ui = current_scene.get_node("UI")
		print("UI node found")
		
		if ui.has_node("GameOver"):
			var game_over = ui.get_node("GameOver")
			print("GameOver node found")
			print("Is visible: " + str(game_over.visible))
			print("Has script: " + str(game_over.get_script() != null))
			if game_over.get_script():
				print("Script path: " + game_over.get_script().resource_path)
		else:
			print("GameOver node not found in UI")
	else:
		print("UI node not found in current scene")

func check_game_over_nodes_again():
	print("Checking GameOver nodes again...")
	var current_scene = get_tree().current_scene
	
	if current_scene.has_node("UI") and current_scene.get_node("UI").has_node("GameOver"):
		var game_over = current_scene.get_node("UI").get_node("GameOver")
		print("GameOver node still exists")
		print("Has show_game_over method: " + str(game_over.has_method("show_game_over")))
		
		# Try manually showing the game over screen
		if game_over.has_method("show_game_over"):
			print("GameOver has show_game_over method")
		else:
			print("GameOver is missing show_game_over method!")
	
	# Also check for autoloads
	if get_node_or_null("/root/GameOverManager") != null:
		print("GameOverManager autoload is present")
	else:
		print("GameOverManager autoload not found")
		
	if get_node_or_null("/root/GameManager") != null:
		print("GameManager autoload is present")
	else:
		print("GameManager autoload not found")
