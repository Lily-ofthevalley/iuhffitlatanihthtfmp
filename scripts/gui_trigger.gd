extends Area2D

class_name GuiTrigger

@export var gui_target: Control
@export var trigger_area: CollisionShape2D

func _ready() -> void:
	trigger_area.connect("on_body_entered", _on_body_entered)
	trigger_area.connect("on_body_exited", _on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	# First check if the thingy entering the area is actually a player
	if body is Player:
		gui_target.find_child("Panel").show()
		gui_target.set_position($GuiPosition.global_position)
		pass


func _on_body_exited(body: Node2D) -> void:
	# First check if the thingy entering the area is actually a player
	if body is Player:
		gui_target.find_child("Panel").hide()
		pass
