extends Control

@onready var arduino = $Arduino
@onready var circle = $Panel/Line2D

var old_value = 0

func _ready():
	arduino.calibrate_knob()
	set_process(true)

func _process(delta: float) -> void:
	var new_value = arduino.get_knob_relative_value()
	if new_value != old_value:
		var diff = new_value - old_value
		print(diff)
		var direction = circle.Direction.CLOCKWISE if diff > 0 else circle.Direction.COUNTERCLOCKWISE
		print(direction)
		for i in range(abs(diff)):
			circle.shift_knob(direction)
	old_value = new_value
