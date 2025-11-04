extends Node

var current_scene = "ti_lab"
var transition_destination = ""

var transition_scene = false

var player_exit_closet_posz = 0
var player_exit_closet_posx = 0
var player_start_closet_posz = 0
var player_start_closet_posx = 0

func finish_changescenes():
	if transition_scene == true:
		transition_scene = false
	#if current_scene == "ti_lab":
		#current_scene = "hallway"
	#else :
		#current_scene = "ti_lab"
