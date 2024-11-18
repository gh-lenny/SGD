extends Area2D

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: CharacterBody2D) -> void:
	State.px = -225
	State.py = -40
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file("res://levels/level3.tscn")
