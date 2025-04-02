
extends Area2D

@onready var particulas = $GPUParticles2D
@onready var som = $AudioStreamPlayer2D

func _ready():
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
    if body.name == "Player":
        body.collect_power_stone()
        particulas.emitting = true
        som.play()
        await get_tree().create_timer(0.4).timeout
        queue_free()
