extends Node

var testArena: Node3D

var igt = 0 #symbolizes time

var autoSaveTime = 0

var miningValues = {
	"selectedDuck" = "",
	"duckMiningStartTime" = 0
}

var tournamentTeam = {}

var foodItems = {}

var spentDictionary = {}

var money = 10000.0

var Duckies: Dictionary = {}

func _ready() -> void:
	loadingData()

func savingData():
	#Saves all save data to json files after grabbing data.
	if testArena != null:
		if testArena.name == "TestArena" && testArena.find_child("Ducks").find_child("XyzAbc") != null:
			return
		
		if testArena.find_child("Ducks"):
			for x in testArena.get_child(0).get_child_count():
				testArena.get_child(0).get_child(x).defineSelfDictionary()
				Duckies.set(testArena.get_child(0).get_child(x).name, testArena.get_child(0).get_child(x).selfDictionary)
					
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
		
		file = FileAccess.open("user://SaveData.json", FileAccess.WRITE)
		var saveData = {
			"igt" = igt,
			"money" = money
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
		else:
			printerr("Something is wrong with data: " + str(data))
			
			
func deleteSaveData():
	DirAccess.open("user://").remove("SaveData.json")
	DirAccess.open("user://").remove("FoodItems.json")
	DirAccess.open("user://").remove("Ducks.json")
	DirAccess.open("user://").remove("Spent.json")
	DirAccess.open("user://").remove("MiningValues.json")
	foodItems = {}
	Duckies = {}
	spentDictionary = {}
	miningValues = {
		"selectedDuck" : "",
		"duckMiningStartTime" : 0
	}
	money = 10000
	igt = 0

func _process(delta: float) -> void:
	igt += delta
	#Autosave system
	if autoSaveTime >= 0:
		autoSaveTime += delta
	else:
		autoSaveTime = 0
		
	if autoSaveTime > 100:
		savingData()
		autoSaveTime -= 100
