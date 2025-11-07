extends CharacterBody2D

signal start_dialogue_finished_yes

var player
var player_in_chat_zone = false
var start_dialogue_finsihed = false
var walk_change_amount = 0


func _ready():
	$AnimatedSprite2D.flip_h = true
	$AnimatedSprite2D.play("side_idle")
	$ButtonHint.visible = false
	
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("chat") and player_in_chat_zone:
		#print("chatting with npc")
		#$TextBox.start()
	if Input.is_action_just_pressed("e") and player_in_chat_zone:
		print("quest has been started")
		$QuestBox.next_quest()
		


func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player") and start_dialogue_finsihed:
		player = body
		player_in_chat_zone = true
		$ButtonHint.visible = true

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_chat_zone = false
		$ButtonHint.visible = false

	pass # Replace with function body.


func _on_opening_cutscene_opening_cutscene_finish() -> void:
	$TextBox.start()


func _on_text_box_start_dialogue_finished() -> void:
	start_dialogue_finished_yes.emit()
	start_dialogue_finsihed = true


func _on_path_follow_2d_npc_reached_point(point_name: Variant) -> void:
	if point_name == "start":
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("side_walk")
	elif point_name == "quarter":
		$AnimatedSprite2D.play("front_walk")
	elif point_name == "three_quarters":
		$AnimatedSprite2D.play("side_walk")
	elif point_name == "end":
		$AnimatedSprite2D.play("idle")
