@tool
extends Polygon2D

class_name Circle
# https://forum.godotengine.org/t/how-to-create-a-circle-with-line2d/37813
enum Direction{CLOCKWISE=0, COUNTERCLOCKWISE=1}

@export var knob_indicator: Line2D
@export var knob_target: TextureRect
@export var points = 15: # The amount of points the polygon circle should have.
	get:
		return points
	set(value):
		points = value

		update_points()

@export var STEP = points / 15 # 1 step = 2 steps on the rotary encoder
var knob_value = points + 3 # Should be the same as the relative value of the rotary encoder.

func update_points():
	var pos_list: PackedVector2Array = PackedVector2Array()
	var correct_cuts = points + 3

	for cut in range(correct_cuts):
		var radian = (2 * PI / 360) * (360 / float(correct_cuts)) * (cut + 3) - PI/2
		var radian_pos = Vector2(snapped(cos(radian), 0.01), snapped(sin(radian), 0.01))
		pos_list.append(radian_pos)

	polygon = pos_list


func shift_knob(direction: Direction):
	match direction:
		Direction.CLOCKWISE:
			knob_value += 1
			knob_indicator.position = polygon[knob_value % points + STEP] * scale + position
			_rotate_knob_indicator()
		Direction.COUNTERCLOCKWISE:
			knob_value -= 1
			knob_indicator.position = polygon[knob_value % points + STEP] * scale + position
			_rotate_knob_indicator()
	print(knob_value)
	


func _set_knob_indicator_relative_position(new_position: Vector2):
	knob_indicator.position = new_position * scale + position

func _rotate_knob_indicator():
		# Rotate the indicator so it is perpendicular to the circle
		var angle = (2 * PI / 360) * (360 / float(points + 3)) * (knob_value % points + STEP + 3) - PI/2 # Magic
		knob_indicator.rotation = angle
	
func reset():
	knob_value = -6
	_set_knob_indicator_relative_position(polygon[points/4 - 6])
	_rotate_knob_indicator()

func _ready() -> void:
	# Get random point, and put the marker there
	var random_pos = polygon[randi() % polygon.size()]
	knob_target.position = random_pos * scale + position
	# TODO: calibrate Arduino as well.
	reset()
	#while true:
		#for i in range(40*200):
			#print(i % 40)
			#print(i)
			#await get_tree().create_timer(0.05).timeout
			#knob_value = i % 40
			#shift_knob(Direction.COUNTERCLOCKWISE)
