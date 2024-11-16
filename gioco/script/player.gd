extends CharacterBody2D

@onready var actionable_finder: Area2D = $Marker2D/Area2D

const SPEED = 50
var direction

func _process(delta):
	
	#movimento
	if State.Dialogue_Window == false:
		direction = Input.get_vector ("ui_left", "ui_right", "ui_up", "ui_down")
		
		if direction != Vector2.ZERO:
			velocity = SPEED*direction
			if direction.y > 0:
				$AnimatedSprite2D.play("giu")
			elif direction.y < 0:
				$AnimatedSprite2D.play("su")
			elif direction.x > 0:
				$AnimatedSprite2D.play("destra")
			elif direction.x < 0:
				$AnimatedSprite2D.play("sinistra")
		else:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.frame = 0
			$AnimatedSprite2D.stop()
				 

		move_and_slide()
		
		#dialogo
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size()>0:
			$"../CanvasLayer".visible = true
		else:
			$"../CanvasLayer".visible = false
		if Input.is_action_just_pressed("interazione"):
			if actionables.size()>0:
				actionables[0].action()
				return
	
	if State.Minigame == true :
		Transition.transition() 
		await Transition.on_transition_finished 
		call_deferred("change_scene")
	
func change_scene(): 
	if get_tree(): 
		get_tree().change_scene_to_file("res://levels/router-choices1/node_2d.tscn")
	else:
		print("Errore: get_tree() restituisce null")
