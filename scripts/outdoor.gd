extends Node2D


func _on_minigame_trigger_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		get_tree().change_scene_to_file("res://scenes/grabbing_minigame.tscn")
