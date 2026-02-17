extends Node

signal object_selected(data: ObjectData)

var object_pool: Array[ObjectData] = []
var current_strangeness_level: int = 0


func _ready() -> void:
	_load_objects()


func _load_objects() -> void:
	# Load all ObjectData resources from the registry
	# Using a registry ensures proper loading in exported builds
	object_pool = ObjectRegistry.get_all_objects()


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
	@warning_ignore("integer_division")
	current_strangeness_level = score / 5
