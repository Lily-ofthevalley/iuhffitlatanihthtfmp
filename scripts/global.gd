extends Node

var arduino_port: String = "/dev/ttyUSB0"

@export var inv: Inv
@export var slots: Array[InvSlot]
@export var item: InvItem
#@export var Quest: 


var current_scene = "ti_lab"
var transition_destination = ""

var transition_scene = false

var player_exit_closet_posz = 0
var player_exit_closet_posx = 0
var player_start_closet_posz = 0
var player_start_closet_posx = 0

func checkPlayerinv(item, curQuest) :
	var itemslots = slots.filter(func(slot): return slot.item.name == item)
	if !itemslots.is_empty():
		pass
	else :
		curQuest = true;
		
	return itemslots
