extends Control

var exportText = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.get_parent().find_child("CostViewer").get_child(0).position.y = self.get_parent().find_child("CostViewer").find_child("VScrollBar").value * -10 + 31

func _on_resume_pressed() -> void:
	self.get_parent().current_tab = 0

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_help_pressed() -> void:
	self.get_parent().current_tab = 7

#Sets Up Cost Viewer Tab
func _on_cost_viewer_pressed() -> void:
	exportText = ""
	
	var foodText = ""
	var spentOnFood = 0
	var miningText = ""
	var gainedFromMining = 0
	var breedingText = ""
	var hospitalText = ""
	
	var costViewer = self.get_parent().find_child("CostViewer")
	costViewer.get_child(0).find_child("BreedingList").clear()
	costViewer.get_child(0).find_child("FoodList").clear()
	costViewer.get_child(0).find_child("MiningList").clear()
	costViewer.get_child(0).find_child("HospitalList").clear()
	
	var totalP = 0
	var totalN = 0
	var total = 0
	
	self.get_parent().current_tab = 6
	for s in saveDataValues.spentDictionary:
		if saveDataValues.spentDictionary.get(s) > 0:
			totalP += saveDataValues.spentDictionary.get(s)
		else:
			totalN -= saveDataValues.spentDictionary.get(s)
		
		if isAny(s, ["Watermelon", "Sunflower", "Nuts", "Bread", "Grapes", "Peas", "Peppers", "Vaccine"]) == true:
			costViewer.get_child(0).find_child("FoodList").add_item(s + " : " + str(saveDataValues.spentDictionary.get(s)))
			foodText += s + ":" + str(saveDataValues.spentDictionary.get(s)) + "\n"
			spentOnFood += saveDataValues.spentDictionary.get(s)
		if isAny(s, ["Gold", "Emerald", "Coal", "Iron", "Diamond", "Silver", "Ruby", "Copper", "Quartz", "Amethyst"]) == true:
			costViewer.get_child(0).find_child("MiningList").add_item(s + " : " + str(saveDataValues.spentDictionary.get(s)))
			miningText += s + ":" + str(saveDataValues.spentDictionary.get(s)) + "\n"
			gainedFromMining += saveDataValues.spentDictionary.get(s)
	
	costViewer.get_child(0).find_child("HospitalList").add_item(str(saveDataValues.spentDictionary.get("Hospital Bill")))
	if saveDataValues.spentDictionary.get("Hospital Bill") != null:
		hospitalText += "Hospital Bills:" + str(saveDataValues.spentDictionary.get("Hospital Bill")) + "\n"
	
	costViewer.get_child(0).find_child("BreedingList").add_item(str(saveDataValues.spentDictionary.get("Baby Breeding Cost")))
	if saveDataValues.spentDictionary.get("Baby Breeding Cost") != null:
		breedingText += "Baby Breeding Cost:" + str(saveDataValues.spentDictionary.get("Baby Breeding Cost"))
	
	total = totalP - totalN
	
	exportText += "-----------------\n Total spent on Food: $" + str(-spentOnFood).pad_decimals(0) + "\n-----------------\n" + foodText
	exportText += "-----------------\n Total gained from Mining: $" + str(gainedFromMining).pad_decimals(0) + "\n-----------------\n" + miningText
	exportText += "-----------------\n" + breedingText + "\n-----------------\n"
	exportText += hospitalText + "-----------------\n"
	
	exportText += "\n \n +" + str(totalP) + "\n " + str(-totalN) + "\n Total: " + str(total)
	
	#Sets the 'Total' text to 'positive total(in green) + negative total(in red) = total
	costViewer.find_child("Total").text = "[color=Green]" + str(totalP) + "[/color] - [color=Red]" + str(totalN) + "[/color] = " + str(total)
	
#This function finds if the value is equal to anything in the array
func isAny(value, list: Array):
	for v in list:
		if value == v:
			return true

func _on_return_pressed() -> void:
	self.get_parent().current_tab = 5

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/starting_screen.tscn")

func _on_export_text_file_pressed() -> void:
	
	
	var file = FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/exportedMoney.txt", FileAccess.WRITE)
	file.store_string(exportText)
