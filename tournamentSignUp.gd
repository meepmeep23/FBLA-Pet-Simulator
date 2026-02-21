extends Control

var option1: String
var option2: String
var option3: String
var option4: String
var option5: String
var option6: String

var optionBeingSelected = -1

var mouseInsideList = false

var teamName = ""

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click") && $DuckList.visible == true && mouseInsideList == false:
		$DuckList.visible = false
		optionBeingSelected = -1
	
	if Input.is_action_just_pressed("escape"):
		for b in 6:
			self.get_child(b).text = ""
		self.get_parent().openTab = 0

func _on_duck_list_mouse_entered() -> void:
	mouseInsideList = true

func _on_duck_list_mouse_exited() -> void:
	mouseInsideList = false

func on_button_pressed(buttonPressed: int):
	$DuckList/VBoxContainer/DuckList.clear()
	$DuckList.position = get_viewport().get_mouse_position()
	$DuckList.visible = true
	optionBeingSelected = buttonPressed
	for x in saveDataValues.Duckies:
		var unique = true
		print(x)
		for y in 6:
			if self.get_child(y).text == x:
				unique = false
			print(str(y) + ", " + str(unique))
		if unique == true:
			if saveDataValues.Duckies.get(x).get("age") >= 7:
				$DuckList/VBoxContainer/DuckList.add_item(x)
	$DuckList/VBoxContainer/DuckList.add_item("erase")

func _on_duck_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	if $DuckList/VBoxContainer/DuckList.get_item_text(index) != "erase":
		self.get_child(optionBeingSelected).text = $DuckList/VBoxContainer/DuckList.get_item_text(index)
	else:
		self.get_child(optionBeingSelected).text = ""
	$DuckList.visible = false
	
	option1 = $"0".text
	option2 = $"1".text
	option3 = $"2".text
	option4 = $"3".text
	option5 = $"4".text
	option6 = $"5".text

#All of these functions just go to the other button fuction with what button was pressed saved
func _on__pressed() -> void:
	on_button_pressed(0)

func _on_1_pressed() -> void:
	on_button_pressed(1)

func _on_2_pressed() -> void:
	on_button_pressed(2)

func _on_3_pressed() -> void:
	on_button_pressed(3)

func _on_4_pressed() -> void:
	on_button_pressed(4)

func _on_5_pressed() -> void:
	on_button_pressed(5)

#Once text gets submitted, the scene will change to the start of the tournament. 
func _on_continue_text_submitted(new_text: String) -> void:
	teamName = new_text
	var TeamComposition = {
		name = teamName,
		swimmer = option1,
		sprinter = option2,
		climber = option3,
		flyer = option4,
		magician = option5,
		sumo = option6
	}
	saveDataValues.tournamentTeam = TeamComposition
	get_tree().change_scene_to_file("res://Scenes/TournamentStart.tscn")
