extends CharacterBody3D

const SPEED = 10
var i = 6
var direction: Vector2

func _physics_process(delta: float) -> void:
	#Random Basic Movement
	i += delta
	if i >= 5:
		direction = Vector2(randf() - 0.5, randf() - 0.5)
		i -= 5
	if direction:
		velocity.x = direction.x
		velocity.z = direction.y
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	print(str(direction))

	move_and_slide()
