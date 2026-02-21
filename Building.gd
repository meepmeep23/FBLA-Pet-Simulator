extends StaticBody3D


@export var sceneToLoad = "res://smth"

var selected = false
var mouseInside = false

var shadowMaterial = preload("res://Materials/shadowMat.tres")
var breedingCenter = preload("res://Scenes/breeding_center.tscn")

func _ready() -> void:
	#Error Fixing with using same material multiple times
	shadowMaterial = shadowMaterial.duplicate()

func _process(_delta: float) -> void:
	#Selection Similar to Ducks, except when 'E' is pressed, load breeding center
	#*Also has 3D Gui that behaves the same way as the duck gui
	
	#Stops the building from being selected while in store
	if self.get_parent().find_child("UI Main").openTab == 1:
		selected = false
	
	if Input.is_action_just_pressed("click") && mouseInside == true:
		selected = true
	if Input.is_action_just_pressed("click") && mouseInside == false:
		selected = false
	if selected == true:
		shadowMaterial.set_albedo(Color(1.0, 1.0, 1.0, 1.0))
		if Input.is_action_just_pressed("E"):
			print("loading " + sceneToLoad)
			saveDataValues.savingData()
			saveDataValues.testArena = null
			get_tree().change_scene_to_file(sceneToLoad)
			
		$Sprite3D.visible = true
	if selected == false:
		shadowMaterial.set_albedo(Color(0.0, 0.0, 0.0, 1.0))
		$Sprite3D.visible = false
	
	#When Click, update the material to the current shadowMaterial
	#Also remember that child must be named 'Shadow' to work effectively
	if Input.is_action_just_pressed("click"):
		self.find_child("Shadow").material_override = shadowMaterial

func _on_mouse_entered() -> void:
	mouseInside = true

func _on_mouse_exited() -> void:
	mouseInside = false
