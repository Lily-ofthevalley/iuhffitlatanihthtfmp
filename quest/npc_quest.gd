extends CanvasLayer

signal quest_menu_closed

var dialogue = []
var current_dialogue_id = 0

var quest1_completed = false
var quest1_dialogue_active = false
var quest1_dialogue_completed = false

var quest2_completed = false
var quest2_dialogue_active = false
var quest2_dialogue_completed = false

var quest3_completed = false
var quest3_dialogue_active = false
var quest3_dialogue_completed = false

var stick = 0

func _ready() -> void: #Sets all ui's invisible at the start
	$quest_dialogue.visible = false
	$quest1_ui.visible = false
	$quest2_ui.visible = false
	$quest3_ui.visible = false

func _process(delta: float) -> void: #Checks if the quests have been completed
	if QuestManager.quest1_active:
		if stick == 0:
			QuestManager.quest1_active = false
			emit_signal("quest1_activity_status", false)
			quest1_completed = true
			quest1_dialogue_active = false
			print("quest 1 compleet: ", quest1_completed)
	if QuestManager.quest2_active:
		if stick == 0:
			QuestManager.quest2_active = false
			emit_signal("quest2_activity_status", false)
			quest2_completed = true
			quest2_dialogue_active = false
			print("quest 2 compleet: ", quest2_completed)
	if QuestManager.quest3_active:
		if stick == 0:
			QuestManager.quest3_active = false
			emit_signal("quest3_activity_status", false)
			quest3_completed = true
			quest3_dialogue_active = false
			print("quest 3 compleet: ", quest3_completed)

func next_quest(): #Checks which quest you are on
	if !quest1_completed:
		quest1_chat()
	elif !quest2_completed:
		quest2_chat()
	elif !quest3_completed:
		quest3_chat()
	else:
		print("No more quests available")
			
func load_dialogue(): #Loads the correct dialogue in
	var file
	
	if quest1_dialogue_active:
		file = FileAccess.open("res://quest/quest1_dialogue.json", FileAccess.READ)
	if quest2_dialogue_active:
		file = FileAccess.open("res://quest/quest2_dialogue.json", FileAccess.READ)
	if quest3_dialogue_active:
		file = FileAccess.open("res://quest/quest3_dialogue.json", FileAccess.READ)
			
	var content = JSON.parse_string(file.get_as_text())
	return content
	
func _input(event: InputEvent) -> void: #Listents for input of enter key to go to the next text
	if event.is_action_pressed("ui_accept"):
		next_script()
		
func next_script(): #Shows next text or closes dialogue
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		if quest1_dialogue_active:
			$quest1_ui.visible = true
		elif quest2_dialogue_active:
			$quest2_ui.visible = true
		elif quest3_dialogue_active:
			$quest3_ui.visible = true
		$quest_dialogue.visible = false
		return
		
	
	$quest_dialogue/Panel/Name.text = dialogue[current_dialogue_id]["name"]
	$quest_dialogue/Panel/Text.text = dialogue[current_dialogue_id]["text"]

# V Quest Dialogue functions V
func quest1_chat():
	quest1_dialogue_active = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	$quest_dialogue.visible = true
	next_script()
	
func quest2_chat():
	quest2_dialogue_active = true
	$quest_dialogue.visible = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()
	
func quest3_chat():
	quest3_dialogue_active = true
	$quest_dialogue.visible = true
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()

# V Quest accept and deny buttons V
func _on_yes_button_1_pressed2() -> void:
	$quest1_ui.visible = false
	QuestManager.quest1_active = true
	print("Quest 1:", QuestManager.quest1_active)


func _on_no_button_1_pressed2() -> void:
	$quest1_ui.visible = false
	QuestManager.quest1_active = false


func _on_yes_button_2_pressed2() -> void:
	$quest2_ui.visible = false
	QuestManager.quest2_active = true
	print("Quest 2:", QuestManager.quest2_active)


func _on_no_button_2_pressed2() -> void:
	$quest2_ui.visible = false
	QuestManager.quest2_active = false


func _on_yes_button_3_pressed2() -> void:
	$quest3_ui.visible = false
	QuestManager.quest3_active = true
	print("Quest 3:", QuestManager.quest3_active)


func _on_no_button_3_pressed2() -> void:
	$quest3_ui.visible = false
	QuestManager.quest3_active = false
