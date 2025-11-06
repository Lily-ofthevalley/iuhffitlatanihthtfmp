extends CharacterBody2D

var player
var player_in_chat_zone = false

func _ready():
	$AnimatedSprite2D.play("idle")
	$ButtonHint.visible = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("chat") and player_in_chat_zone:
		print("chatting with npc")
		$TextBox.start()
	if Input.is_action_just_pressed("e") and player_in_chat_zone:
		print("quest has been started")
		$QuestBox.next_quest()


func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_in_chat_zone = true
		$ButtonHint.visible = true

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_chat_zone = false
		$ButtonHint.visible = false
