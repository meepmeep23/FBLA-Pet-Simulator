extends StaticBody3D

var mouseInside = false
var selected = false

var shadowMaterial = preload("res://Materials/shadowMat.tres")

func _process(_delta: float) -> void:
	if selected == true && Input.is_action_just_pressed("Enter Building") && saveDataValues.Duckies.size() > 5:
		self.get_parent().find_child("TabContainer").openTab = 5
	
	if Input.is_action_just_pressed("click"):
		if mouseInside == true:
			selected = true
		else:
			selected = false
		
		var duckiesOfAge = 0
		
		for x in saveDataValues.Duckies:
			if saveDataValues.Duckies.get(x).age >= 7:
				duckiesOfAge += 1
		
		if duckiesOfAge < 6:
			$Sprite3D/SubViewport/RichTextLabel.text = "Must have 6 Ducks that are 7 years old to participate."
		if duckiesOfAge >= 6:
			$Sprite3D/SubViewport/RichTextLabel.text = "Press 'E' To Enter"
		$Cube.material_override = shadowMaterial
	
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
