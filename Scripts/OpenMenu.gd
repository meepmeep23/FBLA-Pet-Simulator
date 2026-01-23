extends Button



func _on_pressed() -> void:
	self.get_parent().find_child("Are You Sure Submenu").visible = true

func _on_yes_pressed() -> void:
	self.get_parent().find_child("Are You Sure Submenu").visible = false

func _on_no_pressed() -> void:
	self.get_parent().find_child("Are You Sure Submenu").visible = false
