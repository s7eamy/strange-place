extends Area2D

signal object_entered_game_over_zone()


func _on_body_entered(body) -> void:
	if body is RigidBody2D:
		object_entered_game_over_zone.emit()
