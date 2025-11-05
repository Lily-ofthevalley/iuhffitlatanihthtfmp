extends Control

@onready var arduino = $Arduino
@onready var circle = $Panel/Circle

var old_value = 0

func _ready():
	arduino.calibrate_knob()
	_on_calibrate_button_pressed()
	set_process(true)

func _process(delta: float) -> void:
	var new_value = arduino.get_knob_relative_value()
	if new_value != old_value:
		var diff = new_value - old_value
		var direction = circle.Direction.CLOCKWISE if diff > 0 else circle.Direction.COUNTERCLOCKWISE
		for i in range(abs(diff)):
			circle.shift_knob(direction)
	old_value = new_value


func _on_calibrate_button_pressed() -> void:
	set_process(false)
	arduino.calibrate_knob()
	circle.reset()
	old_value = 0
	set_process(true)


func _on_circle_solve_minigame() -> void:
	# Switch back and reward player item and progress quest
	pass # Replace with function body.
