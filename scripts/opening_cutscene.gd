extends CanvasLayer

signal opening_cutscene_finish

var dialogue = []
var current_dialogue_id = 0
var d_active = false

var letters_per_second: float = 20
var dialogue_size: int = 0
var tween: Tween

func _ready() -> void:
	if !d_active:
		$MarginContainer.visible = false
	
	set_process(true)

func play(timer: SceneTreeTimer):
	if tween != null:
		tween.kill()
		
	d_active = true
	$MarginContainer.visible = true
	dialogue = load_dialogue()
	print(dialogue)
	
	set_dialogue(dialogue[0])
	
	$MarginContainer/Panel/Text.visible_characters = 0
	dialogue_size = $MarginContainer/Panel/Text.get_total_character_count()
	
	tween = create_tween()
	tween.tween_property($MarginContainer/Panel/Text, "visible_characters", dialogue_size, dialogue_size / letters_per_second)
	
	await timer.timeout
	
	set_dialogue(dialogue[1])
	
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	
	opening_cutscene_finish.emit()
	
	

func close():
	$MarginContainer.visible = false
	

func load_dialogue() -> Array:
	var file = FileAccess.open("res://dialogue/opening_cutscene.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func set_dialogue(dialogue: String):
	$MarginContainer/Panel/Text.text = dialogue
