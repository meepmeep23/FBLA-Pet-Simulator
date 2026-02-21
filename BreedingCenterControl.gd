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
		
		for c in $Ui/LineEdit.text:
			for v in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']:
				if c == v:
					$Ui/LineEdit.text = ""
					$Ui/LineEdit.placeholder_text = "Error: There must not be numbers in name."
					return
		
		for n in saveDataValues.Duckies:
			if n == $Ui/LineEdit.text:
				babyNameIsAnotherName = true
		
		if maleGenetics != null && femaleGenetics != null && $Ui/LineEdit.text != null && $Ui/LineEdit.text != "" && babyNameIsAnotherName == false && saveDataValues.money >= 500:
			for x in maleGenetics:
				if maleGenetics.get(x) is bool:
					var r = randi_range(0,1)
					if r == 1:
						babyGenetics.set(x, true)
					if r == 0:
						babyGenetics.set(x, false)
						
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
				
				if maleGenetics.get(x) is int:
					if maleGenetics.get(x) > femaleGenetics.get(x):
						babyGenetics.set(x, randi_range(femaleGenetics.get(x), maleGenetics.get(x)))
					else:
						babyGenetics.set(x, randi_range(maleGenetics.get(x), femaleGenetics.get(x)))
				
			#Set variables of the baby that shouldn't be mixed

			babyGenetics.set("age", 0)
			babyGenetics.set("cost", 0)
			babyGenetics.set("holiness", 0)
			babyGenetics.set("intelligence", 1)
			babyGenetics.set("strength", 1)
			babyGenetics.set("flyingHeight", 1)
			babyGenetics.set("health", 10)
			babyGenetics.set("tiredness", 10)
			babyGenetics.set("lifeLength", 20)
			babyGenetics.set("overallSize", 1)
			babyGenetics.set("food", 100)
			
			saveDataValues.Duckies.set($Ui/LineEdit.text, babyGenetics)
			
			saveDataValues.money -= 500
			
			if saveDataValues.spentDictionary.get("Baby Breeding Cost") != null:
				saveDataValues.spentDictionary.set("Baby Breeding Cost", saveDataValues.spentDictionary.get("Baby Breeding Cost") - 500)
			else:
				saveDataValues.spentDictionary.set("Baby Breeding Cost", -500)
			
			$Ui/Money.text = "$" + str(saveDataValues.money)
			
			Duckies = saveDataValues.Duckies
			
			var ducky = falseDuck.instantiate()
			ducky.name = $Ui/LineEdit.text
			ducky.position.x = randf_range(-5,5)
			ducky.position.z = randf_range(-5,5)
			ducky = ducky.duplicate()
			get_child(0).add_child(ducky,true)
			
			#Delete Text So There Aren't Any "Accidents"
			$Ui/LineEdit.text = ""
		
		else:
			#Errors with names / money.
			$Ui/LineEdit.text = ""
			if $Ui/LineEdit.text == null:
				$Ui/LineEdit.placeholder_text = "Error: There is no name for the baby."
			if babyNameIsAnotherName == true:
				$Ui/LineEdit.placeholder_text = "Error: Baby must have a unique name."
			if saveDataValues.money < 500:
				$Ui/LineEdit.placeholder_text = "Error: You may or may not be broke..."
	else:
		#Error with male / female not being selected
		$Ui/LineEdit.text = ""
		if male == null:
			$Ui/LineEdit.placeholder_text = "Error: There is no male selected."
		if female == null:
			$Ui/LineEdit.placeholder_text = "Error: There is no female selected."
