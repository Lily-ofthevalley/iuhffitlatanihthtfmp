extends CanvasLayer

const scenes_to_load = ["res://scenes/ti_lab.tscn", "res://scenes/hallway.tscn", "res://scenes/outdoor.tscn"]
var currently_loading = 0
var progress = []


func _ready() -> void:
	ResourceLoader.load_threaded_request(scenes_to_load[0])
	

func load_next_or_continue():
	if currently_loading + 1 == scenes_to_load.size():
		var scene = ResourceLoader.load_threaded_get(scenes_to_load[0])
		get_tree().change_scene_to_packed(scene)
		
	currently_loading += 1
	ResourceLoader.load_threaded_request(scenes_to_load[1])
	
	
func set_progress(n: int, progress):
	if progress[0] > 0.3 && progress[0] < 0.7:
		progress[0] = 0.68
	match n:
		0:
			$HBoxContainer/TiLabProgresBar.value = progress[0]-0.01
		1:
			$HBoxContainer/HallwayProgressBar.value = progress[0]-0.01
		2:
			$HBoxContainer/OutdoorProgressBar.value = progress[0]-0.01

func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(scenes_to_load[currently_loading], progress)
	set_progress(currently_loading, progress)
	
	# Check if all loaded
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(0.5).timeout # Wait a bit because it looks clean
		load_next_or_continue()
