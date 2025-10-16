extends Control

var is_open = false
@onready var inv: Inv = preload("res://inventory/playerInv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

func update_slots():
	#print(range(min(inv.slots.size(), slots.size())))
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
	

func _ready():
	inv.update.connect(update_slots)
	update_slots()
	close()
	
func _process(delta):
	if Input.is_action_just_pressed("i"):
		print("inv button")
		if is_open:
			close()
		else: open()

func open():
		visible = true
		is_open = true
	
func close():
		visible = false
		is_open = false
