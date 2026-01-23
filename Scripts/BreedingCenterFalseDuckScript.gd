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
var baseHealthiness: float
var speed: float
var metabolismSpeed: float
var luck: float

#Cosmetic
var bodyColor: Color
var wingColor: Color
var beakColor: Color

var hue: float
var saturation: float
var value: float

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

var age = 0.0
var strength: float
var overallSize: float
var food = 100

var size = 1
var timesMined: int

var wasChild = false #Used for making duck spawn in when done
var wasInMine = false

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
	*Make the two situations for what happens with the variable in the getDuckyPolished function:
		*If there is no save data, what should the variable be?
		*If there is save data, get it and save it to the variable
	*Lastly add all the functionality you need for the variable
"""

func _ready() -> void:
	$"3D Gui".texture = $"3D Gui/SubViewport"

#Uses for polishing the ducks values on loading.
func getDuckyPolished():
	"""
	Load genetics from the save node.

	Now that the genetics are set, 
	match the materials on the duck to the genetics.

	Save the duck's values to the dictionary for the save node. 
	"""

	#Genetic Loading
	for x in saveDataValues.Duckies.get(self.name):
		set(x, saveDataValues.Duckies.get(self.name).get(x))
	
	#Fixing Materials, can't use the function because of the way genetics are loaded by 3 values and not 1 color.
	var meshes = self.get_child(0)
	bodyColor = Color.from_hsv(hue, saturation, value, 255)
	
	mat = mat.duplicate()
	mat.set_albedo(bodyColor)
	
	meshes.get_child(0).material_override = mat.duplicate()
	meshes.get_child(7).material_override = mat.duplicate()
	
	#For falseDuck / breedingCenter set the egg colors as well
	find_child("Egg Meshes").find_child("Egg").material_override = mat.duplicate()
	
	wingColor = Color.from_hsv(hue, saturation, value - 0.2, 255)
	
	mat = mat.duplicate()
	mat.set_albedo(wingColor)
	
	meshes.get_child(2).material_override = mat.duplicate()
	meshes.get_child(3).material_override = mat.duplicate()
	
	
	beakColor = Color.from_hsv(beakHue,beakSaturation,beakValue,255)
	
	mat = mat.duplicate()
	mat.set_albedo(beakColor)
	
	#For falseDuck / breedingCenter set the egg colors as well
	find_child("Egg Meshes").find_child("EggDeco").material_override = mat.duplicate()
	
	meshes.get_child(4).material_override = mat.duplicate()
	
	shadowMat = shadowMat.duplicate()
	meshes.get_child(1).material_override = shadowMat
	meshes.get_child(8).material_override = shadowMat
	meshes.get_child(9).material_override = shadowMat
	meshes.get_child(10).material_override = shadowMat
	meshes.get_child(11).material_override = shadowMat
	meshes.get_child(12).material_override = shadowMat
	
	defineSelfDictionary()
	
	hasPolished = true
	
func _physics_process(delta: float) -> void:
	#Sets position on floor so no weird collisions make them fly,
	self.position.y = 0
	
	scale = Vector3(size+0.01,size+0.01,size+0.01)
	
	#Used on start to set up the duck when it gets spawned in.
	if self.get_parent().get_parent().hasCheckedDucks == true && hasPolished == false:
		getDuckyPolished()
	
	ageBehavior(delta)
	movementCheck()
	move_and_slide()
	
#This Function Also has move(), think(), and turn() inside.
func ageBehavior(delta):
	if age > 7:
		if wasChild == false:
			self.visible = false
			velocity.x = 0
			velocity.z = 0
			$CollisionShape3D.disabled = true
		
	
	age += delta * 0.05
	
	$"3D Gui/SubViewport/Ui Parent/Age".text = str(age).pad_decimals(2)
	
	if age < 1:
		wasChild = true
		self.find_child("Egg Meshes").visible = true
		size = 0.3
		velocity.x = 0
		velocity.z = 0
	
	#Makes babies smaller when they are younger
	if age <= 7:
		if age >= 1:
			if wasChild == false:
				self.find_child("Egg Meshes").visible = false
				size = ((age + 3) / 10) * overallSize
				move(delta)
				think(delta)
				turn(delta)
			else:
				$AnimationPlayer.play("Egg Hatch")
				wasChild = false
		food = 100

func movementCheck():
	var raycast = self.find_child("Raycasts")
	
	for r in raycast.get_children():
		if r.is_colliding() == true:
			state = "think"

func move(delta):
	#Moves the duck in the direction for 2.5 seconds
	if state == "move":
		if i < 2.5:
			i += delta * speed
		
		if i >= 2.5:
			i = 0
			state = "think"
		
		velocity.x = direction.x * speed
		velocity.z = direction.y * speed

func think(delta):
	"""
	The Duck stops moving, and picks the new direction to move in.
	Uses basic trigonometry to set the rotation of the duck's raycasts towards the direction to make sure it is a valid direction.
	"""
	if state == "think":
		direction = Vector2(rand.randf_range(-3,3), rand.randf_range(-3,3))
		velocity.x = 0
		velocity.z = 0
		
		if direction.x > 0:
			$Raycasts.rotation.y = acos(direction.y / sqrt(direction.y ** 2 + direction.x ** 2))
		if direction.x < 0:
			$Raycasts.rotation.y = -acos(direction.y / sqrt(direction.y ** 2 + direction.x ** 2))
		
		if i < randf_range(0.4, 0.8):
			i += delta
			
		else:
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
	selfDictionary.set("metabolismSpeed", metabolismSpeed)
	selfDictionary.set("baseHealthiness", baseHealthiness)
	selfDictionary.set("foodQuality", foodQuality)
	selfDictionary.set("addedDiseasePrevention", addedDiseasePrevention)
