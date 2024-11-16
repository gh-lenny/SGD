extends CharacterBody2D

# Export permette di assegnare il target dal pannello editor
@export var target_path: NodePath
var target

# Velocità di movimento
@export var speed = 50.0

# Distanza minima per fermarsi dal target
@export var stop_distance = 50.0

# Riferimento all'Animator
@onready var animator = $AnimatedSprite2D

func _ready():
	target = get_node(target_path)

func _process(delta):
	if target:
		var distance_to_target = position.distance_to(target.position)
		
		if distance_to_target > stop_distance:
			var direction = (target.position - position).normalized()
			velocity = direction * speed
			move_and_slide()

			# Imposta l'animazione in base alla direzione
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					animator.play("destra")
				else:
					animator.play("sinistra")
			else:
				if direction.y > 0:
					animator.play("giu")
				else:
					animator.play("su")
		else:
			# Ferma il movimento quando è abbastanza vicino
			velocity = Vector2.ZERO
			move_and_slide()
			animator.stop()
