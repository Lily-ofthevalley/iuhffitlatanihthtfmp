extends CharacterBody2D


const PLAYER_SPEED = 100.0
enum Direction {Left, Right, Up, Down}
var direction = Direction.Down

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float):
	if Input.is_action_pressed("ui_right"):
		direction = Direction.Right
		handle_movement_animation(direction)
		velocity.x = PLAYER_SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		direction = Direction.Left
		handle_movement_animation(direction)
		velocity.x = -PLAYER_SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		direction = Direction.Down
		handle_movement_animation(direction)
		velocity.x = 0
		velocity.y = PLAYER_SPEED
	elif Input.is_action_pressed("ui_up"):
		direction = Direction.Up
		handle_movement_animation(direction)
		velocity.x = 0
		velocity.y = -PLAYER_SPEED
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
