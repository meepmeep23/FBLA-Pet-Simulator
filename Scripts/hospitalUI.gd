extends TabContainer

var rng = RandomNumberGenerator.new()
var mat = preload("res://Materials/mat.tres")
var rightLimit = -2

@onready var bed = preload("res://Objects/bed.tscn")

#Fix for mouse locking
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	$"Duck Checkup/Money Label".text = "$" + str(saveDataValues.money)

	#Moving camera left and right while in the hospital
	if current_tab == 3 && saveDataValues.hospitalValues.size() > 0:
		if Input.is_action_pressed("A"):
			$"ViewDucks/3D/Camera3D".position.z += delta * 5
			$"ViewDucks/3D/Camera3D".position.z = clamp($"ViewDucks/3D/Camera3D".position.z, rightLimit, 1)
		if Input.is_action_pressed("D"):
			$"ViewDucks/3D/Camera3D".position.z -= delta * 5
			$"ViewDucks/3D/Camera3D".position.z = clamp($"ViewDucks/3D/Camera3D".position.z, rightLimit, 1)
		for d in $"ViewDucks/3D/Beds".get_children(): if is_instance_valid(d):
			print(d)
			d.find_child("SubViewport").get_child(0).find_child("Name").text = d.name
			var timeLeft = saveDataValues.hospitalValues.get(d.name).get("timeEntered") + saveDataValues.hospitalValues.get(d.name).get("timeTillLeave") - saveDataValues.igt
			d.find_child("SubViewport").get_child(0).find_child("Time").text = str(timeLeft).pad_decimals(2)
			if timeLeft < 0:
				saveDataValues.hospitalValues.erase(d.name)
				loadDucksForViewer()
	else:
		$"ViewDucks/3D".visible = false

func _on_order_a_checkup_pressed() -> void:
	#Sets the tab to checkup tab and adds ducks that aren't a child, in the mine, or in the hospital
	current_tab = 1
	$"Duck Checkup/Possible Ducks To Check On".clear()
	#Ducks in list can't be mining, younger than 7, or already in hospital
	for d in saveDataValues.Duckies:
		if saveDataValues.Duckies.get(d).age >= 7:
			if d != saveDataValues.miningValues.get("selectedDuck") || saveDataValues.igt - saveDataValues.miningValues.get("duckMiningStartTime") >= 100: 
				if saveDataValues.hospitalValues.get(d) == null || saveDataValues.hospitalValues.get(d).get("inHospital") == false:
					$"Duck Checkup/Possible Ducks To Check On".add_item(d)

func _on_possible_ducks_to_check_on_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	#When duck gets picked to get a checkup on, will subtract $50, and add to the hospital bill in spentDictionary. Then will check if the duck is sick, if not will be tested negative
	#Now if the duck is sick, it will setup the test results and they will come back positive with a disease based on the severity of the duck's sickness. 
	var duck = $"Duck Checkup/Possible Ducks To Check On".get_item_text(index)
	if saveDataValues.money >= 50:
		saveDataValues.money -= 50
		
		if saveDataValues.spentDictionary.get("Hospital Bill") == null:
			saveDataValues.spentDictionary.set("Hospital Bill", -50)
		else:
			saveDataValues.spentDictionary.set("Hospital Bill", saveDataValues.spentDictionary.get("Hospital Bill") - 50)
			
		if saveDataValues.hospitalValues.get(duck) == null:
			current_tab = 2
			$"Results/Body Text".text = "Your Duck's test results have come back..............
			[color=Green] Negative! [/color]
			Your Duck has been returned to your ranch. Bye!"
		if saveDataValues.hospitalValues.get(duck) != null:
			
			"""
			Disease List:
			
			common cold
			
			Strep
			Flu
			
			Anemia
			Tuberculosis
			
			Measles
			Cancer
			
			"""
			
			current_tab = 2
			var condition = ""
			var costOfCare = 0
			if saveDataValues.hospitalValues.get(duck).healthCondition == "Mild Cold":
				condition = "the Common Cold."
				costOfCare = 75

			#Lines 88 - 119 all set the test results to be the right level of sickness, then randomly selects a disease from that severity
			if saveDataValues.hospitalValues.get(duck).healthCondition == "Sick":
				var r = rng.randf()
				#Strep
				#Flu
				if r < 0.5:
					condition = "Strep"
					costOfCare = 100
				if r >= 0.5:
					condition = "Flu"
					costOfCare = 100
			
			if saveDataValues.hospitalValues.get(duck).healthCondition == "Bedridden Sick":
				var r = rng.randf()
				#Anemia
				#Tuberculosis
				if r < 0.5:
					condition = "Anemia"
					costOfCare = 500
				if r >= 0.5:
					condition = "Tuberculosis"
					costOfCare = 500
			if saveDataValues.hospitalValues.get(duck).healthCondition == "Deathly Sick":
				var r = rng.randf()
				#Measles
				#Cancer
				if r < 0.5:
					condition = "Measles"
					costOfCare = 1000
				if r >= 0.5:
					condition = "Cancer"
					costOfCare = 1000

			#Puts duck in hospital and sets the time entered so that when the time passes the right time, the duck can leave
			saveDataValues.hospitalValues.get(duck).set("inHospital", true)
			saveDataValues.hospitalValues.get(duck).set("timeEntered", saveDataValues.igt)

			#Subtracts the right cost and adds it to the hospital bill in spentDictionary
			saveDataValues.money -= costOfCare
			if saveDataValues.spentDictionary.get("Hospital Bill") == null:
				saveDataValues.spentDictionary.set("Hospital Bill", -costOfCare)
			else:
				saveDataValues.spentDictionary.set("Hospital Bill", saveDataValues.spentDictionary.get("Hospital Bill") + costOfCare)

			#Visuals for the test results
			$"Results/Body Text".text = "You Duck's test results have come back..............
			[color=Red] Positive for " + condition + "[/color]
			Your Duck has been placed under our care, and you have been charged a fine of [color=Red] $" + str(costOfCare) + "[/color]."

func _on_view_ducks_pressed() -> void:
	loadDucksForViewer()

func loadDucksForViewer():
	#Puts ducks visuals correctly and sets up the beds that they lie in.
	mat = mat.duplicate()
	$"ViewDucks/3D".visible = true
	
	current_tab = 3
	
	var amountOfDucks = 0

	#Empties the ducks beds just in case there are leftover ducks
	if $"ViewDucks/3D/Beds".get_child_count() > 0:
		for b in $"ViewDucks/3D/Beds".get_children():
			b.free()

	#loops through the hospital values and if they are in the hospital it will setup the beds based on the duck's values
	for d in saveDataValues.hospitalValues:
		if saveDataValues.hospitalValues.get(d).get("inHospital") == true:
			#sets the duck bed position to be the right location, and makes bandaid visible if duck is injured
			var duck = bed.instantiate()
			duck.position.x = amountOfDucks * -7
			duck.find_child("Duck Body")
			var HC = saveDataValues.Duckies.get(d).get("healthCondition")
			if HC == "Injured" || HC == "Severely Injured" || HC == "Sprained Ankle":
				duck.find_child("Bandaid").visible = true

			#Gets the color of the duck
			var hue = saveDataValues.Duckies.get(d).get("hue")
			var saturation = saveDataValues.Duckies.get(d).get("saturation")
			var value = saveDataValues.Duckies.get(d).get("value")

			#Sets the color of the duck to the colors it got
			var bodyColor = Color.from_hsv(hue, saturation, value)
			var beakColor = Color.from_hsv(saveDataValues.Duckies.get(d).get("beakHue"), saveDataValues.Duckies.get(d).get("beakSaturation"), saveDataValues.Duckies.get(d).get("beakValue"))
			mat.set_albedo(bodyColor)
			duck.get_child(1).material_override = mat.duplicate()
			mat.set_albedo(beakColor)
			duck.get_child(6).material_override = mat.duplicate()
			amountOfDucks += 1
			duck.name = d
			$"ViewDucks/3D/Beds".add_child(duck)

	#Specific offsets for the right wall so the wall doesn't overflow
	
	rightLimit = amountOfDucks * -7 + 5
	
	$"ViewDucks/3D/Right Wall".position.z = amountOfDucks * -7 - 0.5
