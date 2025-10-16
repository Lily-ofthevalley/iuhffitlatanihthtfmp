extends CharacterBody2D

class_name Player

@export var inv: Inv
const PLAYER_SPEED = 100.0
enum Direction {Left, Right, Up, Down}
var direction = Direction.Down

func player():
	pass

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func get_speed() -> float:
	return (PLAYER_SPEED * 2 if Input.is_key_pressed(KEY_SHIFT) else PLAYER_SPEED)

func handle_movement(delta: float):
	if Input.is_action_pressed("ui_right"):
		direction = Direction.Right
		handle_movement_animation(direction)
		velocity.x = get_speed()
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		direction = Direction.Left
		handle_movement_animation(direction)
		velocity.x = -get_speed()
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		direction = Direction.Down
		handle_movement_animation(direction)
		velocity.x = 0
		velocity.y = get_speed()
	elif Input.is_action_pressed("ui_up"):
		direction = Direction.Up
		handle_movement_animation(direction)
		velocity.x = 0
		velocity.y = -get_speed()
	else:
		handle_movement_animation(direction, false)
		velocity = Vector2(0,0)
	
	move_and_slide()

func handle_movement_animation(direction: Direction, moving: bool = true):
	var anim = $AnimatedSprite2D
	
	match direction:
		Direction.Right:
			anim.flip_h = false
			if moving:
				anim.play("side_walk")
			else:
				anim.play("side_idle")
		Direction.Left:
			anim.flip_h = true
			if moving:
				anim.play("side_walk")
			else:
				anim.play("side_idle")
		Direction.Down:
			anim.flip_h = true
			if moving:
				anim.play("front_walk")
			else:
				anim.play("front_idle")
		Direction.Up:
			anim.flip_h = true
			if moving:
				anim.play("back_walk")
			else:
				anim.play("back_idle")

func collect(item):
	inv.insert(item)
	
