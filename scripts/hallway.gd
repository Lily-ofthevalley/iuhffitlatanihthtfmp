extends Node2D

@onready var scene_transition = $SceneTransitionAnimation/AnimationPlayer

var angle: float = 0.0
var arduino_timer : Timer

func _ready() -> void:
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

