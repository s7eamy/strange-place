extends Camera2D

const move_speed := 800.0
const edge_scroll_speed := 800.0
const edge_scroll_margin := 20.0

const clamp_margin := 200.0
var left_edge := 0.0
var right_edge := 1152.0
var top_edge := 0.0
const bottom_edge := 648

const zoom_step := 0.1
const zoom_min := 0.4
const zoom_max := 1.5
const zoom_lerp_speed := 8.0

var target_zoom := 1.0


func _ready():
	target_zoom = zoom.x


func _process(delta):
	_handle_keyboard_movement(delta)
	_handle_edge_scroll(delta)
	_handle_zoom(delta)
	_clamp_camera_to_objects()


func on_bounds_updated(left: float, right: float, top: float) -> void:
	left_edge = left
	right_edge = right
	top_edge = top


# ---------------------------------
# Movement (WASD / Arrows)
# ---------------------------------
func _handle_keyboard_movement(delta):
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		# Scale speed by current zoom (inverse)
		global_position += direction * move_speed * delta / zoom.x


# ---------------------------------
# Edge Scroll
# ---------------------------------
func _handle_edge_scroll(delta):
	var mouse_pos := get_viewport().get_mouse_position()
	var screen_size := get_viewport_rect().size
	var direction := Vector2.ZERO
	
	if mouse_pos.x <= edge_scroll_margin:
		direction.x -= 1
	elif mouse_pos.x >= screen_size.x - edge_scroll_margin:
		direction.x += 1
		
	if mouse_pos.y <= edge_scroll_margin:
		direction.y -= 1
	elif mouse_pos.y >= screen_size.y - edge_scroll_margin:
		direction.y += 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		# Scale speed by current zoom (inverse)
		global_position += direction * edge_scroll_speed * delta / zoom.x


# ---------------------------------
# Zoom
# ---------------------------------
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += zoom_step
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= zoom_step
		
		target_zoom = clamp(target_zoom, zoom_min, zoom_max)


func _handle_zoom(delta):
	var current := zoom.x
	var new_zoom: float = lerp(current, target_zoom, zoom_lerp_speed * delta)
	zoom = Vector2(new_zoom, new_zoom)


func _clamp_camera_to_objects() -> void:
	var half_screen_zoomed := get_viewport_rect().size * 0.5  / zoom
	
	var min_x := left_edge - half_screen_zoomed.x + clamp_margin
	var max_x := right_edge + half_screen_zoomed.x - clamp_margin
	var min_y := top_edge - half_screen_zoomed.y + clamp_margin
	var max_y := bottom_edge - half_screen_zoomed.y # To ensure it does not go below floor
	
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)
