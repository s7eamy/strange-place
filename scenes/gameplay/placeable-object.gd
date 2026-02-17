extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var object_data: ObjectData


func init(data: ObjectData) -> void:
	object_data = data

	# Configure sprite
	sprite.texture = data.texture

	# Configure collision shapes
	if data.collision_shapes.size() > 0:
		# Multiple collision shapes - hide default collision and create new ones
		collision.queue_free()
		for shape_data in data.collision_shapes:
			var col = CollisionShape2D.new()
			col.shape = shape_data.get("shape")
			col.position = shape_data.get("position", Vector2.ZERO)
			col.rotation = shape_data.get("rotation", 0.0)
			add_child(col)
	elif data.collision_shape:
		# Single collision shape
		collision.shape = data.collision_shape
		collision.position = data.collision_position
		collision.rotation = data.collision_rotation
	else:
		# Auto-create rectangle collision matching sprite size
		var rect_shape = RectangleShape2D.new()
		var texture_size = data.texture.get_size()
		rect_shape.size = texture_size
		collision.shape = rect_shape

	# Configure physics properties
	mass = data.weight
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = data.friction
	physics_material_override.bounce = data.bounce

	# Start frozen, will be unfrozen when placed
	freeze = true
