extends ItemList

var selected = false
@export var female: bool #Used for setting the itemList to only catch one gender


func _ready() -> void:
	#Removes the test item, and sets up the duck list depending on gender.
	remove_item(0)
	for d in saveDataValues.Duckies:
		if saveDataValues.Duckies.get(d).get("female") == true:
			if female == true && saveDataValues.Duckies.get(d).get("age") >= 7:
				if d != saveDataValues.miningValues.get("selectedDuck") || saveDataValues.igt - saveDataValues.miningValues.get("duckMiningStartTime") >= 100: 
					if saveDataValues.hospitalValues.get(d) == null || saveDataValues.hospitalValues.get(d).get("inHospital") == false:
						add_item(d)
		
		if saveDataValues.Duckies.get(d).get("female") == false:
			if female == false && saveDataValues.Duckies.get(d).get("age") >= 7:
				if d != saveDataValues.miningValues.get("selectedDuck") || saveDataValues.igt - saveDataValues.miningValues.get("duckMiningStartTime") >= 100: 
					if saveDataValues.hospitalValues.get(d) == null || saveDataValues.hospitalValues.get(d).get("inHospital") == false:
						add_item(d)

func _on_item_selected(index: int) -> void:
	#Reads selection
	if female == true:
		self.get_parent().get_parent().get_parent().female = get_item_text(index)
		
	if female == false:
		self.get_parent().get_parent().get_parent().male = get_item_text(index)
