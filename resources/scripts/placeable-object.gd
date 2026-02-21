extends RigidBody2D

@onready var object_data: ObjectData = $ObjectData


func _ready() -> void:
	mass = object_data.weight
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.weight = object_data.weight
	physics_material_override.friction = object_data.friction
	#physics_material_override.bounce = object_data.bounce

	freeze = true
