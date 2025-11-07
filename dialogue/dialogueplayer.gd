extends CanvasLayer
class_name DialogueText

signal start_dialogue_finished

@onready var text: RichTextLabel = $MarginContainer/Panel/Text

var dialogue = []
var current_dialogue_id = 0
var d_active = false
var letters_per_second: float = 20
var dialogue_size: int = 0
var tween: Tween

func _ready() -> void:
	$MarginContainer.visible = false
	
func start():
	d_active = true
	$MarginContainer.visible = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	text.visible_characters = 0
	tween = create_tween()
	
	next_script()
	
func load_dialogue():
	var file = FileAccess.open("res://dialogue/labperson_dialogue1.json", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event: InputEvent) -> void:
	if !d_active:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()
	
func next_script():
	if tween != null:
		tween.kill()
		
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$MarginContainer.visible = false
		emit_signal("dialogue_finished")
		start_dialogue_finished.emit()
		return
	
	$MarginContainer/Panel/Name.text = dialogue[current_dialogue_id]["name"]
	$MarginContainer/Panel/Text.text = dialogue[current_dialogue_id]["text"]
	
	text.visible_characters = 0
	dialogue_size = text.get_total_character_count()
	
	tween = create_tween()
	tween.tween_property(text, "visible_characters", dialogue_size, dialogue_size / letters_per_second)
