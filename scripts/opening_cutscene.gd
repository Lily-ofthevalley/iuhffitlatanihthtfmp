extends CanvasLayer

signal opening_cutscene_finish

var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready() -> void:
	if !d_active:
		$MarginContainer.visible = false
	
	set_process(true)

func play(timer: SceneTreeTimer):
	d_active = true
	$MarginContainer.visible = true
	dialogue = load_dialogue()
	print(dialogue)
	
	set_dialogue(dialogue[0])
	await timer.timeout
	
	set_dialogue(dialogue[1])
	opening_cutscene_finish.emit()

func close():
	$MarginContainer.visible = false
	

func load_dialogue() -> Array:
	var file = FileAccess.open("res://dialogue/opening_cutscene.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func set_dialogue(dialogue: String):
	$MarginContainer/Panel/Text.text = dialogue
