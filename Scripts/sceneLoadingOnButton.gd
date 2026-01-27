extends Control

@export var sceneToLoad: String

func _on_pressed() -> void:
	saveDataValues.savingData()
	get_tree().change_scene_to_file("res://Scenes/" + sceneToLoad + ".tscn")
