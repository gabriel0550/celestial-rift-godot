extends Control

var health_bar: ColorRect
var max_health: float = 5.0
var current_health: float = 5.0
var visibility_timer: float = 0.0
const VISIBILITY_DURATION: float = 2.0  # How long the health bar stays visible after taking damage

func _ready():
	health_bar = $HealthBar
	hide()  # Hide the health bar initially

func _process(delta):
	if visibility_timer > 0:
		visibility_timer -= delta
		if visibility_timer <= 0:
			hide()

func update_health(current: float, maximum: float):
	current_health = current
	max_health = maximum
	
	# Update the health bar width
	var health_percentage = current_health / max_health
	health_bar.scale.x = health_percentage
	
	# Show the health bar and reset the visibility timer
	show()
	visibility_timer = VISIBILITY_DURATION 