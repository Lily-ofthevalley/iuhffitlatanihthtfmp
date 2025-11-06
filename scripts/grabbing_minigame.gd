extends Control

signal solve_minigame

@export var claw: CharacterBody2D
@export var robot: CharacterBody2D
@export var cable: Line2D

const SPEED = 5
var grappled: bool = false
var cable_end: Vector2


func _ready():
	cable_end = cable.global_position

func handle_input():
	if Input.is_action_pressed("ui_right") && !grappled:
		claw.position.x += SPEED
		claw.velocity.y = 0
	elif Input.is_action_pressed("ui_left") && !grappled:
		claw.position.x -= 5
		claw.velocity.y = 0
	elif Input.is_action_pressed("ui_down") && !grappled:
		claw.position.y += SPEED
	elif Input.is_action_pressed("ui_up"):
		claw.position.y -= SPEED


func _move_cable(cable: Line2D):
	cable.set_point_position(0, Vector2(claw.global_position.x, 0))
	cable.set_point_position(1, claw.get_node("CableStart").global_position)


func _process(delta: float) -> void:
	_move_cable(cable)
	if grappled:
		robot.position = claw.position
		if robot.position.y <= 10:
			# Done!
			solve_minigame.emit()
			
	handle_input()



func _on_robot_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	grappled = true
