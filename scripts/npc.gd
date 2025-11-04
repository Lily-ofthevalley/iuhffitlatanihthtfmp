extends CharacterBody2D

var player
var player_in_chat_zone = false
var start_dialogue_complete = false
const NPC_SPEED = 100.0

func _ready():
	$AnimatedSprite2D.flip_h = true
	$AnimatedSprite2D.play("idle_side")
	$ButtonHint.visible = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("e") and player_in_chat_zone and start_dialogue_complete:
		print("quest has been started")
		$QuestBox.next_quest()
	elif Input.is_action_just_pressed("e") and !start_dialogue_complete:
		print("chatting with npc")
		$TextBox.start()

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player") and start_dialogue_complete:
		player = body
		player_in_chat_zone = true
		$ButtonHint.visible = true

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player") and start_dialogue_complete:
		player_in_chat_zone = false
		$ButtonHint.visible = false
