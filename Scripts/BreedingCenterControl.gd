extends Node3D


var male: String
var female: String

var Duckies
var hasCheckedDucks = false
@onready var falseDuck = preload("res://Objects/breedingCenterFalseDuck.tscn")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Ui/Money.text = "$" + str(saveDataValues.money)

func _process(_delta: float) -> void:
	saveDataValues.testArena = self
	Duckies = saveDataValues.Duckies
	if hasCheckedDucks == false && Duckies != {}:
		for x in Duckies:
			print(x)
			var ducky = falseDuck.instantiate()
			ducky.name = x
			if saveDataValues.Duckies.get(x).get("age") > 7:
				ducky.visible = false
			ducky.position.x = randf_range(-5,5)
			ducky.position.z = randf_range(-5,5)
			ducky = ducky.duplicate()
			self.get_child(0).add_child(ducky,true)
		hasCheckedDucks = true

func _on_breed_button_pressed() -> void:
	"""
	When the breed button is pressed, take the genetics of the parent ducks and create a baby duck with genetics somewhere in between
	*Checks to make sure that the user has enough money (500)
	*Also checks to make sure the baby's name isn't already taken by another duck or is empty.
	*If breeding works, it will save the data and clear the text.
	If breeding doesn't work, nothing will happen.
	"""

	if male != null && female != null:
		var maleGenetics = saveDataValues.Duckies.get(male)
		var femaleGenetics = saveDataValues.Duckies.get(female)
		var babyGenetics = {}
		var babyNameIsAnotherName = false

		#Error checking
		for c in $Ui/LineEdit.text:
			for v in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']:
				if c == v:
					$Ui/LineEdit.add_theme_color_override("font_placeholder_color", Color(1,0,0))
					$Ui/LineEdit.text = ""
					$Ui/LineEdit.placeholder_text = "Error: There must not be numbers in name."
					return
		
		print("pass 1")
		
		for c in $Ui/LineEdit.text:
			if c == " ":
				$Ui/LineEdit.add_theme_color_override("font_placeholder_color", Color(1,0,0))
				$Ui/LineEdit.text = ""
				$Ui/LineEdit.placeholder_text = "Error: There must not be a space in name."
				return
		
		print("pass 2")
		
		for n in saveDataValues.Duckies:
			if n == $Ui/LineEdit.text:
				$Ui/LineEdit.add_theme_color_override("font_placeholder_color", Color(1,0,0))
				$Ui/LineEdit.text = ""
				$Ui/LineEdit.placeholder_text = "Error: Baby must have a unique name."
				return
		
		print("pass 3")
		
		if $Ui/LineEdit.text == "":
			$Ui/LineEdit.add_theme_color_override("font_placeholder_color", Color(1,0,0))
			$Ui/LineEdit.placeholder_text = "Error: There is no name for the baby."
			$Ui/LineEdit.text = ""
			return
		
		print("pass 4")
		
		if saveDataValues.money < 500:
			$Ui/LineEdit.add_theme_color_override("font_placeholder_color", Color(1,0,0))
			$Ui/LineEdit.placeholder_text = "Error: You may or may not be broke..."
			$Ui/LineEdit.text = ""
			return
		
		print("pass 5")

		#If passes all the checks check again ig, I probably should've removed this
		if maleGenetics != null && femaleGenetics != null && $Ui/LineEdit.text != null && $Ui/LineEdit.text != "" && babyNameIsAnotherName == false && saveDataValues.money >= 500:

			#Loops through all of the male's stats to give stats to the baby
			for x in maleGenetics:
				#If the stat is a boolean generate a random boolean
				if maleGenetics.get(x) is bool:
					var r = randi_range(0,1)
					if r == 1:
						babyGenetics.set(x, true)
					if r == 0:
						babyGenetics.set(x, false)

				#If the stat is a float, generate a random float in betweeen the adult's numbers unless it is one of the hues because the in between number is different
				if maleGenetics.get(x) is float:
					if x == "hue" || x == "beakHue":
						var difference = maleGenetics.get(x) - femaleGenetics.get(x)
						if abs(difference) > 0.5:
							if difference > 0:
								difference -= 0.5
							if difference < 0:
								difference += 0.5
						babyGenetics.set(x, maleGenetics.get(x) + difference * randf() * 2)
						print("difference:")
						print(str(difference))
						print("baby " + x)
						print(str(babyGenetics.get(x)))
					
					else:
						if maleGenetics.get(x) > femaleGenetics.get(x):
							babyGenetics.set(x, randf_range(femaleGenetics.get(x), maleGenetics.get(x)))
						else:
							babyGenetics.set(x, randf_range(maleGenetics.get(x), femaleGenetics.get(x)))

				#If the stat is an integer, generate an integer in between the parent's stats
				if maleGenetics.get(x) is int:
					if maleGenetics.get(x) > femaleGenetics.get(x):
						babyGenetics.set(x, randi_range(femaleGenetics.get(x), maleGenetics.get(x)))
					else:
						babyGenetics.set(x, randi_range(maleGenetics.get(x), femaleGenetics.get(x)))
			
			#Sick parents will make sick babies
			if saveDataValues.hospitalValues.get(male) != null || saveDataValues.hospitalValues.get(female):
				babyGenetics.set("baseHealthiness", move_toward(babyGenetics.get("baseHealthiness"), 0, 0.1))
			
			#Set variables of the baby that shouldn't be randomly generated

			babyGenetics.set("age", 0)
			babyGenetics.set("strength", 1)
			babyGenetics.set("health", 10)
			babyGenetics.set("tiredness", 10)
			babyGenetics.set("overallSize", 1)
			babyGenetics.set("food", 100)
			babyGenetics.set("foodQuality", 1)
			
			saveDataValues.Duckies.set($Ui/LineEdit.text, babyGenetics)


			#Subtract money by $500
			saveDataValues.money -= 500

			#Set the spendDictionary value to be 500 less
			if saveDataValues.spentDictionary.get("Baby Breeding Cost") != null:
				saveDataValues.spentDictionary.set("Baby Breeding Cost", saveDataValues.spentDictionary.get("Baby Breeding Cost") - 500)
			else:
				saveDataValues.spentDictionary.set("Baby Breeding Cost", -500)
			
			$Ui/Money.text = "$" + str(saveDataValues.money)
			
			Duckies = saveDataValues.Duckies

			#Setup a new "falseDuck" to represent the baby in the nursery
			var ducky = falseDuck.instantiate()
			ducky.name = $Ui/LineEdit.text
			ducky.position.x = randf_range(-5,5)
			ducky.position.z = randf_range(-5,5)
			ducky = ducky.duplicate()
			get_child(0).add_child(ducky,true)
			$Ui/LineEdit.placeholder_text = "Name Your Baby Here"
			$Ui/LineEdit.add_theme_color_override("font_placeholder_color", Color(0.58, 0.58, 0.58, 1.0))
			
			#Delete Text So There Aren't Any "Accidents"
			$Ui/LineEdit.text = ""
		
	else:
		#Error with male / female not being selected
		$Ui/LineEdit.text = ""
		if male == null:
			$Ui/LineEdit.placeholder_text = "Error: There is no male selected."
		if female == null:
			$Ui/LineEdit.placeholder_text = "Error: There is no female selected."
