extends Node

signal object_selected(data: ObjectData)

var object_pool: Array[ObjectData] = []
var current_strangeness_level: int = 0


func _ready() -> void:
	_load_objects()


func _load_objects() -> void:
	# Load all ObjectData resources from resources/objects/
	var dir = DirAccess.open("res://resources/objects/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource_path = "res://resources/objects/" + file_name
				var data = load(resource_path) as ObjectData
				if data:
					object_pool.append(data)
			file_name = dir.get_next()
		dir.list_dir_end()


func pick_next_object() -> void:
	if object_pool.is_empty():
		push_error("ObjectQueue: No objects in pool!")
		return

	# Filter by strangeness level
	var available_objects = object_pool.filter(
		func(data): return data.strangeness_level <= current_strangeness_level
	)

	# If no objects match, use all objects
	if available_objects.is_empty():
		available_objects = object_pool

	# Pick random object
	var selected = available_objects.pick_random()
	object_selected.emit(selected)


func increase_strangeness(score: int) -> void:
	# Increase strangeness every 5 objects placed
	current_strangeness_level = score / 5
