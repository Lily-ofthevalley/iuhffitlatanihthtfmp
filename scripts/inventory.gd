extends Resource

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	var itemslots = slots.filter(func(slot): return slot.item == item)
	if !itemslots.is_empty():
		pass
	else: 
		var emptyslots = slots.filter(func(slot): return slot.item == null)
		if !emptyslots.is_empty():
			emptyslots[0].item = item
	update.emit()

#func insert(item: InvItem):
	#var itemslots = slots.filter(func(slot): return slot.item == item)
	#if !itemslots.is_empty():
		#pass
	#else: 
		#var emptyslots = slots.filter(func(slot): return slot.item == null)
		#if !emptyslots.is_empty():
			#emptyslots[0].item = item
	#update.emit()
