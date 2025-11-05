extends Node2D

func _process(_delta):
	change_scene()

func onClosetTransitionPointEntry(body) :
	if body.has_method("player") :
		global.transition_scene = true

func onClosetTransitionPointExit(body) :
	if body.has_method("player") :
		global.transition_scene = false

func change_scene():
	if global.transition_scene == true:
		if global.current_scene == "ti_lab":
			get_tree().change_scene_to_file("res://scenes/testworld.tscn")
			global.finish_changescenes()
		else:
			get_tree().change_scene_to_file("res://scenes/ti_lab.tscn")
			global.finish_changescenes()
