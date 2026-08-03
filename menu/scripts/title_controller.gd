extends Node

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://world/tests/test_combat.tscn")
