extends Area3D

var timeInAir = 0

var target: Node3D

var startingPos: Vector3

var flyingHeight: float

var t: float
var d: float
var b: float
var a: float

func _process(delta: float) -> void:
	#Uses Cramer's rule to calculate the quadratic equation for the arc of the projectile
	#Moves the projectile towards the target depending on the time its been alive

	target = self.get_parent().find_child("Target")
	timeInAir += delta
	t = sqrt((startingPos.x - target.position.x) ** 2 + (startingPos.z - target.position.z) ** 2)
	
	d = (t**3)/-4.0
	
	a = (t*flyingHeight) / d
	
	b = -(t**2 * flyingHeight) / d
	
	self.position.y = a * timeInAir ** 2 + b * timeInAir
	if self.position.y < 0:
		self.position.y = 0
	
	self.look_at(Vector3(((target.position.x - startingPos.x) * (timeInAir + 0.1) / t),(a* (timeInAir + 0.1) ** 2 + b * (timeInAir + 0.1)), (target.position.z - startingPos.z) * (timeInAir + 0.1) / t))
	
	self.position.x = (target.position.x - startingPos.x) * timeInAir / t
	self.position.z = (target.position.z - startingPos.z) * timeInAir / t


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		self.queue_free()
