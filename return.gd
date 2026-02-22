extends Button


func _on_pressed() -> void:
	self.get_parent().get_parent().current_tab = 0
