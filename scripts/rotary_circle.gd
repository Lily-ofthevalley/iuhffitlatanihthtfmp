@tool
extends Polygon2D

class_name Circle2D
# https://forum.godotengine.org/t/how-to-create-a-circle-with-line2d/37813
enum Direction{CLOCKWISE=0, COUNTERCLOCKWISE=1}

@export var knob_indicator: TextureRect
@export var knob_target: TextureRect

@export var cuts = 128:
	get:
		return cuts
	set(value):
		cuts = value
		
		update_points()

@export var STEP = cuts / 15
var knob_value = 0

func update_points():
	var pos_list: PackedVector2Array = PackedVector2Array()
	var correct_cuts = cuts + 3
	
	for cut in range(correct_cuts):
		var radian = (2 * PI / 360) * (360 / float(correct_cuts)) * (cut + 3) - PI/2
		var radian_pos = Vector2(snapped(cos(radian), 0.01), snapped(sin(radian), 0.01))
		pos_list.append(radian_pos)
	
	polygon = pos_list


func shift_knob(direction: Direction):
	match direction:
		Direction.CLOCKWISE:
			knob_value += 1
			knob_indicator.position = polygon[knob_value % cuts + STEP] * scale + position
		Direction.COUNTERCLOCKWISE:
			knob_value -= 1
			knob_indicator.position = polygon[knob_value % cuts + STEP] * scale + position

func _set_knob_indicator(new_position: Vector2):
	knob_indicator.position = new_position
	


func _ready() -> void:
	# Get random point, and instance the marker
	var random_pos = polygon[randi() % polygon.size()]
	knob_target.position = random_pos * scale + position
	knob_indicator.position = polygon[0]
	
	#
	#while true:
		#for i in range(40*200):
			#print(i % 40)
			#print(i)
			#await get_tree().create_timer(0.05).timeout
			#knob_value = i % 40
			#shift_knob(Direction.COUNTERCLOCKWISE)
