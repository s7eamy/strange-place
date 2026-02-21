extends Node2D

signal object_placed(placed_object: Node)
signal bounds_updated(left: float, right: float, top: float)

# Container for all placed objects
@export var objects_collection: Node2D

var selected_scene: PackedScene
var ghost: Node2D
var ghost_sprite: Sprite2D

var can_place: bool = false
var cooldown_remaining: float = 0.0
const COOLDOWN: float = 0.5

const GHOST_ALPHA_MIN := 0.0
const GHOST_ALPHA_MAX := 0.6

const ROTATION_SPEED := deg_to_rad(135)
# Rotation input state
var rotate_left := false
var rotate_right := false

# Exposed bounds for camera
var leftmost: float = 0.0
var rightmost: float = 0.0
var topmost: float = 0.0


func _process(delta: float) -> void:
	if cooldown_remaining > 0.0:
		cooldown_remaining -= delta
		cooldown_remaining = max(cooldown_remaining, 0.0)
	
	if ghost:
		# Follow mouse cursor
		ghost.global_position = get_global_mouse_position()
		
		# Rotate ghost
		if rotate_left:
			ghost.rotation -= ROTATION_SPEED * delta
		if rotate_right:
			ghost.rotation += ROTATION_SPEED * delta
		
		if ghost_sprite:
			# Handle cooldown and fade in of new previewed object
			if cooldown_remaining < COOLDOWN:
				var progress := 1.0 - (cooldown_remaining / COOLDOWN)
				ghost_sprite.modulate.a = GHOST_ALPHA_MIN + progress * (GHOST_ALPHA_MAX - GHOST_ALPHA_MIN)
			
			# Tint red when previewed object is unplaceable
			if _is_overlapping():
				ghost_sprite.modulate = Color(1, 0.3, 0.3, ghost_sprite.modulate.a)
			else:
				ghost_sprite.modulate = Color(1, 1, 1, ghost_sprite.modulate.a)


func _is_overlapping() -> bool:
	return ghost.get_overlapping_bodies().size() > 0


func preview_object(scene: PackedScene) -> void:
	can_place = true
	selected_scene = scene
	
	# Instantiate the real scene temporarily to extract visuals
	var temp_instance = scene.instantiate()
	var original_body = temp_instance.get_node("RigidBody2D")
	
	# Create ghost preview
	ghost = Area2D.new()
	add_child(ghost)

	# Update ghost collision
	ghost.collision_layer = 1
	ghost.collision_mask = 1
	ghost.monitoring = true
	ghost.monitorable = true
	
	# Move children from original body directly to ghost
	for child in original_body.get_children():
		var copy = child.duplicate()
		ghost.add_child(copy)
		
		if copy is Sprite2D:
			ghost_sprite = copy
	
	temp_instance.queue_free()


func _convert_rigidbody_to_static(body: RigidBody2D) -> void:
	var replacement = Node2D.new()
	replacement.position = body.position
	replacement.rotation = body.rotation
	replacement.scale = body.scale
	
	# Move all children to replacement
	for child in body.get_children():
		child.reparent(replacement)
	
	# Replace in tree
	body.get_parent().add_child(replacement)
	body.queue_free()


func _input(event: InputEvent) -> void:
	# Placement
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_place and ghost and cooldown_remaining == 0.0 and not _is_overlapping():
				_place_object()
	
	# Rotation
	if event is InputEventKey:
		if event.keycode == KEY_Q:
			rotate_left = event.pressed
		elif event.keycode == KEY_E:
			rotate_right = event.pressed


func _place_object() -> void:
	# Spawn the real object at ghost position
	var placed_object = selected_scene.instantiate()
	placed_object.global_position = ghost.global_position
	placed_object.rotation = ghost.rotation
	objects_collection.add_child(placed_object)
	
	cooldown_remaining = COOLDOWN
	remove_object()
	
	_update_camera_bounds(placed_object)
	object_placed.emit(placed_object)


func remove_object() -> void:
	if ghost:
		ghost.queue_free()
	can_place = false


func _update_camera_bounds(object: Node2D) -> void:
	var sprite := object.get_node_or_null("RigidBody2D/Sprite2D")
	if not sprite:
		return
	
	var pos := object.global_position
	var size: Vector2 = sprite.texture.get_size() * object.scale
	
	if objects_collection.get_child_count() == 1:
		leftmost = pos.x - size.x / 2
		rightmost = pos.x + size.x / 2
		topmost = pos.y - size.y / 2
	else:
		leftmost = min(leftmost, pos.x - size.x / 2)
		rightmost = max(rightmost, pos.x + size.x / 2)
		topmost = min(topmost, pos.y - size.y / 2)
		
		bounds_updated.emit(leftmost, rightmost, topmost)
