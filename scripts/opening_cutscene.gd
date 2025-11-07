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
	current_dialogue_id = -1
	$MarginContainer/Panel/Text.visible_characters = 0
	tween = create_tween()
	
	next_script()
	
	#set_dialogue(dialogue[0])
	#
	#$MarginContainer/Panel/Text.visible_characters = 0
	#dialogue_size = $MarginContainer/Panel/Text.get_total_character_count()
	#
	#tween = create_tween()
	#tween.tween_property($MarginContainer/Panel/Text, "visible_characters", dialogue_size, dialogue_size / letters_per_second)
	#
	#await timer.timeout
	#
	#set_dialogue(dialogue[1])
	
	#await tween.finished
	#await get_tree().create_timer(2.0).timeout
	#
	#opening_cutscene_finish.emit()
	
	

func close():
	$MarginContainer.visible = false
	

func load_dialogue() -> Array:
	var file = FileAccess.open("res://dialogue/opening_cutscene.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func set_dialogue(dialogue: String):
	$MarginContainer/Panel/Text.text = dialogue
	
func next_script():
	if tween != null:
		tween.kill()
		
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$MarginContainer.visible = false
		
		await get_tree().create_timer(2.0).timeout
	
		opening_cutscene_finish.emit()
		return
	
	$MarginContainer/Panel/Text.text = dialogue[current_dialogue_id]["text"]
	
	$MarginContainer/Panel/Text.visible_characters = 0
	dialogue_size = $MarginContainer/Panel/Text.get_total_character_count()
	
	tween = create_tween()
	tween.tween_property($MarginContainer/Panel/Text, "visible_characters", dialogue_size, dialogue_size / letters_per_second)

func _input(event: InputEvent) -> void:
	if !d_active:
		return
	if event.is_action_pressed("ui_accept"):
		next_script()
