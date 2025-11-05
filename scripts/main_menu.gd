extends Control

@onready var credits_scene = preload("res://scenes/credits.tscn")

func _ready():
	$Backgroud/Moving.play("move-loop")
	$Settings/Configs/ArduinoInput.text = global.arduino_port

func _on_start_pressed() -> void:
	var loading_screen = load("res://scenes/loading_screen.tscn")
	get_tree().change_scene_to_packed(loading_screen)


func _on_info_pressed() -> void:
	$Popup.show()


func _on_popup_close() -> void:
	$Popup.hide()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	$Settings.show()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scene)


func _on_settings_close_requested() -> void:
	$Settings.hide()


func _on_settings_save() -> void:
	var new_text = $Settings/Configs/ArduinoInput.text
	global.arduino_port = new_text
	$Settings.hide()
