extends CharacterBody2D

var is_chatting = false

var player
var player_in_chat_zone = false

func _ready():
	$AnimatedSprite2D.play("idle")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("chat"):
		print("chatting with npc")
		$TextBox.start()
		is_chatting = true
	if Input.is_action_just_pressed("quest"):
		print("quest has been started")
		$QuestBox.next_quest()
		is_chatting = true

func choose(array):
	array.shuffle()
	return array.front()


func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_in_chat_zone = true


func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_chat_zone = false


func _on_dialogue_dialogue_finished() -> void:
	is_chatting = false


func _on_npc_quest_quest_menu_closed() -> void:
	is_chatting = false
