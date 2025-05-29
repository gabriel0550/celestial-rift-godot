extends Node

var game_over_scene_resource = preload("res://scenes/GameOver.tscn")
var game_over_instance = null

func _ready():
	print("GameManager ready")

func show_game_over():
	if not game_over_instance:
		game_over_instance = game_over_scene_resource.instantiate()
		add_child(game_over_instance)
		print("GameOver UI created by GameManager")
	
	if game_over_instance.has_method("show_game_over"):
		game_over_instance.show_game_over()
		print("Game over animation started")
	else:
		print("Error: Game over method not found")

func clean_up():
	if game_over_instance:
		game_over_instance.queue_free()
		game_over_instance = null
