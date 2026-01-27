extends RayCast3D

#This script has been scrapped and should be removed in a future update

#Script for the raycasts on the ducks!
func _process(_delta: float) -> void:
	if is_colliding():
		self.get_parent().get_parent().state = "think"
