extends Control


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/world_1.tscn")


func _on_credits_bnt_pressed() -> void:
	pass # Replace with function body.


func _on_quit_btn_pressed():
		get_tree().quit()
