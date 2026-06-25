extends CharacterBody2D


const speed = 300.0
var x_direction = 0
var y_direction = 0

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the uiment/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	#Horizontal Movement
	
	if Input.is_action_just_pressed("ui_right"):
		x_direction = 1
	if Input.is_action_just_pressed("ui_left"):
		x_direction = -1
		
	if Input.is_action_just_released("ui_right") and x_direction == 1:
		if Input.is_action_pressed("ui_left"):
			x_direction = -1
		else:
			x_direction = 0
	if Input.is_action_just_released("ui_left") and x_direction == -1:
		if Input.is_action_pressed("ui_right"):
			x_direction = 1
		else:
			x_direction = 0
	
	velocity.x = speed*x_direction
	
	#Vertical Movement
	
	if Input.is_action_just_pressed("ui_down"):
		y_direction = 1
	if Input.is_action_just_pressed("ui_up"):
		y_direction = -1
		
	if Input.is_action_just_released("uia_down") and y_direction == 1:
		if Input.is_action_pressed("ui_up"):
			y_direction = -1
		else:
			y_direction = 0
	if Input.is_action_just_released("ui_up") and y_direction == -1:
		if Input.is_action_pressed("ui_down"):
			y_direction = 1
		else:
			y_direction = 0
	
	velocity.y = speed*y_direction
	move_and_slide()
