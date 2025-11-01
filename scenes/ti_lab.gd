extends Node2D

@onready var scene_transition = $SceneTransitionAnimation/AnimationPlayer

func _process(_delta):
	change_scene()

func _enter_tree() -> void:
	if !global.transition_scene:
		$player.dead_on_ground()
		$player/OpeningCutscene.play(get_tree().create_timer(2.0))

func onClosetTransitionPointEntry(body) :
	if body.has_method("player"):
		global.transition_scene = true

func onClosetTransitionPointExit(body) :
	if body.has_method("player"):
		global.transition_scene = false

func change_scene():
	if global.transition_scene == true:
		scene_transition.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		if global.current_scene == "ti_lab":
			get_tree().change_scene_to_file("res://scenes/hallway.tscn")
			global.finish_changescenes()
		else:
			get_tree().change_scene_to_file("res://scenes/ti_lab.tscn")
			global.finish_changescenes()
