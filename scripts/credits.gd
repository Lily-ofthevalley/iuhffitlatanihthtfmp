extends Control

signal animation_finished

@onready var text_length = $Contents.get_content_height()
@export var scroll_duration_seconds: float = 30.0

func _ready() -> void:
	var scroll_animation: Animation = $AnimationPlayer.get_animation("scroll")
	var last_key = scroll_animation.track_get_key_count(0) - 1
	# We willen dat de credits naar boven scrollen, en stoppen precies wanneer de content voorbij is, plus de hoogte van de viewport.
	var target_position = Vector2($Contents.position.x, $Contents.position.y - text_length - get_viewport().get_visible_rect().size.y)
	scroll_animation.track_set_key_value(0, last_key, target_position)
	scroll_animation.track_set_key_time(0, last_key, scroll_duration_seconds)
	
	$AnimationPlayer.play("scroll")


func _on_animation_player_animation_finished() -> void:
	animation_finished.emit()
