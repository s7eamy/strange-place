extends Node

@onready var object_factory = $ObjectFactory
@onready var placement_controller = $PlacementController
@onready var game_over_zone = $GameOverZone
@onready var game_over_layer = $GameOverLayer

var score: int = 0
var turn_number: int = 1
var is_game_over: bool = false


func _ready() -> void:
	if GGT.is_changing_scene():
		await GGT.scene_transition_finished
	print("GGT/Gameplay: scene transition animation finished")

	# Connect signals
	object_factory.object_selected.connect(_on_object_selected)
	placement_controller.object_placed.connect(_on_object_placed)
	game_over_zone.object_entered_game_over_zone.connect(_on_game_over)
	game_over_layer.restart_triggered.connect(_on_restart_triggered)

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


func _on_game_over() -> void:
	if is_game_over:
		return

	is_game_over = true
	placement_controller.remove_object()
	game_over_layer.show_game_over(score)


func _on_restart_triggered() -> void:
	get_tree().reload_current_scene()
