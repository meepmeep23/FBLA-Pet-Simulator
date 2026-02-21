extends TabContainer

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

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for x in saveDataValues.Duckies:
		if saveDataValues.Duckies.get(x).get("age") >= 7:
			$"Duck Selection/DuckList".add_item(x + "    " + str(saveDataValues.Duckies.get(x).get("strength") * (saveDataValues.Duckies.get(x).get("timesMined") / 5 + 1)).pad_decimals(2))
	
	if saveDataValues.miningValues.get("MiningValue") != null && saveDataValues.miningValues.get("MiningValue") != 0:
		miningValue = saveDataValues.miningValues.get("MiningValue")
	else:
		saveDataValues.miningValues.set("MiningValue", 0)
	
	saveDataValues.miningValues.set("MiningTime", miningTime)
	
	if saveDataValues.miningValues.get("duckMiningStartTime") != 0:
		current_tab = 1
	else:
		current_tab = 0

func _process(_delta: float) -> void:
	if saveDataValues.miningValues.get("selectedDuck") != "":
		$"Duck Selection/Continue".visible = true
	var timeSpentInMine = saveDataValues.igt - saveDataValues.miningValues.get("duckMiningStartTime")
	if current_tab == 1:
		$ReturnTimer/ReturnTime.text = saveDataValues.miningValues.get("selectedDuck") + " will return in " + str(miningTime - timeSpentInMine).pad_decimals(1) + " seconds."
	
	if timeSpentInMine >= miningTime && saveDataValues.miningValues.get("duckMiningStartTime") != 0 && current_tab != 2:
		$ObtainMinerals/ReturnTime.text = saveDataValues.miningValues.get("selectedDuck") + " has returned with many resources!"
		current_tab = 2
		obtainedMinerals = {}
		for x in MineralList:
			var profit = MineralList.get(x) * randf() * miningValue
			if profit >= 0.7:
				obtainedMinerals.set(x, round(profit))
		
		for x in obtainedMinerals:
			$ObtainMinerals/ItemList.add_item(str(obtainedMinerals.get(x)) + " " + x)
	
func _on_duck_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	saveDataValues.miningValues.set("selectedDuck", $"Duck Selection/DuckList".get_item_text(index).remove_chars("1234567890. "))
	miningValue = 2 * saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).get("strength") * (saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).get("timesMined") / 5 + 1)
	saveDataValues.miningValues.set("MiningValue", miningValue)
	
func _on_continue_pressed() -> void:
	if saveDataValues.miningValues.get("selectedDuck") != "":
		current_tab = current_tab + 1
		saveDataValues.miningValues.set("duckMiningStartTime", saveDataValues.igt)
		saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).set("timesMined", saveDataValues.Duckies.get(saveDataValues.miningValues.get("selectedDuck")).get("timesMined") + 1)
		self.get_parent().find_child("ErrorText").visible = false
	else:
		self.get_parent().find_child("ErrorText").visible = true
		self.get_parent().find_child("ErrorText").text = "Error: No Duck Selected"

func _on_collect_pressed() -> void:
	current_tab = 0
	saveDataValues.miningValues.set("duckMiningStartTime", 0)
	saveDataValues.miningValues.set("selectedDuck", "")
	$ObtainMinerals/ItemList.clear()
	for x in obtainedMinerals:
		if saveDataValues.miningValues.get(x) != null:
			saveDataValues.miningValues.set(x, saveDataValues.miningValues.get(x) + obtainedMinerals.get(x))
		else:
			saveDataValues.miningValues.set(x, obtainedMinerals.get(x))
	saveDataValues.savingData()
