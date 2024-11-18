extends Node2D

func _ready():
	$player.position = Vector2(State.px,State.py)
