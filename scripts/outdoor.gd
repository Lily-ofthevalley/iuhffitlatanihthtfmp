extends Node2D

var switch = false
var target

func _on_minigame_trigger_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		get_tree().change_scene_to_file("res://scenes/grabbing_minigame.tscn")

func _process(delta: float) -> void:
	if switch && Input.is_action_just_pressed("e"):
		#var target = load("res://scenes/hallway.tscn")
		$SceneTransitionAnimation.change_scene(target)

func _on_door_body_entered(body: Node2D) -> void:
	$ButtonHint.visible = true
	if body is Player:
		global.transition_scene = true
		switch = true
		target = load("res://scenes/hallway.tscn")

	pass # Replace with function body.
	
func _on_door_body_exited(body: Node2D) -> void:
	$ButtonHint.visible = false
	if body is Player:
		switch = false
	pass # Replace with function body.
