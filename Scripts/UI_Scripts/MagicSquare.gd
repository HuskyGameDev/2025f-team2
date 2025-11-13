extends Sprite2D

class_name MagicSquareUI

var rrot = 0.0
@export var rotSpeed = 0.5
@export var rote = 0.0

@export var circlePosition : Vector4

@onready var places = [$ItemNode, $ItemNode2, $ItemNode3, $ItemNode4]

var ids = [false, false, false, false]

var activateOnce = false
func _process(delta: float) -> void:
	if not (material is ShaderMaterial):
		return
		
	rrot += rotSpeed*delta
	
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("rotation", rrot)
	
	var post1 = get_ellipse_point(circlePosition.x, circlePosition.y, circlePosition.z, circlePosition.w, -rrot+rote)
	$ItemNode.position = post1
	
	var post2 = get_ellipse_point(circlePosition.x, circlePosition.y, circlePosition.z, circlePosition.w, -rrot+rote+deg_to_rad(90))
	$ItemNode2.position = post2
	
	var post3 = get_ellipse_point(circlePosition.x, circlePosition.y, circlePosition.z, circlePosition.w, -rrot+rote+deg_to_rad(180))
	$ItemNode3.position = post3
	
	var post4 = get_ellipse_point(circlePosition.x, circlePosition.y, circlePosition.z, circlePosition.w, -rrot+rote+deg_to_rad(270))
	$ItemNode4.position = post4
	
func get_ellipse_point(h : float , k: float, a: float, b: float, theta: float):
	"""
	Calculates the coordinates of a point on an ellipse.

	Args:
		h (float): x-coordinate of the ellipse center.
		k (float): y-coordinate of the ellipse center.
		a (float): Semi-major axis length.
		b (float): Semi-minor axis length.
		theta (float): Eccentric anomaly in radians.

	Returns:
		tuple: (x, y) coordinates of the point on the ellipse.
	"""
	
	
	var x = h + a * cos(theta)
	var y = k + b * sin(theta)
	return Vector2(x, y)

func set_Clock_UI(time_in_seconds : float):
	var minutes: int = int(fmod(time_in_seconds / 60.0, 60.0))
	var seconds: int = int(fmod(time_in_seconds, 60.0))
	
	var time_string: String = ""
	time_string += "%d:%02d" % [minutes, seconds]
	
	$Clock/Label.text = time_string

func clockOn():
	if activateOnce:
		return
	activateOnce = true
	await GlobalSceneLoader.onTransitionDone
	create_tween().tween_property($Clock, "modulate", Color.WHITE, 1.75)



func setUI(id : int = 0, type : int = 0, value : int = 0):
	if !ids[id]:
		create_tween().tween_property(places[id], "modulate", Color.WHITE, 1.75)
		ids[id] = true
	places[id].get_child(0).frame = type
	places[id].get_child(0).get_child(0).text = str(value)
