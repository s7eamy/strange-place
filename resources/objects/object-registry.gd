extends Resource
class_name ObjectRegistry

## Registry of all available ObjectData resources
## This ensures objects are properly loaded in exported builds

const OBJECTS: Array[ObjectData] = [
	preload("res://resources/objects/suolelis.tres"),
	preload("res://resources/objects/pomidor.tres"),
]


static func get_all_objects() -> Array[ObjectData]:
	return OBJECTS
