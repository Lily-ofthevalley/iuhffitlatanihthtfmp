extends PathFollow2D

signal npc_reached_point(point_name)

var speed = 0.3
var walk_allowed = false
var signal_points = {
	"start": 0.0,
	"quarter": 0.66,
	"three_quarters": 0.75,
	"end": 1.0
}

var triggered_points = {}

func _ready():
	for point_name in signal_points:
		triggered_points[point_name] = false
	
func _process(delta):
	if walk_allowed:
		loop_movement(delta)
		check_signal_points()
		
func check_signal_points():
	for point_name in signal_points:
		var point_ratio = signal_points[point_name]
		
		if progress_ratio >= point_ratio and not triggered_points[point_name]:
			triggered_points[point_name] = true
			emit_signal("npc_reached_point", point_name)
	
func loop_movement(delta):
	progress_ratio += delta * speed

func _on_npc_start_dialogue_finished_yes() -> void:
	walk_allowed = true
