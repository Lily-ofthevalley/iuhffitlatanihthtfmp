extends Control

@export var fact: String

func _ready() -> void:
	$Panel/FactContents.text = "Wist je dat:\n%s" % fact
