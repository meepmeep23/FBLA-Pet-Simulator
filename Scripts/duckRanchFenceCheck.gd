extends RayCast3D


#Script for the raycasts on the ducks!
func _process(_delta: float) -> void:
	if is_colliding():
		self.get_parent().get_parent().state = "think"
