extends Node2D

@onready var scene_transition = $SceneTransitionAnimation/AnimationPlayer

func _ready() -> void:
	scene_transition.play("fade_out")
