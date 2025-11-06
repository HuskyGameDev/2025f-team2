extends Control

class_name Transition

@export var animator : AnimationPlayer

func _ready() -> void:
	z_index = 4046

func lowerTransition():
	animator.play("transition_exit")

func raiseTransition():
	animator.play("transition_enters")

func kill_on_finish():
	animator.animation_finished.connect(free_self)

func free_self(anim_name : String):
	queue_free()
