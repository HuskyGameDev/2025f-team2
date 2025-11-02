extends Camera3D

var speed : float = 10.0

var target_camera_position : Vector3

func _ready() -> void:
	target_camera_position = position

func _process(delta: float) -> void:
	var moveVector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) * delta * speed
	var distanceVector = Input.get_axis("release", "reroll") * delta * speed
	target_camera_position += Vector3(moveVector.x, distanceVector, moveVector.y)
	
	position =  position.lerp(target_camera_position, 15*delta)
