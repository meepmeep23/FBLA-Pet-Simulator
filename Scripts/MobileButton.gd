extends Button


func _on_pressed() -> void:
	Input.action_press(self.name)
