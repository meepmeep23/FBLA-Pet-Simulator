extends CharacterBody3D

@export var target: Node3D
@export var attackSpeed: float
@export var maxHeight: float

@onready var projectile = preload("res://Objects/projectile_basic.tscn")

var time = 0

func _physics_process(delta: float) -> void:
	#Attack Timer
	time += delta
	if time >= attackSpeed: 
		summonProjectile()
		time -= attackSpeed
	
	move_and_slide()

func summonProjectile():
	#Sets the variables of the projectile and summons it
	var projectileSpawned = projectile.instantiate()
	projectileSpawned.target = target
	projectileSpawned.flyingHeight = maxHeight
	projectileSpawned.startingPos = self.position
	self.get_parent().add_child(projectileSpawned)
