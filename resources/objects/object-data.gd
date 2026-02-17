extends Resource
class_name ObjectData

# For simple objects with one collision shape
@export var object_name: String = ""
@export var texture: Texture2D
@export var collision_shape: Shape2D
@export var collision_position: Vector2 = Vector2.ZERO
@export var collision_rotation: float = 0.0
@export var weight: float = 1.0
@export var friction: float = 0.5
@export var bounce: float = 0.0
@export var strangeness_level: int = 0

# For complex objects with multiple collision shapes
# Array of dictionaries with keys: "shape" (Shape2D), "position" (Vector2), "rotation" (float)
@export var collision_shapes: Array[Dictionary] = []
