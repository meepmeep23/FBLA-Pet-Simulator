extends ItemList

var selected = false
@export var female: bool #Used for setting the itemList to only catch one gender


func _ready() -> void:
	#Removes the test item, and sets up the duck list depending on gender.
	remove_item(0)
	for x in saveDataValues.Duckies:
		print(x)
		print(saveDataValues.Duckies.get(x).get("female"))
		if saveDataValues.Duckies.get(x).get("female") == true:
			if female == true && saveDataValues.Duckies.get(x).get("age") >= 6:
				add_item(x)
		if saveDataValues.Duckies.get(x).get("female") == false:
			if female == false && saveDataValues.Duckies.get(x).get("age") >= 6:
				add_item(x)

func _process(_delta: float) -> void:
	#I really have no idea what this does because pressing 'E' was never used for it, but removing it break something. ¯\_(ツ)_/¯
	if has_focus() == true && Input.is_action_just_pressed("E"):
		for x in self.get_parent().get_child_count():
			get_child(x).selected = false
		selected = true

func _on_item_selected(index: int) -> void:
	#Reads selection
	if female == true:
		self.get_parent().get_parent().get_parent().female = get_item_text(index)
		
	if female == false:
		self.get_parent().get_parent().get_parent().male = get_item_text(index)
