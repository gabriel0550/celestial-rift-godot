extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("collect_power_stone"):
		body.collect_power_stone()
		queue_free()
