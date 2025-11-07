extends Node2D

@onready var scene_transition = $SceneTransitionAnimation/AnimationPlayer

var angle: float = 0.0
var arduino_timer : Timer
var switch = false
var target

func _ready() -> void:
	$ButtonHintLab.visible = false
	$ButtonHintOutside.visible = false

	scene_transition.play("fade_out")

	arduino_timer = Timer.new()
	arduino_timer.autostart = true
	arduino_timer.wait_time = 0.5
	arduino_timer.connect("timeout", Callable(self, "process_serial"))
	self.add_child(arduino_timer)
	

# https://docs.godotengine.org/en/stable/tutorials/math/vector_math.html Wiskunde!
func process_serial():
	if !$player/Arduino.serial.is_open():
		print("Serial not ready!")
		return
	
	angle = -(($CompassTarget.position).angle_to_point($player.position)+PI/2)
	
	$player/Arduino.update_compass(true, angle)

func _process(delta: float) -> void:
	if switch && Input.is_action_just_pressed("e"):
		#var target = load("res://scenes/ti_lab.gd")
		$SceneTransitionAnimation.change_scene(target)

func _on_door_body_entered_tilab(body: Node2D) -> void:
	$ButtonHintLab.visible = true
	if body is Player:
		global.transition_scene = true
		switch = true
		target = load("res://scenes/ti_lab.tscn")
	pass # Replace with function body.
	
func _on_door_body_entered_outside(body: Node2D) -> void:
	$ButtonHintOutside.visible = true
	if body is Player:
		global.transition_scene = true
		switch = true
		target = load("res://scenes/outdoor.tscn")
	pass # Replace with function body.
	
func _on_door_body_exited(body: Node2D) -> void:
	$ButtonHintLab.visible = false
	$ButtonHintOutside.visible = false
	if body is Player:
		switch = false
	pass # Replace with function body.
