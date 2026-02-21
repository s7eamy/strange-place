extends CanvasLayer

@onready var score_number_label: Label = $CenterContainer/SplitContainer/VBoxContainerLabels/ScoreNumber
@onready var restart_button: Button = $CenterContainer/SplitContainer/VBoxContainerButtons/RestartButton
@onready var exit_button: Button = $CenterContainer/SplitContainer/VBoxContainerButtons/ExitButton

signal restart_triggered


func _ready():
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func show_game_over(score: int) -> void:
	score_number_label.text = str(score)
	visible = true


func _on_restart_pressed():
	emit_signal("restart_triggered")


func _on_exit_pressed():
	# gently shutdown the game
	var transitions = get_node_or_null("/root/GGT_Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()
