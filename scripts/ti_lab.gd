extends Node2D

#func onTransitionPointEntry(body) :
	#if body.has_method("player") :
		#global.transition_scene = true
	#pass
