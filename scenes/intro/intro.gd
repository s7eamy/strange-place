extends Control

@onready var label: Label = $CenterContainer/Label
@onready var hint_label: Label = $HintLabel
@onready var tween_ref: Tween

var slides: Array[String] = [
	"The government has started taxing land\nbased on the base size used.",
	"Grandma must move her old belongings\nfrom the house to the shed,\nusing as little base space as possible.",
]

var current_slide: int = 0
var can_advance: bool = false


func _ready() -> void:
	if GGT.is_changing_scene():
		await GGT.scene_transition_finished
	show_slide(current_slide)


func show_slide(index: int) -> void:
	can_advance = false
	label.modulate.a = 0.0
	hint_label.modulate.a = 0.0
	label.text = slides[index]

	tween_ref = create_tween()
	tween_ref.tween_property(label, "modulate:a", 1.0, 0.5)
	tween_ref.tween_interval(0.3)
	tween_ref.tween_property(hint_label, "modulate:a", 1.0, 0.4)
	tween_ref.tween_callback(func(): can_advance = true)


func advance() -> void:
	if not can_advance:
		return
	can_advance = false

	if tween_ref:
		tween_ref.kill()

	var fade_out = create_tween()
	fade_out.tween_property(label, "modulate:a", 0.0, 0.3)
	fade_out.parallel().tween_property(hint_label, "modulate:a", 0.0, 0.3)
	await fade_out.finished

	current_slide += 1
	if current_slide < slides.size():
		show_slide(current_slide)
	else:
		GGT.change_scene("res://scenes/gameplay/gameplay.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		advance()
	elif event is InputEventKey and event.pressed:
		advance()
	elif event is InputEventJoypadButton and event.pressed:
		advance()
