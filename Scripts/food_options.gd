extends ItemList

var Duck: Node3D
var mouseInside = false

func _process(_delta: float) -> void:
	#Displays food if food panel is open, and closes panel if clicked off of it.

	if self.visible == true && Duck != null:
		if mouseInside == false && Input.is_action_just_pressed("click"):
			self.get_parent().get_parent().get_parent().visible = false
			self.get_parent().get_parent().get_parent().position = Vector2(-276,0)
		for y in item_count:
			remove_item(0)
		for x in saveDataValues.foodItems:
			add_item(x + "     " + str(saveDataValues.foodItems.get(x)))


func _on_mouse_entered() -> void:
	mouseInside = true

func _on_mouse_exited() -> void:
	mouseInside = false

func _on_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	"""
	Reads what item was selected,
	makes sure that there is at least 1 to feed them,
	give duck food or changes a stat depending on what food was fed to them,
	sets food to 100 so the duck can't get overfed.
	"""

	var foodText = get_item_text(index)
	foodText = foodText.remove_chars(" 1234567890")
	Duck.fed(foodText)
