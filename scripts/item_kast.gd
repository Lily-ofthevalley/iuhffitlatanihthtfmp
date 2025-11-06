extends Node2D

var state = "has item"
var player_in_area = false

@export var item: InvItem
var player = null

func _ready():
	if state == "has item":
		pass
	
func _process(delta):
	if state == "has item":
		if player_in_area == true:
			if Input.is_action_just_pressed("e"):
				player.collect(item)
				#print("yello")

func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		player = body
		player_in_area = true

func _on_area_2d_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
