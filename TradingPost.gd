extends StaticBody3D

var mouseInside = false
var selected = false

var shadowMaterial = preload("res://Materials/shadowMat.tres")

#This entire script is basically just the same as building, but just opens a tab instead

func _process(_delta: float) -> void:
	#Stops the building from being selected while in store
	if self.get_parent().find_child("UI Main").openTab == 1:
		selected = false
	
	if selected == true && Input.is_action_just_pressed("E"):
		self.get_parent().find_child("UI Main").openTab = 1
	
	if Input.is_action_just_pressed("click"):
		if mouseInside == true:
			selected = true
		else:
			selected = false
		
		$Shadow.material_override = shadowMaterial
	
	if selected == true:
		shadowMaterial.set_albedo(Color(1.0, 1.0, 1.0, 1.0))
		$Sprite3D.visible = true
	if selected == false:
		shadowMaterial.set_albedo(Color(0.0, 0.0, 0.0, 1.0))
		$Sprite3D.visible = false

func _on_mouse_entered() -> void:
	mouseInside = true

func _on_mouse_exited() -> void:
	mouseInside = false
