extends Node

@onready var object_factory = $ObjectFactory
@onready var placement_controller = $PlacementController

var score: int = 0
var turn_number: int = 1

func _ready() -> void:
	var scene_data = GGT.get_current_scene_data()
	print("GGT/Gameplay: scene params are ", scene_data.params)

	if GGT.is_changing_scene():
		await GGT.scene_transition_finished
	print("GGT/Gameplay: scene transition animation finished")

	# Connect signals
	object_factory.object_selected.connect(_on_object_selected)
	placement_controller.object_placed.connect(_on_object_placed)

	# Start the game by picking the first object
	object_factory.pick_next_object(turn_number)


func _on_object_selected(scene: PackedScene) -> void:
	# Show the ghost with the selected object
	placement_controller.set_object(scene)


func _on_object_placed(placed_object: Node) -> void:
	# Increment score and turn number
	var object_data = placed_object.get_node_or_null("ObjectData")
	var object_score = object_data.score if object_data else 1
	score += object_score
	turn_number += 1
	print("Object placed! Turn: ", turn_number, " Score +", object_score, " Total: ", score)

	# Pick the next object
	object_factory.pick_next_object(turn_number)
