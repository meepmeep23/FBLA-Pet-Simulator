extends TabContainer

@export var maxTabs = 1

var colorOption1: Color
var colorOption2: Color
var colorOption3: Color

var colorAlternateOption1: Color
var colorAlternateOption2: Color
var colorAlternateOption3: Color

var maleChoice = true 
var hasGeneratedColors = false 

var maleBodyColor: Color
var maleBeakColor: Color

var femaleBodyColor: Color
var femaleBeakColor: Color

var maleInputText = true
var maleName: String
var femaleName: String

var firstTime = false 
var hasReadIntroduction = false

"""
This Script is primarily used for the starting tutorial.
"""


func _process(_delta: float) -> void:
	#Generates color options for the two starting ducks
	if hasGeneratedColors == false:
		colorOption1 = Color.from_hsv(randf(),randf(),randf())
		colorOption2 = Color.from_hsv(randf(),randf(),randf())
		colorOption3 = Color.from_hsv(randf(),randf(),randf())
		colorAlternateOption1 = Color.from_hsv(randf(),randf(),randf())
		colorAlternateOption2 = Color.from_hsv(randf(),randf(),randf())
		colorAlternateOption3 = Color.from_hsv(randf(),randf(),randf())
		
		$"First Duck Selection/Panel/DuckBody".modulate = colorOption1
		$"First Duck Selection/Panel2/DuckBody".modulate = colorOption2
		$"First Duck Selection/Panel3/DuckBody".modulate = colorOption3
		
		$"First Duck Selection/Panel/DuckWing".modulate = Color.from_hsv(colorOption1.h,colorOption1.s,colorOption1.v - 0.2)
		$"First Duck Selection/Panel2/DuckWing".modulate = Color.from_hsv(colorOption2.h,colorOption2.s,colorOption2.v - 0.2)
		$"First Duck Selection/Panel3/DuckWing".modulate = Color.from_hsv(colorOption3.h,colorOption3.s,colorOption3.v - 0.2)
		
		$"First Duck Selection/Panel/DuckBeak".modulate = colorAlternateOption1
		$"First Duck Selection/Panel2/DuckBeak".modulate = colorAlternateOption2
		$"First Duck Selection/Panel3/DuckBeak".modulate = colorAlternateOption3
		
		hasGeneratedColors = true
	
	if current_tab == 0:
		position.x = 1920
		if Input.is_action_just_pressed("escape"):
			current_tab = 5
			position.x = 0
	else:
		position.x = 0
	
	#If it is the player's first time, start tutorial, otherwise, allow tabs to switch with 'Tab'.
	if firstTime == false:
		if Input.is_action_just_pressed("escape") && current_tab == 1:
			current_tab = 0
	
	else:
		if hasReadIntroduction == true:
			if maleChoice == true:
				$"First Duck Selection/RichTextLabel".text = "Choose Your Male Starter Duck!"
			else:
				$"First Duck Selection/RichTextLabel".text = "Choose Your Female Starter Duck!"
		else:
			current_tab = 3
			

func _on_option_1_pressed() -> void:
	"""
	On left option pressed, check for which gender is being picked
	Set the random colors on the gendered duck,
	if male, change the choice to female
	if female, save the data and change to the renaming tab
	"""
	if maleChoice == true:
		print("MaleSelected")
		maleBodyColor = colorOption1
		maleBeakColor = colorAlternateOption1
		maleChoice = false
		hasGeneratedColors = false
	else:
		print("FemaleSelected")
		femaleBodyColor = colorOption1
		femaleBeakColor = colorAlternateOption2
		
		changeTheDucksColorsToNewColors()
		saveDataValues.savingData()
		current_tab = 4

func _on_option_2_pressed() -> void:
	"""
	On middle option pressed, check for which gender is being picked
	Set the random colors on the gendered duck,
	if male, change the choice to female
	if female, save the data and change to the renaming tab
	"""
	if maleChoice == true:
		print("MaleSelected")
		maleBodyColor = colorOption2
		maleBeakColor = colorAlternateOption2
		maleChoice = false
		hasGeneratedColors = false
	else:
		print("FemaleSelected")
		femaleBodyColor = colorOption2
		femaleBeakColor = colorAlternateOption2
		
		changeTheDucksColorsToNewColors()
		saveDataValues.savingData()
		current_tab = 4

func _on_option_3_pressed() -> void:
	"""
	On right option pressed, check for which gender is being picked
	Set the random colors on the gendered duck,
	if male, change the choice to female
	if female, save the data and change to the renaming tab
	"""
	if maleChoice == true:
		print("MaleSelected")
		maleBodyColor = colorOption3
		maleBeakColor = colorAlternateOption3
		maleChoice = false
		hasGeneratedColors = false
	else:
		print("FemaleSelected")
		femaleBodyColor = colorOption3
		femaleBeakColor = colorAlternateOption3
		
		changeTheDucksColorsToNewColors()
		saveDataValues.savingData()
		current_tab = 4

func _on_continue_pressed() -> void:
	#Continue to the Duck selection tab, could probably be merged into a different function
	current_tab = 2
	hasReadIntroduction = true

func _on_line_edit_text_submitted(new_text: String) -> void:
	"""
	If the text inputted isn't empty, set the name of the appropriate starting duck to be the inputted text
	*If inputting male text, it will switch everything to female so that can be inputted next
	*If inputting female text, it will set both duck's default values, save the data, switch the tab to the ranching tab, and finish the tutorial
	*If the text is empty or already taken, it will show an error and clear the text.
	"""
	#Error with numbers.
	for c in new_text:
		for v in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']:
			if c == v:
				$"Naming Your New Ducks!/LineEdit".text = ""
				$"Naming Your New Ducks!/LineEdit".add_theme_color_override("font_placeholder_color", Color(1,0,0))
				$"Naming Your New Ducks!/LineEdit".placeholder_text = "Error: There must not be numbers in name."
				return
	
	if new_text == "":
		$"Naming Your New Ducks!/LineEdit".placeholder_text = "Error: Name can't be empty."
		$"Naming Your New Ducks!/LineEdit".text = ""
		$"Naming Your New Ducks!/LineEdit".add_theme_color_override("font_placeholder_color", Color(1,0,0))

	if new_text == "XyzAbc":
		$"Naming Your New Ducks!/LineEdit".placeholder_text = "Error: You shouldn't pick this name."
		$"Naming Your New Ducks!/LineEdit".text = ""
		$"Naming Your New Ducks!/LineEdit".add_theme_color_override("font_placeholder_color", Color(1,0,0))
	
	if new_text == maleName:
		$"Naming Your New Ducks!/LineEdit".placeholder_text = "Error: no duplicate names."
		$"Naming Your New Ducks!/LineEdit".text = ""
		$"Naming Your New Ducks!/LineEdit".add_theme_color_override("font_placeholder_color", Color(1,0,0))
		
	
	#This is a special case to make sure that the name isn't "XyzAbc" which is the default name of the starting ducks.
	if new_text != "" && new_text != "XyzAbc"  && new_text != maleName:
		$"Naming Your New Ducks!/LineEdit".add_theme_color_override("font_placeholder_color", Color(1,1,1))
		if maleInputText == true:
			maleName = new_text
			$"Naming Your New Ducks!/LineEdit".text = ""
			$"Naming Your New Ducks!/LineEdit".placeholder_text = "Input your female duck's name here:"
			maleInputText = false
		else:
			femaleName = new_text
			
			#Setup default values when successful. 
			self.get_parent().find_child("Ducks").get_child(0).renameDuck(maleName)
			self.get_parent().find_child("Ducks").get_child(1).renameDuck(femaleName)

			self.get_parent().find_child("Ducks").get_child(0).position = Vector3(-5,0,0)
			self.get_parent().find_child("Ducks").get_child(1).position = Vector3(5,0,0)
			
			self.get_parent().find_child("Ducks").get_child(0).wasChild = false
			self.get_parent().find_child("Ducks").get_child(1).wasChild = false
			
			self.get_parent().find_child("Ducks").get_child(0).visible = true
			self.get_parent().find_child("Ducks").get_child(1).visible = true
			
			self.get_parent().find_child("Ducks").get_child(0).age = 7
			self.get_parent().find_child("Ducks").get_child(1).age = 7
			
			self.get_parent().find_child("Ducks").get_child(0).food = 100
			self.get_parent().find_child("Ducks").get_child(1).food = 100
			
			self.get_parent().find_child("Ducks").get_child(0).find_child("CollisionShape3D").disabled = false
			self.get_parent().find_child("Ducks").get_child(1).find_child("CollisionShape3D").disabled = false
			
			saveDataValues.savingData()
			current_tab = 0
			firstTime = false

func changeTheDucksColorsToNewColors():
	#Change the starting ducks colors to be the colors that were picked.
	self.get_parent().find_child("Ducks").get_child(0).female = false
	self.get_parent().find_child("Ducks").get_child(0).bodyColor = maleBodyColor
	self.get_parent().find_child("Ducks").get_child(0).hue = maleBodyColor.h
	self.get_parent().find_child("Ducks").get_child(0).saturation = maleBodyColor.s
	self.get_parent().find_child("Ducks").get_child(0).value = maleBodyColor.v
	self.get_parent().find_child("Ducks").get_child(0).beakColor = maleBeakColor
	self.get_parent().find_child("Ducks").get_child(0).beakHue = maleBeakColor.h
	self.get_parent().find_child("Ducks").get_child(0).beakSaturation = maleBeakColor.s
	self.get_parent().find_child("Ducks").get_child(0).beakValue = maleBeakColor.v
	self.get_parent().find_child("Ducks").get_child(0).wingColor = Color.from_hsv(maleBodyColor.h,maleBodyColor.s,maleBodyColor.v - 0.2)
	self.get_parent().find_child("Ducks").get_child(0).refreshDuckColors()
	
	self.get_parent().find_child("Ducks").get_child(1).female = true
	self.get_parent().find_child("Ducks").get_child(1).bodyColor = femaleBodyColor
	self.get_parent().find_child("Ducks").get_child(1).hue = femaleBodyColor.h
	self.get_parent().find_child("Ducks").get_child(1).saturation = femaleBodyColor.s
	self.get_parent().find_child("Ducks").get_child(1).value = femaleBodyColor.v
	self.get_parent().find_child("Ducks").get_child(1).beakColor = femaleBeakColor
	self.get_parent().find_child("Ducks").get_child(1).beakHue = femaleBeakColor.h
	self.get_parent().find_child("Ducks").get_child(1).beakSaturation = femaleBeakColor.s
	self.get_parent().find_child("Ducks").get_child(1).beakValue = femaleBeakColor.v
	self.get_parent().find_child("Ducks").get_child(1).wingColor = Color.from_hsv(femaleBodyColor.h,femaleBodyColor.s,femaleBodyColor.v - 0.2)
	self.get_parent().find_child("Ducks").get_child(1).refreshDuckColors()

#Makes the game think the colors aren't generated yet so it just redoes it
func _on_reroll_pressed() -> void:
	hasGeneratedColors = false

func _on_store_exit_pressed() -> void:
	if current_tab == 1:
		current_tab = 0
		$Store/StoreTab.current_tab = 0

func _on_f_button_pressed() -> void:
	Input.action_press("F")

func _on_f_button_button_up() -> void:
	Input.action_release("F")
