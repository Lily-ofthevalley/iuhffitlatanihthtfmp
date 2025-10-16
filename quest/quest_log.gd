extends CanvasLayer

func _process(delta: float) -> void: #Checks if the quests have been completed
	if QuestManager.quest1_active == true:
		$MarginContainer/Panel/Text.text = "Steel de sensoren uit de kluis"
	elif QuestManager.quest2_active == true:
		$MarginContainer/Panel/Text.text = "Vindt een lichaam voor je robot"
	elif QuestManager.quest3_active == true:
		$MarginContainer/Panel/Text.text = "Pak het moederboord"
	else:
		$MarginContainer/Panel/Text.text = ""
