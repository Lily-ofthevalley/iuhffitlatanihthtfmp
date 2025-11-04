extends Node2D

func _ready():
	$ButtonHint.visible = false
	
func _process(_delta):
	change_scene()

func _enter_tree() -> void:
	if !global.transition_scene:
		$player.dead_on_ground()
		$player/OpeningCutscene.play(get_tree().create_timer(2.0))

func transitionToHallway(body) :
	if body.has_method("player") :
		$ButtonHint.visible = true
		global.transition_scene = true
		global.transition_destination = "hallway"

func onDoorTransitionPointExit(body) :
	if body.has_method("player") :
		$ButtonHint.visible = false
		global.transition_scene = false

func change_scene():
	if global.transition_scene == true && Input.is_action_just_pressed("e"):
		match global.transition_destination:
			"hallway":
				get_tree().change_scene_to_file("res://scenes/hallway.tscn")
				global.finish_changescenes()
				
			"ti_lab":
				get_tree().change_scene_to_file("res://scenes/ti_lab.tscn")
				global.finish_changescenes()
		#if global.current_scene == "ti_lab":
			#get_tree().change_scene_to_file("res://scenes/hallway.tscn")
			#global.finish_changescenes()
		#else:
			#get_tree().change_scene_to_file("res://scenes/ti_lab.tscn")
			#global.finish_changescenes()
