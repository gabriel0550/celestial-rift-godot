extends Control

@export var max_hearts: int = 3

func _ready() -> void:
	# Update hearts UI on start
	update_hearts(max_hearts)

# Function to update hearts visibility
func update_hearts(current_hearts: int) -> void:
	var hearts_container = $HeartsContainer
	if hearts_container:
		print("Updating hearts UI. Current hearts: ", current_hearts)
		for i in range(hearts_container.get_child_count()):
			var heart = hearts_container.get_child(i)
			heart.visible = i < current_hearts
			print("Heart ", i, " visibility: ", heart.visible)
	else:
		print("Warning: HeartsContainer not found!")
