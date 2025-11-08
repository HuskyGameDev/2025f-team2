extends Node2D

var scoreText = "+1"
@export var scoreLabel: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scoreLabel.text = scoreText
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _process(delta: float) -> void:
	position.y -= 0.25
