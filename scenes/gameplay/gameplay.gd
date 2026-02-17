extends Node

@onready var object_queue = $ObjectQueue
@onready var placement_controller = $PlacementController

var score: int = 0


func _ready() -> void:
	var scene_data = GGT.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)

	if GGT.is_changing_scene():
		await GGT.scene_transition_finished

	print("GGT/Gameplay: scene transition animation finished")

	# Connect signals
	object_queue.object_selected.connect(_on_object_selected)
	placement_controller.object_placed.connect(_on_object_placed)

	# Start the game by picking the first object
	object_queue.pick_next_object()


func _on_object_selected(data: ObjectData) -> void:
	# Show the ghost with the selected object
	placement_controller.set_object(data)


func _on_object_placed(_placed_object: RigidBody2D) -> void:
	# Increment score
	score += 1
	print("Object placed! Score: ", score)

	# Update strangeness level based on score
	object_queue.increase_strangeness(score)

	# Pick the next object
	object_queue.pick_next_object()
