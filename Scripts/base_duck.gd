extends CharacterBody3D

#Logic Values

var mat = preload("res://Materials/mat.tres")
var shadowMat = preload("res://Materials/shadowMat.tres")

var angerEyes = preload("res://Models & Textures/angryEye.tres")
var baseEyes = preload("res://Models & Textures/eye.tres")
var sadEyes = preload("res://Models & Textures/sadEye.tres")

var rand = RandomNumberGenerator.new()
var i = 0
var direction: Vector2

var selfDictionary: Dictionary

var state = "think"

var mouseInside = false
var selected = false

var hasPolished = false


#Genetic Values:

#Stats
var female = false

var strengthPotential: float
var baseHealthiness: float
var speed: float
var metabolismSpeed: float
var luck: float

#Cosmetic
var bodyColor: Color
var wingColor: Color
var beakColor: Color

var hue: float
var tempHue: float
var saturation: float
var tempSaturation: float
var value: float

var beakHue: float
var beakSaturation: float
var beakValue: float

#Emotions
var angerSense: float
var sadSense: float

var anger: float
var sad: float

#Non-Genetic Values

var age = 0.0
var strength: float
var overallSize: float
var food = 100

var size = 1
var timesMined: int

var wasChild = false #Used for making duck spawn in when done
var wasInMine = false #Used for making duck spawn when exiting mine
var wasInHospital = false #Used for making duck spawn when exiting hospital

var foodList = []
var foodQuality = 1.0
var timeWOFood = 0 #Used for visualizing the time, instead of subtracting from nutrition
var nutrition = 1

var sickOdds = 0.0
var overallHealth = 10.0
var addedDiseasePrevention = 0.0
var numOfVacBought = 0 #Number of Vaccines Bought
var healthCondition = ""

var timeToCheckDuck = 0
var sicknessCheckTime = 20

"""
Whenever you want to add a new value to the save data, you need to follow these steps:
	*Set up the variable
	*Put the variable down in the defineSelfDictionary function
	*If there is no save data, what should the variable be?
	*Lastly add all the functionality you need for the variable
"""

func _ready() -> void:
	#Debugging checks to solve errors and to check if duck isn't here. 
	connect("mouse_entered", _on_mouse_entered)
	print("connected1")
	connect("mouse_exited", _on_mouse_exited)
	print("connected2")
	self.find_child("3D Selection Gui").texture = self.find_child("SubViewport").get_texture()
	food = 100
	sicknessCheckTime = randf_range(10,40)
	timeToCheckDuck = saveDataValues.igt + sicknessCheckTime

#Uses for polishing the ducks values on loading.
func getDuckyPolished():
	"""
	If the duck is new, assign random genetics,
	otherwise, load genetics from the save node.

	Now that the genetics are set, 
	match the materials on the duck to the genetics.

	Save the duck's values to the dictionary for the save node. 
	"""

	#Genetic Loading/Generating
	if saveDataValues.Duckies == {} || saveDataValues.Duckies.size() < 2:
		print("NewSave")
		var randGender = randi_range(0,1)
		if randGender == 1:
			female = false
		if randGender == 0:
			female = true
		
		strengthPotential = randf() + 0.1
		baseHealthiness = randf()
		speed = randf_range(0.33,3)
		metabolismSpeed = (strengthPotential + speed) / 2
		luck = randf_range(0,7)
		
		hue = randf()
		tempHue = hue
		saturation = randf()
		value = randf()
		beakHue = randf()
		beakSaturation = randf()
		beakValue = randf()
		
		angerSense = randf()
		sadSense = randf()
		
		age = 0.8
		overallSize = 1
		
		anger = 0
		sad = 0
		foodQuality = 0.5
		
		timesMined = 0
	
	else:
		for x in saveDataValues.Duckies.get(self.name):
			set(x, saveDataValues.Duckies.get(self.name).get(x))
	
	#Fixing Materials, can't use the function because of the way genetics are loaded by 3 values and not 1 color.
	var meshes = self.get_child(0)
	bodyColor = Color.from_hsv(tempHue, tempSaturation, value, 255)
	
	mat = mat.duplicate()
	mat.set_albedo(bodyColor)
	
	meshes.get_child(0).material_override = mat.duplicate()
	meshes.get_child(7).material_override = mat.duplicate()
	
	
	wingColor = Color.from_hsv(tempHue, tempSaturation, value - 0.2, 255)
	
	mat = mat.duplicate()
	mat.set_albedo(wingColor)
	
	meshes.get_child(2).material_override = mat.duplicate()
	meshes.get_child(3).material_override = mat.duplicate()
	
	
	beakColor = Color.from_hsv(beakHue,beakSaturation,beakValue,255)
	
	mat = mat.duplicate()
	mat.set_albedo(beakColor)
	
	meshes.get_child(4).material_override = mat.duplicate()
	
	shadowMat = shadowMat.duplicate()
	meshes.get_child(1).material_override = shadowMat
	meshes.get_child(8).material_override = shadowMat
	meshes.get_child(9).material_override = shadowMat
	meshes.get_child(10).material_override = shadowMat
	meshes.get_child(11).material_override = shadowMat
	meshes.get_child(12).material_override = shadowMat
	
	var timeGone = saveDataValues.igt - saveDataValues.timeLeftRanch
	
	if timeWOFood > 0:
		timeWOFood = timeWOFood + timeGone
	
	food = food - (metabolismSpeed * timeGone)
	
	nutrition = ((foodQuality + food / 100) * 5) / (timeWOFood + 1)
	
	if saveDataValues.hospitalValues.get(self.name) != null:
		healthCondition = saveDataValues.hospitalValues.get(self.name).get("healthCondition")
	
	defineSelfDictionary()
	
	hasPolished = true
	
func _physics_process(delta: float) -> void:
	#Checking to see if should be there or not
	if saveDataValues.miningValues.get("selectedDuck") == name && saveDataValues.igt - saveDataValues.miningValues.get("duckMiningStartTime") < saveDataValues.miningValues.get("MiningTime"):
		if wasInMine == false:
			self.visible = false
			self.find_child("CollisionShape3D").disabled = true
			wasInMine = true
		food = 30
	#If was not here, but now is out of mine, is now not in mine and plays an animation
	else:
		if wasInMine == true && wasInHospital == false:
			self.visible = true
			self.find_child("CollisionShape3D").disabled = false
			$AnimationPlayer.play("Walk Out Of Mine")
			wasInMine = false
			saveDataValues.miningValues.selectedDuck = ""
	
	#Checking to see if should be there or not, just like mining, but for hospital instead
	if saveDataValues.hospitalValues.get(self.name) != null && saveDataValues.hospitalValues.get(self.name).get("inHospital") == true:
		if wasInHospital == false:
			self.visible = false
			self.find_child("CollisionShape3D").disabled = true
			wasInHospital = true
		food = 100
	#If was not here, but is now not in hospital and plays an animation
	if saveDataValues.hospitalValues.get(self.name) != null &&  saveDataValues.hospitalValues.get(self.name).get("timeEntered") + saveDataValues.hospitalValues.get(self.name).get("timeTillLeave") < saveDataValues.igt:
		saveDataValues.hospitalValues.erase(self.name)
		self.visible = true
		self.find_child("CollisionShape3D").disabled = false
		$AnimationPlayer.play("Walk Out Of Hospital")
		wasInHospital = false
	
	strength = strengthPotential
	$"3D Selection Gui/SubViewport/Ui Parent/Name".text = self.name
	
	#Sets position on floor so no weird collisions make them fly,
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	#Used on start to set up the duck when it gets spawned in.
	if self.get_parent().get_parent().hasCheckedDucks == true && hasPolished == false:
		getDuckyPolished()
	
	ageBehavior(delta)
	selectionBehavior()
	foodBehavior(delta)
	movementCheck()
	emotionBehavior()
	move_and_slide()

#This Function Also has healthSetUp(), move(), think(), and turn() inside.
func ageBehavior(delta):
	if get_parent().get_parent().find_child("UI Main").firstTime == false:
		age += delta * 0.1
	
	$"3D Selection Gui/SubViewport/Ui Parent/Age".text = str(age).pad_decimals(2)
	
	if age < 7:
		self.visible = false
		size = 0.3
		velocity.x = 0
		velocity.z = 0
		$CollisionShape3D.disabled = true
		wasChild = true
	
	if age > 7:
		healthSetUp(delta)
		if wasChild == true:
			wasChild = false
			self.visible = true
			$AnimationPlayer.play("Walk Out Of Breeding Center")
			velocity.x = 0
			velocity.z = 0
			$CollisionShape3D.disabled = false
			state = "think"
		if $AnimationPlayer.current_animation != "Walk Out Of Breeding Center" && $AnimationPlayer.current_animation != "Walk Out Of Mine" && $AnimationPlayer.current_animation != "Walk Out Of Hospital":
			move(delta)
			think()
			turn(delta)
		
		scale = Vector3(size,size,size)
	size = overallSize

#This function handles almost all food related behaviors.
func foodBehavior(delta):
	get_child(3).get_child(0).get_child(0).get_child(0).value = food #Makes food progress bar equal to how full the duck is.
	
	if food > 0 && age > 1:
		#Will make the duck lose extra food if mildly sick
		if healthCondition != "":
			food -= metabolismSpeed * delta
		food -= metabolismSpeed * delta
		nutrition = ((foodQuality + food / 100) * 5)
	elif age < 1:
		food = 100
		nutrition = 10
	else:
		food = 0
		
		if sadSense > angerSense:
			sad += delta * (1 + sadSense)
		else:
			anger += delta * (1 + angerSense)
		
		timeWOFood += delta
		nutrition = -timeWOFood / 50

func fed(foodType: String):
	if saveDataValues.foodItems.get(foodType) != null && saveDataValues.foodItems.get(foodType) > 0:
		saveDataValues.foodItems.set(foodType, saveDataValues.foodItems.get(foodType) - 1)
		$"Quack Sound".stop()
		$"Quack Sound".play()
		if foodType == "Bread":
			food += 20
			saturation -= 0.005
			refreshDuckColors()
		if foodType == "Peas":
			food += 20
		if foodType == "Watermelon":
			food += 100
			overallSize += 0.02
		if foodType == "Peppers":
			food += 30
			speed += 0.02
		if foodType == "Sunflower":
			food += 5
			value += 0.005
			refreshDuckColors()
		if foodType == "Nuts":
			food += 25
			strengthPotential += 0.02
		if foodType == "Grapes":
			food += 30
			saturation += 0.005
			refreshDuckColors()
		if foodType == "Vaccine":
			numOfVacBought += 1
			addedDiseasePrevention += (1 - (baseHealthiness + addedDiseasePrevention)) / 4
			if healthCondition == "Mild Cold":
				healthCondition = ""
			
			if sadSense > angerSense:
				sad -= 5
			else:
				anger -= 5
			
			return
		
		foodList.append(foodType)
		if foodList.size() > 5:
			foodList.remove_at(0)
		
		var tempFoodList = []
		var foodUsed = false
		var tempFoodQuality = 1
		
		for f in foodList:
			if f == "Bread":
				tempFoodQuality -= 0.05
			for t in tempFoodList:
				if f == t:
					foodUsed = true
			if foodUsed == true:
				tempFoodQuality -= 0.1
				foodUsed = false
			else:
				tempFoodList.append(f)
		
		foodQuality = tempFoodQuality
	
	if sadSense > angerSense:
		sad -= 5
	else:
		anger -= 5
	
	timeWOFood = 0
	
	if food > 100:
		food = 100

#Health Values and getting sick/hurt
func healthSetUp(delta):
	overallHealth = (nutrition + (baseHealthiness + addedDiseasePrevention) * 10) / 2
	sickOdds = 200 * (0.5 ** overallHealth)
	if saveDataValues.igt > timeToCheckDuck && get_parent().get_parent().find_child("UI Main").firstTime == false:
		if healthCondition == "" || healthCondition == "Scratched Up" || healthCondition == "Mild Cold":
			sicknessCheckTime = randf_range(10,40)
			timeToCheckDuck = saveDataValues.igt + sicknessCheckTime
			if saveDataValues.spentDictionary.get("Hospital Bill") == null:
				saveDataValues.spentDictionary.set("Hospital Bill", 0)
			if rand.randf() * 100 < sickOdds:
				print("Something Happened...")
				if wasInMine == false:
					if overallHealth < 3:
						healthCondition = "Deathly Sick"
						saveDataValues.hospitalValues.set(self.name, {
							"timeTillLeave" : 300,
							"timeEntered" : saveDataValues.igt,
							"severity" : 3,
							"healthCondition" : healthCondition,
							"inHospital" : false
						})
						
					if overallHealth > 3:
						healthCondition = "Bedridden Sick"
						saveDataValues.hospitalValues.set(self.name, {
							"timeTillLeave" : 180,
							"timeEntered" : saveDataValues.igt,
							"severity" : 2,
							"healthCondition" : healthCondition,
							"inHospital" : false
						})
						
					if overallHealth > 6:
						healthCondition = "Sick"
						saveDataValues.hospitalValues.set(self.name, {
							"timeTillLeave" : 120,
							"timeEntered" : saveDataValues.igt,
							"severity" : 1,
							"healthCondition" : healthCondition,
							"inHospital" : false
						})
						
					if overallHealth > 8:
						healthCondition = "Mild Cold"
			else:
				healthCondition = ""
	if healthCondition == "":
		tempHue = hue
		tempSaturation = tempSaturation
	if healthCondition == "Mild Cold":
		tempHue = move_toward(tempHue, 0.34, delta / 100)
		tempSaturation = move_toward(tempSaturation, 1, delta / 100)
		refreshDuckColors()
		
		if sadSense > angerSense:
			sad += delta * sadSense
		else:
			anger += delta * angerSense
		
	if healthCondition == "Sick":
		tempHue = move_toward(tempHue, 0.34, delta / 50)
		tempSaturation = move_toward(tempSaturation, 1, delta / 50)
		refreshDuckColors()
		
		if sadSense > angerSense:
			sad += delta * (0.5 + sadSense)
		else:
			anger += delta * (0.5 + angerSense)
		
	if healthCondition == "Bedridden Sick":
		tempHue = move_toward(tempHue, 0.2, delta / 25)
		tempSaturation = move_toward(tempSaturation, 1, delta / 25)
		refreshDuckColors()
		
		if strengthPotential >= 0:
			strengthPotential -= strengthPotential * delta
		else:
			strengthPotential = 0
		
		if sadSense > angerSense:
			sad += delta * (0.75 + sadSense)
		else:
			anger += delta * (0.75 + angerSense)
		
	if healthCondition == "Deathly Sick":
		tempHue = move_toward(tempHue, 0.2, delta / 10)
		tempSaturation = move_toward(tempSaturation, 1, delta / 10)
		refreshDuckColors()
		
		if strengthPotential >= 0:
			strengthPotential -= 0.004 * delta
		else:
			strengthPotential = 0
		
		if sadSense > angerSense:
			sad += delta * (1 + sadSense)
		else:
			anger += delta * (1 + angerSense)

#Behaviors / statChanges that are caused by emotions
func emotionBehavior():
	if anger > 10:
		find_child("Ducky Meshes").find_child("Right Eye").mesh = angerEyes
		find_child("Ducky Meshes").find_child("Right Eye").get_child(0).position = Vector3(0.289, 0.15, 0.183)
		find_child("Ducky Meshes").find_child("Left Eye").mesh = angerEyes
		find_child("Ducky Meshes").find_child("Left Eye").get_child(0).position = Vector3(0.332, 0.174, 0.191)
	elif sad > 10:
		find_child("Ducky Meshes").find_child("Right Eye").mesh = sadEyes
		find_child("Ducky Meshes").find_child("Right Eye").get_child(0).position = Vector3(0.394, 0.15, -0.177)
		find_child("Ducky Meshes").find_child("Left Eye").mesh = sadEyes
		find_child("Ducky Meshes").find_child("Left Eye").get_child(0).position = Vector3(-0.358, 0.174, 0)
	else:
		find_child("Ducky Meshes").find_child("Right Eye").mesh = baseEyes
		find_child("Ducky Meshes").find_child("Right Eye").get_child(0).position = Vector3(0.439, 0.15, -0.402)
		find_child("Ducky Meshes").find_child("Left Eye").mesh = baseEyes
		find_child("Ducky Meshes").find_child("Left Eye").get_child(0).position = Vector3(-0.363, 0.174, -0.454)

#This function handles all the behavior of selecting Ducks.
func selectionBehavior():
	#Can't change selection state of ducks if feeding panel is open
	if get_parent().get_parent().find_child("Feed Panel").visible == false:
		#Makes the Duck selected when you click on it, and checks to make sure that no other duck is selected. 
		if mouseInside == true && Input.is_action_just_pressed("click"):
			for x in self.get_parent().get_child_count():
				if get_parent().get_child(x).selected == true:
					selected = false
			selected = true
		
		#If you click off the Duck & the food panel isn't open, the duck is no longer selected. 
		if mouseInside == false && Input.is_action_just_pressed("click"):
			selected = false
	
	#If the duck is selected the border around the duck will be white, and if 'F' is pressed, the feed panel will be come visible. 
	if selected == true:
		$"3D Selection Gui".visible = true
		$"3D Selection Gui/SubViewport/Ui Parent/Healthiness".text = str(overallHealth).pad_decimals(2)
		self.get_child(0).get_child(1).material_override.albedo_color = Color(255,255,255,255)
		if Input.is_action_just_pressed("F"):
			self.get_parent().get_parent().find_child("Feed Panel").visible = true
			self.get_parent().get_parent().find_child("Feed Panel").position = get_viewport().get_mouse_position()
			self.get_parent().get_parent().find_child("Feed Panel").get_child(0).get_child(0).get_child(0).Duck = self
		
	if selected == false:
		$"3D Selection Gui".visible = false
		self.get_child(0).get_child(1).material_override.albedo_color = Color(0,0,0,255)

func movementCheck():
	var raycast = self.find_child("Raycasts")
	
	for r in raycast.get_children():
		if r.is_colliding() == true:
			state = "think"

func move(delta):
	#Moves the duck in the direction for 2.5 seconds
	if state == "move":
		if i < 2.5:
			$AnimationPlayer.play("Walk")
			i += delta * speed
		
		if i >= 2.5:
			i = 0
			state = "think"
			
		
		velocity.x = direction.x * speed
		velocity.z = direction.y * speed

func think():
	"""
	The Duck stops moving, and picks the new direction to move in.
	Uses basic trigonometry to set the rotation of the duck's raycasts towards the direction to make sure it is a valid direction.
	"""
	if state == "think":
		$AnimationPlayer.play("Idle")
		direction = Vector2(rand.randf_range(-3,3), rand.randf_range(-3,3))
		velocity.x = 0
		velocity.z = 0
		
		if direction.x > 0:
			$Raycasts.rotation.y = acos(direction.y / sqrt(direction.y ** 2 + direction.x ** 2))
		if direction.x < 0:
			$Raycasts.rotation.y = -acos(direction.y / sqrt(direction.y ** 2 + direction.x ** 2))
		
		i = 0
		state = "turn"

func turn(delta):
	"""
	Uses basic trigonometry to turn the duck towards the direction its velocity is pointing
	"""
	if state == "turn":
		var initAngle = get_child(0).rotation.y
		if direction.y != 0 || direction.x != 0:
			if direction.x > 0:
				get_child(0).rotation.y = move_toward(get_child(0).rotation.y, acos(direction.y / sqrt(direction.y ** 2 + direction.x ** 2)), delta * speed)
			if direction.x < 0:
				get_child(0).rotation.y = move_toward(get_child(0).rotation.y, -acos(direction.y / sqrt(direction.y ** 2 + direction.x ** 2)), delta * speed)
			self.get_child(1).rotation.y = self.get_child(0).rotation.y
			
		if initAngle == get_child(0).rotation.y:
			state = "move"

func _on_mouse_entered() -> void:
	mouseInside = true

func _on_mouse_exited() -> void:
	mouseInside = false

func defineSelfDictionary():
	"""
	Sets the duck's dictionary do its current values so that when the saving system uses it, it has the right values.
	"""
	selfDictionary.set("age", age)
	selfDictionary.set("female", female)
	selfDictionary.set("hue", hue)
	selfDictionary.set("tempHue", hue)
	selfDictionary.set("saturation", saturation)
	selfDictionary.set("tempSaturation", tempSaturation)
	selfDictionary.set("value", value)
	selfDictionary.set("beakHue", beakHue)
	selfDictionary.set("beakSaturation", beakSaturation)
	selfDictionary.set("beakValue", beakValue)
	selfDictionary.set("speed", speed)
	selfDictionary.set("overallSize", overallSize)
	selfDictionary.set("food", food)
	selfDictionary.set("anger", anger)
	selfDictionary.set("angerSense", angerSense)
	selfDictionary.set("sad", sad)
	selfDictionary.set("sadSense", sadSense)
	selfDictionary.set("timesMined", timesMined)
	selfDictionary.set("strengthPotential", strengthPotential)
	selfDictionary.set("strength", strength)
	
	selfDictionary.set("foodList", foodList)
	selfDictionary.set("foodQuality", foodQuality)
	selfDictionary.set("metabolismSpeed", metabolismSpeed)
	selfDictionary.set("baseHealthiness", baseHealthiness)
	selfDictionary.set("foodQuality", foodQuality)
	selfDictionary.set("addedDiseasePrevention", addedDiseasePrevention)

func refreshDuckColors():
	"""
	Changes the duck's color to the duck's current colors
	"""
	var meshes = self.get_child(0)
	
	if healthCondition == "":
		tempHue = hue
		tempSaturation = saturation
	
	bodyColor = Color.from_hsv(tempHue, tempSaturation, value)
	
	mat = mat.duplicate()
	mat.set_albedo(bodyColor)
	
	meshes.get_child(0).material_override = mat.duplicate()
	meshes.get_child(7).material_override = mat.duplicate()
	
	mat = mat.duplicate()
	
	wingColor = Color.from_hsv(hue, saturation, value - 0.2)
	mat.set_albedo(wingColor)
	
	meshes.get_child(2).material_override = mat.duplicate()
	meshes.get_child(3).material_override = mat.duplicate()
	
	mat = mat.duplicate()
	
	beakColor = Color.from_hsv(beakHue, beakSaturation, beakValue)
	
	mat.set_albedo(beakColor)
	
	meshes.get_child(4).material_override = mat.duplicate()

func renameDuck(newName: String):
	saveDataValues.Duckies.erase(self.name)
	self.name = newName
