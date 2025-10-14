extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ti_lab.tscn")
	pass # Replace with function body.


func _on_info_pressed() -> void:
	$Popup.show()
	pass # Replace with function body.


func _on_popup_close() -> void:
	$Popup.hide()
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
