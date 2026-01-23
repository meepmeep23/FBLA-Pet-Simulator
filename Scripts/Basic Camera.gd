extends Camera3D

var scrollDir = 0

var parent: Node3D

var UIMain: Control 

func _ready() -> void:
	parent = self.get_parent()
	UIMain = get_parent().get_parent().find_child("UI Main")

func _process(delta: float) -> void:
	"""
	When scrolling, go up/down
	When right clicking, lock mouse for rotation
	When WASD pressed, move camera using current rotation
	Limit the scroll to 20 - 40 and limit the camera's position to -40 - 40 on the x axis and -50 - 50 on the z axis
	"""
	
	
	
	#Movement using WASD
	var inputDir = Input.get_vector("A","D","W","S")
	var direction = (global_transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	
	if UIMain.current_tab == 0: #Ranching Tab
		#Locks mouse
		if Input.is_action_pressed("Right Click"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		#Direction to position conversion over time
		parent.position.x += direction.x * delta * 20 * parent.position.y / 27
		parent.position.z += direction.z * delta * 20 * parent.position.y / 27
		parent.position.x = clamp(parent.position.x, -40, 40)
		parent.position.z = clamp(parent.position.z, -50, 50)
		
		#Scroll behavior and limitations
		if Input.is_action_just_pressed("Up") || Input.is_action_pressed("Down Alt"):
			parent.position.y -= delta * 20
			parent.position.y -= delta * 10
			parent.position.y = clamp(parent.position.y, 20, 40)
		elif Input.is_action_just_pressed("Down") || Input.is_action_pressed("Up Alt"):
			parent.position.y += delta * 20
			parent.position.y += delta * 10
			parent.position.y = clamp(parent.position.y, 20, 40)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if UIMain.current_tab == 1:
		parent.position.z = move_toward(parent.position.z, -27.529, delta * 20)
		parent.position.y = move_toward(parent.position.y, 19.2, delta * 20)
		parent.position.x = move_toward(parent.position.x, 10.38, delta * 20)
		parent.rotation_degrees.y = move_toward(parent.rotation_degrees.y, 7.5 , delta * 300)
		rotation_degrees.x = move_toward(rotation_degrees.x, -90 , delta * 20)

func _unhandled_input(event: InputEvent) -> void:
	if UIMain != null:
		#Basic mobile controls:
		if OS.get_name() == "Android" || "IOS" && UIMain.current_tab != 1:
			#Camera movement on mobile
			if event is InputEventScreenDrag:
				self.get_parent().rotate_y(-event.relative.x * 0.001)
				self.get_parent().position.y += -event.relative.y * 0.01
			
			#Double tab to emulate pressing 'E'
			if event is InputEventScreenTouch && event.double_tap == true:
				Input.action_press("Enter Building")
			else:
				Input.action_release("Enter Building")
			
			get_parent().position.y = clamp(self.get_parent().position.y, 20, 40)
			
	#Handles mouse movement for the camera rotating
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			parent.rotate_y(-event.relative.x * 0.001)
			self.rotate_x(-event.relative.y * 0.001)
			if self.rotation_degrees.x < -175:
				self.rotation_degrees.x = -175
			if self.rotation_degrees.x > -10:
				self.rotation_degrees.x = -10
