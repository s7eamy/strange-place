extends Node2D

signal object_placed(placed_object: Node)

var ghost: Node2D
var can_place: bool = false


func _process(_delta: float) -> void:
	if ghost:
		# Follow mouse cursor
		ghost.global_position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_place and ghost:
				_place_object()


func set_object(scene: PackedScene) -> void:
	can_place = true
	if ghost:
		ghost.queue_free()

	# Instantiate ghost object scene
	ghost = scene.instantiate()
	add_child(ghost)

	# Disable physics
	var ghost_body = ghost.get_node_or_null("RigidBody2D")
	if ghost_body:
		ghost_body.freeze = true
		ghost_body.sleeping = true
		ghost_body.set_collision_layer(0)
		ghost_body.set_collision_mask(0)
		
	var ghost_sprite = ghost_body.get_node_or_null("Sprite2D")
	if ghost_sprite:
		ghost_sprite.modulate.a = 0.5


func remove_object() -> void:
	if ghost:
		ghost.queue_free()
	can_place = false


func _place_object() -> void:
	# Spawn the real object at ghost position
	var placed_object = ghost.duplicate()

	# Add to scene first (so @onready variables are initialized)
	get_parent().add_child(placed_object)

	# Unfreeze physics
	var rigid_body = placed_object.get_node_or_null("RigidBody2D")
	if rigid_body:
		rigid_body.freeze = false
		rigid_body.set_collision_layer(1)
		rigid_body.set_collision_mask(1)
	
	remove_object()
	object_placed.emit(placed_object)
