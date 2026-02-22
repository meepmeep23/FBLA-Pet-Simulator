extends TabContainer

var rng = RandomNumberGenerator.new()

@export var miningTime: float

var MineralList = {
	Gold = 0.75,
	Iron = 3,
	Emerald = 0.5,
	Coal = 4,
	Diamond = 0.2,
	Silver = 1.2,
	Ruby = 0.3,
	Copper = 2,
	Quartz = 1.75,
	Amethyst = 0.5
}

var miningValue: float
var obtainedMinerals: Dictionary

var miniGameCount = 0
var inMiniGame = false

var leftValue = 0
var middleValue = 0
var rightValue = 0

func _ready():
	#Sets mouse mode to visible to avoid issues with ranch invisible mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	setUpListOfDucks()
	
	#Sets up mining value
	if saveDataValues.miningValues.get("MiningValue") != null && saveDataValues.miningValues.get("MiningValue") != 0:
		miningValue = saveDataValues.miningValues.get("MiningValue")
	else:
		saveDataValues.miningValues.set("MiningValue", 0)
	
	saveDataValues.miningValues.set("MiningTime", miningTime)
	
	#If a duck is already mining go to waiting menu
	if saveDataValues.miningValues.get("duckMiningStartTime") != 0:
		current_tab = 1
	else:
		current_tab = 0
	

func _process(delta: float) -> void:
	miniGameBehavior(delta)
	
	if saveDataValues.miningValues.get("selectedDuck") != "":
		$"Duck Selection/Continue".visible = true
	
	
	var timeSpentInMine = saveDataValues.igt - saveDataValues.miningValues.get("duckMiningStartTime")
	
	#Sets up waiting label
	if current_tab == 1:
		$ReturnTimer/ReturnTime.text = saveDataValues.miningValues.get("selectedDuck") + " will return in " + str(miningTime - timeSpentInMine).pad_decimals(1) + " seconds."
	
	#If duck is done mining, make tab collection tab, set up obtained minerals, set up list
	if timeSpentInMine >= miningTime && saveDataValues.miningValues.get("duckMiningStartTime") != 0 && current_tab != 2:
		obtainMinerals()
		

func miniGameBehavior(delta):
	if current_tab != 1:
		inMiniGame = false
		saveDataValues.miningValues.set("miniGameStartTimer", saveDataValues.igt)
	
	miniGameCount = saveDataValues.igt - saveDataValues.miningValues.get("miniGameStartTimer")
		
	#Starts Minigame when 30 seconds have passed while waiting
	if miniGameCount >= 30 && inMiniGame == false:
		$"ReturnTimer/MiniGame Options".visible = true
		inMiniGame = true
		#makes one tunnel be +, one be -, and one be nothing.
		leftValue = rng.randi_range(-1,1)
		middleValue = rng.randi_range(-1,1)
		if middleValue == leftValue:
			middleValue += 1
			if middleValue == 2:
				middleValue = -1
		
		#Loops rightValue to be whatever left and middle aren't
		rightValue = -2
		for x in 3:
			rightValue += 1
			if rightValue != leftValue && rightValue != middleValue:
				return
		
	elif miniGameCount < 30:
		inMiniGame = false
		$"ReturnTimer/MiniGame Options".visible = false
		
	if inMiniGame == true:
		self.get_parent().find_child("OmniLight3D").position.y = move_toward(get_parent().find_child("OmniLight3D").position.y, 2, delta * 4)
	else:
		self.get_parent().find_child("OmniLight3D").position.y = move_toward(get_parent().find_child("OmniLight3D").position.y, 15, delta * 4)
	
func _on_duck_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	
	var selection_array = $"Duck Selection/DuckList".get_item_text(index).split(":", false, 0)
	saveDataValues.miningValues.set("selectedDuck", selection_array[0])
	
	miningValue = 2 * saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).get("strength") * (saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).get("timesMined") / 5 + 1)
	saveDataValues.miningValues.set("MiningValue", miningValue)
	
func _on_continue_pressed() -> void:
	if saveDataValues.miningValues.get("selectedDuck") != "":
		current_tab = current_tab + 1
		saveDataValues.miningValues.set("duckMiningStartTime", saveDataValues.igt)
		saveDataValues.miningValues.set("miniGameStartTimer", saveDataValues.igt)
		saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).set("timesMined", saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).get("timesMined") + 1)
		self.get_parent().find_child("ErrorText").visible = false
	else:
		self.get_parent().find_child("ErrorText").visible = true
		self.get_parent().find_child("ErrorText").text = "Error: No Duck Selected"

func _on_collect_pressed() -> void:
	#Sets up duck options list
	$"Duck Selection/DuckList".clear()
	
	setUpListOfDucks()
	
	#Reset a bunch of things
	current_tab = 0
	saveDataValues.miningValues.set("duckMiningStartTime", 0)
	saveDataValues.miningValues.set("selectedDuck", "")
	$ObtainMinerals/ReturnTime.text = "Your duck has returned with many resources!"
	
	#Add Minerals to MiningValues
	$ObtainMinerals/ItemList.clear()
	for x in obtainedMinerals:
		if saveDataValues.miningValues.get(x) != null:
			saveDataValues.miningValues.set(x, saveDataValues.miningValues.get(x) + obtainedMinerals.get(x))
		else:
			saveDataValues.miningValues.set(x, obtainedMinerals.get(x))
	saveDataValues.savingData()

func _on_option_1_pressed() -> void:
	if inMiniGame == true:
		miniGameOptionPicked(leftValue)
		
func _on_option_2_pressed() -> void:
	if inMiniGame == true:
		miniGameOptionPicked(middleValue)
		
func _on_option_3_pressed() -> void:
	if inMiniGame == true:
		miniGameOptionPicked(rightValue)

func obtainMinerals():
	current_tab = 2
	obtainedMinerals = {}
	for x in MineralList:
		var profit = MineralList.get(x) * rng.randf() * miningValue
		if profit >= 0.7:
			obtainedMinerals.set(x, round(profit))
	
	for x in obtainedMinerals:
		$ObtainMinerals/ItemList.add_item(str(obtainedMinerals.get(x)) + " " + x)

func duckGotInjured():
	var duck = saveDataValues.miningValues.get("selectedDuck")
	saveDataValues.hospitalValues.set(duck, {
		"timeTillLeave" : 120,
		"timeEntered" : saveDataValues.igt,
		"healthCondition" : "Sprained Ankle",
		"inHospital" : true
	})
	saveDataValues.money -= 200
	if saveDataValues.spentDictionary.get("Hospital Bill") == null:
		saveDataValues.spentDictionary.set("Hospital Bill", -200)
	else:
		saveDataValues.spentDictionary.set("Hospital Bill", saveDataValues.spentDictionary.get("Hospital Bill") - 200)
		
	saveDataValues.miningValues.set("selectedDuck", "")
	obtainMinerals()
	$ObtainMinerals/ReturnTime.text = "[color=Red]Duck Was Injured....[/color]"
	saveDataValues.miningValues.set("miniGameStartTimer", saveDataValues.igt)
	$ReturnTimer/MiniGameSoundEffects.play()

func miniGameOptionPicked(pathChosen: int):
	var v = randf()
	if pathChosen == 0:
		saveDataValues.miningValues.set("duckMiningStartTime", saveDataValues.miningValues.get("duckMiningStartTime") + 30 * v)
		$"ReturnTimer/Effect Animation".play("effect fade in")
		$"ReturnTimer/Effect Label".text = "[color=Red]+ " + str(round(30 * v)) + " seconds"
		saveDataValues.miningValues.set("miniGameStartTimer", saveDataValues.igt)
	
	if pathChosen == 1:
		miningValue += v
		saveDataValues.miningValues.set("MiningValue", miningValue)
		$"ReturnTimer/Effect Animation".play("effect fade in")
		$"ReturnTimer/Effect Label".text = "[color=Green]+ " + str(v).pad_decimals(2) + " value"
		saveDataValues.miningValues.set("miniGameStartTimer", saveDataValues.igt)
	
	if pathChosen == -1:
		duckGotInjured()
	
	if pathChosen != -1 && pathChosen != 0 && pathChosen != 1:
		printerr("Minigame error: Value Incompatible")

func setUpListOfDucks():
	#Only ducks over 7 years old and not in hospital can be on the list
	for x in saveDataValues.Duckies:
		if saveDataValues.Duckies.get(x).get("age") >= 7:
			if saveDataValues.hospitalValues.get(x) == null || saveDataValues.hospitalValues.get(x).get("inHospital") == false:
				$"Duck Selection/DuckList".add_item(x + ":   " + str(saveDataValues.Duckies.get(x).get("strength") * (saveDataValues.Duckies.get(x).get("timesMined") / 5 + 1)).pad_decimals(2))
