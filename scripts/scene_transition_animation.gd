extends Node2D

@onready var scene_transition = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func change_scene(target: PackedScene):
		scene_transition.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_packed(target)
