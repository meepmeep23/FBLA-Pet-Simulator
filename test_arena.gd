extends Node3D

var Duckies = saveDataValues.Duckies
var hasCheckedDucks = false
@onready var baseDuck = preload("res://Objects/base_duck.tscn")

func _process(_delta: float) -> void:
	#System for loading ducks from saved data by looping through the dictionary and spawning ducks
	saveDataValues.testArena = self
	Duckies = saveDataValues.Duckies
	if hasCheckedDucks == false && Duckies != {}:
		get_child(0).get_child(1).queue_free()
		get_child(0).get_child(0).queue_free()
		for x in Duckies:
			print(x)
			var ducky = baseDuck.instantiate()
			ducky.name = x
			ducky.position.x = randf_range(-5,5)
			ducky.position.z = randf_range(-5,5)
			ducky = ducky.duplicate()
			self.get_child(0).add_child(ducky,true)
		hasCheckedDucks = true
	
	#First duck is named "XyzAbc" to see if saved data exists
	if self.get_child(0).find_child("XyzAbc") != null && hasCheckedDucks == false:
		self.find_child("UI Main").position.x = 0
		self.find_child("UI Main").firstTime = true
		hasCheckedDucks = true
