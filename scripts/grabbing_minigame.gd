extends Control

signal solve_minigame

@export var claw: CharacterBody2D
@export var robot: CharacterBody2D
@export var cable: Line2D
@export var arduino: Node


const SPEED = 5
var grappled: bool = false
var cable_end: Vector2


func _ready():
	cable_end = cable.global_position

func handle_input():
	# The Arduino buttons are mapped wrong. Select=up, left=down
	if (Input.is_action_pressed("ui_right")) && !grappled:
		claw.position.x += SPEED
	elif (Input.is_action_pressed("ui_left")) && !grappled:
		claw.position.x -= 5
	elif (Input.is_action_pressed("ui_down") or arduino.controller.get("left")) && !grappled:
		claw.position.y += SPEED
	elif (Input.is_action_pressed("ui_up") or arduino.controller.get("select")):
		claw.position.y -= SPEED


func _move_cable(cable: Line2D):
	cable.set_point_position(0, Vector2(claw.global_position.x, 0))
	cable.set_point_position(1, claw.get_node("CableStart").global_position)


func _process(delta: float) -> void:
	_move_cable(cable)
	if grappled:
		robot.position = claw.position
		if robot.position.y <= 10:
			print("a")
			# Done!
			solve_minigame.emit()
			get_tree().change_scene_to_file("res://scenes/outdoor.tscn")
	handle_input()



func _on_robot_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	grappled = true
