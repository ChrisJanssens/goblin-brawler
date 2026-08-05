extends Label

@export var player: GoblinPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Health: %d/%d" % [player.health, player.max_health]
