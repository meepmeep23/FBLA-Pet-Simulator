extends CharacterBody3D

#Logic Values

var mat = preload("res://Materials/mat.tres")
var shadowMat = preload("res://Materials/shadowMat.tres")

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
var intelligencePotential: float
var flyingPotential: float
var diseaseChance: float
var stamina: float
var speed: float
var attackSpeed: float
var metabolismSpeed: float
var luck: float
var lifeLength: float
var wisdom: float

#Cosmetic
var bodyColor: Color
var wingColor: Color
var beakColor: Color

var hue: float
var saturation: float
var value: float

var eyeHue: float
var eyeValue: float

var wingLength: float
var beakHue: float
var beakSaturation: float
var beakValue: float

#Emotions
var angerSens: float
var sadSense: float
var boredSense: float

var anger: float
var sad: float
var bored: float

#Non-Genetic Values

var cost = 0
var age = 0.0
var holiness: float
var intelligence: float
var strength: float
var flyingHeight: float
var health: float
var healthCondition: int
var tiredness: float
var lifeLengthPerm: float
var overallSize: float
var food = 100

var size = 1
var timesMined: int

var wasChild = false #Used for making duck spawn in when done
var wasInMine = false #Used for making duck spawn when exiting mine

var foodList = []
var foodQuality = 1.0
var timeWOFood = 0
var nutrition = 1

"""
Whenever you want to add a new value to the save data, you need to follow these steps:
	*Set up the variable
	*Put the variable down in the defineSelfDictionary function
	*Make the two situations for what happens with the variable in the getDuckyPolished function:
		*If there is no save data, what should the variable be?
		*If there is save data, get it and save it to the variable
	*Lastly add all the functionality you need for the variable
"""


func _ready() -> void:
	#Debugging checks to solve errors and to check if duck isn't here. 
	connect("mouse_entered", _on_mouse_entered)
	print("connected1")
	connect("mouse_exited", _on_mouse_exited)
	print("connected2")
	self.find_child("3D Selection Gui").texture = self.find_child("SubViewport").get_texture()

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
		intelligencePotential = randf() + 0.1
		flyingPotential = randf() + 0.1
		diseaseChance = randf()
		stamina = randf() * 100
		speed = randf_range(0.33,3)
		attackSpeed = randf_range(0.33,3)
		metabolismSpeed = randf() + 0.1
		luck = randf_range(0,7)
		lifeLength = randf_range(0.7,1.2)
		wisdom = randf() + 1
		
		hue = randf()
		saturation = randf()
		value = randf()
		beakHue = randf()
		beakSaturation = randf()
		beakValue = randf()
		
		age = 0.8
		overallSize = 1
		
		anger = 0
		sad = 0
		bored = 0
		
		timesMined = 0
	
	else:
		for x in saveDataValues.Duckies.get(self.name):
			set(x, saveDataValues.Duckies.get(self.name).get(x))
	
	#Fixing Materials, can't use the function because of the way genetics are loaded by 3 values and not 1 color.
	var meshes = self.get_child(0)
	bodyColor = Color.from_hsv(hue, saturation, value, 255)
	
	mat = mat.duplicate()
	mat.set_albedo(bodyColor)
	
	meshes.get_child(0).material_override = mat.duplicate()
	meshes.get_child(7).material_override = mat.duplicate()
	
	
	wingColor = Color.from_hsv(hue, saturation, value - 0.2, 255)
	
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
	
	nutrition = foodQuality * 10 / (timeWOFood + 1)
	
	defineSelfDictionary()
	
	hasPolished = true
	
func _physics_process(delta: float) -> void:
	if saveDataValues.miningValues.get("selectedDuck") == name && saveDataValues.igt - saveDataValues.miningValues.get("duckMiningStartTime") < saveDataValues.miningValues.get("MiningTime"):
		self.visible = false
		self.find_child("CollisionShape3D").disabled = true
		wasInMine = true
		food = 30
	else:
		if wasInMine == true:
			self.visible = true
			self.find_child("CollisionShape3D").disabled = false
			$AnimationPlayer.play("Walk Out Of Mine")
			wasInMine = false
	
	strength = strengthPotential
	$"3D Selection Gui/SubViewport/Ui Parent/Name".text = self.name
	
	#Sets position on floor so no weird collisions make them fly,
	self.position.y = 0
	
	scale = Vector3(size+0.01,size+0.01,size+0.01)
	
	#Used on start to set up the duck when it gets spawned in.
	if self.get_parent().get_parent().hasCheckedDucks == true && hasPolished == false:
		getDuckyPolished()
	
	ageBehavior(delta)
	selectionBehavior()
	foodBehavior(delta)
	movementCheck()
	move_and_slide()

#This Function Also has move(), think(), and turn() inside.
func ageBehavior(delta):
	if get_parent().get_parent().find_child("UI Main").firstTime == false:
		age += delta * 0.01
	
	$"3D Selection Gui/SubViewport/Ui Parent/Age".text = str(age).pad_decimals(2)
	
	if age < 7:
		self.visible = false
		size = 0.3
		velocity.x = 0
		velocity.z = 0
		$CollisionShape3D.disabled = true
		wasChild = true
	
	if age > 7:
		if wasChild == true:
			wasChild = false
			self.visible = true
			$AnimationPlayer.play("Walk Out Of Breeding Center")
			velocity.x = 0
			velocity.z = 0
			$CollisionShape3D.disabled = false
			state = "think"
		if $AnimationPlayer.current_animation != "Walk Out Of Breeding Center" && $AnimationPlayer.current_animation != "Walk Out Of Mine":
			move(delta)
			think()
			turn(delta)
	size = overallSize

#This function handles almost all food related behaviors.
func foodBehavior(delta):
	get_child(3).get_child(0).get_child(0).get_child(0).value = food #Makes food progress bar equal to how full the duck is.
	
	if food > 0 && age > 1:
		food -= delta / 2
		nutrition = foodQuality * 10
	elif age < 1:
		food = 100
		nutrition = 10
	else:
		food = 0
		timeWOFood += delta
		nutrition = foodQuality * 10 / (timeWOFood + 1)

func fed(foodType: String):
	if saveDataValues.foodItems.get(foodType) != null && saveDataValues.foodItems.get(foodType) > 0:
		saveDataValues.foodItems.set(foodType, saveDataValues.foodItems.get(foodType) - 1)
		if foodType == "Bread":
			food += 25
		if foodType == "Watermelon":
			overallSize += 0.02
			food += 100
		if foodType == "Peppers":
			speed += 0.02
			food += 30
		if foodType == "Sunflower":
			value += 0.005
			refreshDuckColors()
		if foodType == "Nuts":
			food += 15
			strengthPotential += 0.02
		
		foodList.append(foodType)
		if foodList.size() > 5:
			foodList.remove_at(0)
		
		var tempFoodList = []
		var foodUsed = false
		var tempFoodQuality = 1
		
		for f in foodList:
			for t in tempFoodList:
				if f == t:
					foodUsed = true
			if foodUsed == true:
				tempFoodQuality -= 0.2
				foodUsed = false
			else:
				tempFoodList.append(f)
		
		
		foodQuality = tempFoodQuality
	
	timeWOFood = 0
	
	if food > 100:
		food = 100

#This function handles all the behavior of selecting Ducks.
func selectionBehavior():
	#Makes the Duck selected when you click on it, and checks to make sure that no other duck is selected. 
	if mouseInside == true && Input.is_action_just_pressed("click"):
		for x in self.get_parent().get_child_count():
			if get_parent().get_child(x).selected == true:
				selected = false
		selected = true
	
	#If you click off the Duck & the food panel isn't open, the duck is no longer selected. 
	if mouseInside == false && Input.is_action_just_pressed("click") && get_parent().get_parent().find_child("Feed Panel").visible == false:
		selected = false
	
	#If the duck is selected the border around the duck will be white, and if 'F' is pressed, the feed panel will be come visible. 
	if selected == true:
		$"3D Selection Gui".visible = true
		$"3D Selection Gui/SubViewport/Ui Parent/Nutrition".text = str(nutrition).pad_decimals(2)
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
	selfDictionary.set("saturation", saturation)
	selfDictionary.set("value", value)
	selfDictionary.set("beakHue", beakHue)
	selfDictionary.set("beakSaturation", beakSaturation)
	selfDictionary.set("beakValue", beakValue)
	selfDictionary.set("eyeHue", eyeHue)
	selfDictionary.set("eyeValue", eyeValue)
	selfDictionary.set("speed", speed)
	selfDictionary.set("overallSize", overallSize)
	selfDictionary.set("food", food)
	selfDictionary.set("anger", anger)
	selfDictionary.set("bored", bored)
	selfDictionary.set("sad", sad)
	selfDictionary.set("timesMined", timesMined)
	selfDictionary.set("strengthPotential", strengthPotential)
	selfDictionary.set("strength", strength)
	selfDictionary.set("foodList", foodList)
	selfDictionary.set("foodQuality", foodQuality)

func refreshDuckColors():
	"""
	Changes the duck's color to the duck's current colors
	"""
	var meshes = self.get_child(0)
	
	bodyColor = Color.from_hsv(hue, saturation, value)
	
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
