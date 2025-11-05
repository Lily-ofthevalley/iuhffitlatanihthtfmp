extends CanvasLayer

const target_scene = "res://scenes/ti_lab.tscn"
var progress = []

func _ready() -> void:
	ResourceLoader.load_threaded_request(target_scene)

func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(target_scene, progress)
	$ProgressBar.value = progress[0]-0.01
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(0.5).timeout # Wait a bit because it looks clean
		var scene = ResourceLoader.load_threaded_get(target_scene)
		get_tree().change_scene_to_packed(scene)
