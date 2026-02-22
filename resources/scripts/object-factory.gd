extends Node

signal object_selected(scene: PackedScene)

	# Take all ObjectData resources from the global object registry
	# Using a registry ensures proper loading in exported builds
@export var object_registry: Node


func _ready() -> void:
	if object_registry.scenes.size() == 0:
		push_error("ObjectQueue: no objects in registry!")


func pick_next_object(turn_number: int) -> void:
	var eligibility_score_criteria = 3 * turn_number
	var eligible_objects: Array = []

	# TODO: don't trigger recalculation if all objects have been added
	for object in object_registry.scenes:
		var instance = object.instantiate()
		var object_data = instance.get_node("ObjectData")
		# Evaluate if object is eligible
		if object_data.score <= eligibility_score_criteria:
			eligible_objects.append(object)
		instance.queue_free()

	if eligible_objects.size() == 0:
		push_warning("ObjectQueue: no eligible objects for turn ", turn_number)
		eligible_objects = object_registry.scenes
		return

	# Pick random object
	var selected = eligible_objects.pick_random()
	object_selected.emit(selected)
