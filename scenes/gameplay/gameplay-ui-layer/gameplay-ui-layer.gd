extends CanvasLayer

#@onready var pause := self
#@onready var pause_button := $MarginContainer/Control/PauseButton
@onready var score_number_label := $MarginContainer/Control/VBoxScore/ScoreNumber
#@onready var label = $MarginContainer/Control/Label
@onready var ui_options = $MarginContainer/Control/VBoxOptions
@onready var resume_option := $MarginContainer/Control/VBoxOptions/ResumeButton
@onready var color_rect = $ColorRect

@onready var nodes_grp1 = [] # should be visible during gameplay and hidden during pause
#@onready var nodes_grp1 = [pause_button, label] # should be visible during gameplay and hidden during pause
@onready var nodes_grp2 = [ui_options, color_rect] # should be visible only in pause menu
#@onready var nodes_grp2 = [pause_options, color_rect] # should be visible only in pause menu

signal restart_triggered


func _ready():
	pause_hide()


func update_score(score: int) -> void:
	score_number_label.text = str(score)


func pause_show():
	for n in nodes_grp1:
		n.hide()
	for n in nodes_grp2:
		n.show()


func pause_hide():
	for n in nodes_grp1:
		if n:
			n.show()

	for n in nodes_grp2:
		if n:
			n.hide()


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_game()
		get_viewport().set_input_as_handled()


func resume():
	get_tree().paused = false
	pause_hide()


func restart():
	resume()
	emit_signal("restart_triggered")


func pause_game():
	resume_option.grab_focus()
	get_tree().paused = true
	pause_show()


func exit_game():
	# gently shutdown the game
	var transitions = get_node_or_null("/root/GGT_Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _on_ResumeButton_pressed():
	resume()


#func _on_PauseButton_pressed():
	#pause_game()


func _on_RestartButton_pressed():
	restart()


func _on_ExitButton_pressed():
	exit_game()


#func _on_main_menu_pressed():
	#GGT.change_scene("res://scenes/menu/menu.tscn", {"show_progress_bar": false})
