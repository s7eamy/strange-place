extends Node2D

signal object_placed(placed_object: Node)

#@onready var ghost: RigidBody2D = $Ghost
var ghost: Node2D
var can_place: bool = false


#func _ready() -> void:
	#ghost.modulate.a = 0.5  # Semi-transparent


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
	print(ghost_body)
	if ghost_body:
		ghost_body.freeze = true
		ghost_body.sleeping = true
		ghost_body.set_collision_layer(0)
		ghost_body.set_collision_mask(0)
		
	var ghost_sprite = ghost_body.get_node_or_null("Sprite2D")
	print(ghost_sprite)
	if ghost_sprite:
		ghost_sprite.modulate.a = 0.5


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
	
	ghost.queue_free()
	ghost = null
	## Hide ghost and disable placement
	#ghost.visible = false
	#can_place = false
	#current_object = null

	# Emit signal
	object_placed.emit(placed_object)
