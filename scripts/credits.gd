extends Control

signal animation_finished

@onready var text_length = $Contents.get_content_height()
@onready var player = $AnimationPlayer
@export var scroll_duration_seconds: float = 60.0

func sum(accum, number):
	return accum + number

func _process(_delta: float):
	# Inspired by Minecraft's credit screen
	var scroll_multiplier: float = [
		Input.is_key_pressed(KEY_SPACE),
		Input.is_key_pressed(KEY_SHIFT),
		Input.is_key_pressed(KEY_CTRL),
		Input.is_key_pressed(KEY_ENTER),
		Input.is_key_pressed(KEY_ALT),
		]\
		.map(func(pressed: bool): return 1.0 if pressed else 0.0)\
		.reduce(sum, 0.0) + 1.0
	
	player.speed_scale = scroll_multiplier

func _ready() -> void:
	var scroll_animation: Animation = player.get_animation("scroll")
	var last_key = scroll_animation.track_get_key_count(0) - 1
	
	# We willen dat de credits naar boven scrollen, en stoppen precies wanneer de content voorbij is, plus de hoogte van de viewport.
	var target_position = Vector2($Contents.position.x, $Contents.position.y - text_length - get_viewport().get_visible_rect().size.y)
	scroll_animation.track_set_key_value(0, last_key, target_position)
	
	scroll_animation.length = scroll_duration_seconds
	scroll_animation.track_set_key_time(0, last_key, scroll_duration_seconds)
	
	player.play("scroll")


func _on_animation_player_animation_finished() -> void:
	animation_finished.emit()
