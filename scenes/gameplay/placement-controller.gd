extends Node2D

signal object_placed(placed_object: RigidBody2D)

@onready var ghost: Sprite2D = $Ghost

var placeable_object_scene: PackedScene = preload("res://scenes/gameplay/placeable-object.tscn")
var current_object_data: ObjectData = null
var can_place: bool = false


func _ready() -> void:
	ghost.modulate.a = 0.5  # Semi-transparent


func _process(_delta: float) -> void:
	if current_object_data:
		# Follow mouse cursor
		ghost.global_position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_place and current_object_data:
				_place_object()


func set_object(data: ObjectData) -> void:
	current_object_data = data
	ghost.texture = data.texture
	ghost.visible = true
	can_place = true


func _place_object() -> void:
	# Spawn the real object at ghost position
	var placed_object = placeable_object_scene.instantiate() as RigidBody2D
	placed_object.global_position = ghost.global_position

	# Add to scene first (so @onready variables are initialized)
	get_parent().add_child(placed_object)

	# Initialize with current object data
	placed_object.init(current_object_data)

	# Unfreeze physics
	placed_object.freeze = false

	# Hide ghost and disable placement
	ghost.visible = false
	can_place = false
	current_object_data = null

	# Emit signal
	object_placed.emit(placed_object)
