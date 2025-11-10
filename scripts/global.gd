extends Node

#@onready var scene_transition = $SceneTransitionAnimation/AnimationPlayer

var arduino_port: String = "/dev/ttyUSB0"

var current_scene = "ti_lab"
var transition_destination = ""

var transition_scene = false

var player_exit_closet_posz = 0
var player_exit_closet_posx = 0
var player_start_closet_posz = 0
var player_start_closet_posx = 0


#func _process(_delta):
	#change_scene()
	

		
