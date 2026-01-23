extends Node

var testArena: Node3D

var igt = 0.0 #symbolizes time

var autoSaveTime = 0.0

var hospitalValues = {}

var miningValues = {
	"selectedDuck" = "",
	"duckMiningStartTime" = 0,
	"miniGameStartTimer" = 0
}

var foodItems = {}

var spentDictionary = {}

var money = 1000.0

var timeLeftRanch = 0

var Duckies: Dictionary = {}

var musicSwitch = ""

func _ready() -> void:
	loadingData()
	self.add_child(AudioStreamPlayer.new())
	self.get_child(0)
	self.get_child(0).play()
	self.get_child(0).volume_db = -4

func savingData():
	#Saves all save data to json files after grabbing data.
	if testArena != null:
		if testArena.name == "TestArena" && testArena.find_child("Ducks").find_child("XyzAbc") != null:
			return
		
		if testArena.find_child("Ducks"):
			for x in testArena.get_child(0).get_children():
				x.defineSelfDictionary()
				Duckies.set(x.name, x.selfDictionary)
					
		var file = FileAccess.open("user://Ducks.json", FileAccess.WRITE)
		file.store_var(Duckies.duplicate_deep())
		file.close()
		
		file = FileAccess.open("user://MiningValues.json", FileAccess.WRITE)
		file.store_var(miningValues.duplicate_deep())
		file.close()
		
		file = FileAccess.open("user://Spent.json", FileAccess.WRITE)
		file.store_var(spentDictionary.duplicate_deep())
		file.close()

		file = FileAccess.open("user://FoodItems.json", FileAccess.WRITE)
		file.store_var(foodItems.duplicate_deep())
		file.close()
		
		file = FileAccess.open("user://HospitalValues.json", FileAccess.WRITE)
		file.store_var(hospitalValues.duplicate_deep())
		file.close()
		
		file = FileAccess.open("user://SaveData.json", FileAccess.WRITE)
		var saveData = {
			"igt" = igt,
			"money" = money,
			"timeLeftRanch" = timeLeftRanch
		}
		file.store_var(saveData.duplicate_deep())
		file.close()

func loadingData():
	#Loads data from 5 json files if found.
	if FileAccess.file_exists("user://Ducks.json"):
		var file = FileAccess.open("user://Ducks.json", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		Duckies = data.duplicate()
	
	if FileAccess.file_exists("user://HospitalValues.json"):
		var file = FileAccess.open("user://HospitalValues.json", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		if data is Dictionary:
			hospitalValues = data.duplicate()
		else:
			printerr("Something is wrong with data: " + str(data))
	
	if FileAccess.file_exists("user://MiningValues.json"):
		var file = FileAccess.open("user://MiningValues.json", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		if data is Dictionary:
			miningValues = data.duplicate()
		else:
			printerr("Something is wrong with data: " + str(data))
	
	if FileAccess.file_exists("user://Spent.json"):
		var file = FileAccess.open("user://Spent.json", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		if data is Dictionary:
			spentDictionary = data.duplicate()
		else:
			printerr("Something is wrong with data: " + str(data))
		
	if FileAccess.file_exists("user://FoodItems.json"):
		var file = FileAccess.open("user://FoodItems.json", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		if data is Dictionary:
			foodItems = data.duplicate()
		else:
			printerr("Something is wrong with data: " + str(data))
	
	if FileAccess.file_exists("user://SaveData.json"):
		var file = FileAccess.open("user://SaveData.json", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		if data is Dictionary:
			igt = data.get("igt")
			money = data.get("money")
			timeLeftRanch = data.get("timeLeftRanch")
		else:
			printerr("Something is wrong with data: " + str(data))
			
func deleteSaveData():
	DirAccess.open("user://").remove("SaveData.json")
	DirAccess.open("user://").remove("FoodItems.json")
	DirAccess.open("user://").remove("Ducks.json")
	DirAccess.open("user://").remove("Spent.json")
	DirAccess.open("user://").remove("MiningValues.json")
	DirAccess.open("user://").remove("HospitalValues.json")
	foodItems = {}
	Duckies = {}
	spentDictionary = {}
	miningValues = {
		"selectedDuck" : "",
		"duckMiningStartTime" : 0,
		"miniGameStartTimer" : 0
	}
	hospitalValues = {}
	money = 1000
	igt = 0
	timeLeftRanch = 0

func _process(delta: float) -> void:
	if self.get_parent().get_children().size() == 2 && self.get_parent().get_child(1).name != "Starting Screen":
		igt += delta
	
	#Autosave system
	if autoSaveTime >= 0:
		autoSaveTime += delta
	else:
		autoSaveTime = 0
		
	if autoSaveTime > 100:
		savingData()
		autoSaveTime -= 100
	
	if self.get_child(0).is_playing() == false:
		self.get_child(0).play()
	
	if self.get_parent().get_children().size() == 2 && self.get_parent().get_child(1).name == "Mines":
		if musicSwitch == "" || musicSwitch != "mines":
			self.get_child(0).stream = load("res://Sounds/hot bassline .wav")
			musicSwitch = "mines"
	elif self.get_parent().get_children().size() == 2 && self.get_parent().get_child(1).name == "TestArena":
		if musicSwitch == "" || musicSwitch != "hub":
			self.get_child(0).stream = load("res://Sounds/base Theme.wav")
			musicSwitch = "hub"
	elif self.get_parent().get_children().size() == 2 && self.get_parent().get_child(1).name == "Starting Screen":
		if musicSwitch == "" || musicSwitch != "mainMenu":
			self.get_child(0).stream = load("res://Sounds/slow jazz.wav")
			musicSwitch = "mainMenu"
