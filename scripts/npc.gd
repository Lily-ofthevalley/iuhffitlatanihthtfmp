extends CharacterBody2D

func _ready():
	$AnimatedSprite2D.play("idle")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("chat"):
		print("chatting with npc")
		$TextBox.start()
	if Input.is_action_just_pressed("quest"):
		print("quest has been started")
		$QuestBox.next_quest()
