extends Node2D

var switch = false
func _ready():
	$ButtonHint.visible = false

#func _process(_delta):
	#change_scene()

func _enter_tree() -> void:
	if !global.transition_scene:
		$player.dead_on_ground()
		$player/OpeningCutscene.play(get_tree().create_timer(2.0))

func transitionToHallway(body):
	if body is Player && Input.is_action_just_pressed("e"):
			var target = load("res://scenes/hallway.tscn")
			$SceneTransitionAnimation.change_scene(target)
		#if body.has_method("player"):
			#$ButtonHint.visible = true
			#global.transition_scene = true
			#global.transition_destination = "hallway"

func onDoorTransitionPointExit(body) :
	if body.has_method("player"):
		$ButtonHint.visible = false
		global.transition_scene = false

#func change_scene():
	#if global.transition_scene == true && Input.is_action_just_pressed("e"):
		#scene_transition.play("fade_in")
		#await get_tree().create_timer(0.5).timeout
#
		#match global.transition_destination:
			#"hallway":
				#get_tree().change_scene_to_file("res://scenes/hallway.tscn")
				#
			#"ti_lab":
				#get_tree().change_scene_to_file("res://scenes/ti_lab.tscn")
		#global.transition_scene = false
		#

func _process(delta: float) -> void:
	if switch && Input.is_action_just_pressed("e"):
		var target = load("res://scenes/hallway.tscn")
		$SceneTransitionAnimation.change_scene(target)

func _on_door_body_entered(body: Node2D) -> void:
	$ButtonHint.visible = true
	if body is Player:
		global.transition_scene = true
		switch = true
	pass # Replace with function body.
	
func _on_door_body_exited(body: Node2D) -> void:
	$ButtonHint.visible = false
	if body is Player:
		switch = false
	pass # Replace with function body.
