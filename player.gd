extends CharacterBody3D


class_name player



const SPEED = 7.25
const JUMP_VELOCITY = 6
@export var max_health: int = 100
var health: int = 100
var sens: int = 0.0025
@onready var pivot: Node3D = $Camera_Controller
const JUMP_FORCE = 10
const WALL_JUMP_FORCE = 10
@onready var cam: Camera3D = $Camera_Controller/Camera_Target/Camera3D
@onready var cam_2: Camera3D = $Camera_Controller/Camera_Target/Camera3D2
var tar = true



func jump() -> void:
	velocity.y = JUMP_VELOCITY

func slide_jump(z: float) -> void:
	velocity.y = JUMP_VELOCITY
	velocity.z = z




# Get the gravity from the project settings to be synced with RigidBody nodes.
static var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") as float






func _physics_process(delta: float) -> void:
	if tar == true:
		
		#Rotate the camera left / right
		if Input.is_action_just_pressed("cam_left"):
			$Camera_Controller.rotate_y(deg_to_rad(30))
		
		
		if Input.is_action_just_pressed("cam_right"):
			$Camera_Controller.rotate_y(deg_to_rad(-30))
		
		if Input.is_action_just_pressed("first_person"):
			
			cam.set_current(true)
			cam_2.set_current(false)
		
		
		if Input.is_action_just_pressed("third_person"):
			
			
			cam_2.set_current(true)
			cam.set_current(false)
			
		
		
		
		
		
			
		
		
		
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
			
			
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		
		
		if is_on_wall_only() and Input.is_action_just_pressed("ui_accept"):
			var normal: Vector3 = get_last_slide_collision().get_normal()
			velocity.y += JUMP_FORCE
			velocity += normal * WALL_JUMP_FORCE
		
		
		
		
		
		
		
		
		
		
		
		# Get the input direction and handle the movement/deceleration.
		# New Vector3 direction, taking into account the user arrow inputs and the camera rotation
		var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		Vector2(0,0)
		var direction: Vector3 = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		# Rotate the character mesh so oriented towards the direction moving in relation to the camera
		if input_dir != Vector2(0,0):
			$MeshInstance3D.rotation_degrees.y = $Camera_Controller.rotation_degrees.y + 90 -rad_to_deg(input_dir.angle())
			
		
		
		
		
		# Update the velocity and move the character
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			
		move_and_slide()
		
		
		
		
		
		
		
		
		





func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		# Show/hide mouse (can be useful for UI on mobile too)
		if event.is_action_pressed("show_mouse"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			return # Important: Don't process further camera input if showing mouse
		
		# Mobile Touch Input for Camera Control
		if event is InputEventScreenDrag:
			if event.index == 0: # Only register the first finger touch for camera
				$Camera_Controller.rotate_y(-event.relative.x * 0.0025)
				cam_2.rotate_x(-event.relative.y * 0.0025)
				cam_2.rotation.x = clamp(cam_2.rotation.x, deg_to_rad(-30), deg_to_rad(60))
				cam.rotate_x(-event.relative.y * 0.0025)
				cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-30), deg_to_rad(60))
		elif event is InputEventMouseButton:
			if event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			# Mouse motion for desktop (only if captured)
			$Camera_Controller.rotate_y(-event.relative.x * 0.0025)
			cam_2.rotate_x(-event.relative.y * 0.0025)
			cam_2.rotation.x = clamp(cam_2.rotation.x, deg_to_rad(-30), deg_to_rad(60))
			cam.rotate_x(-event.relative.y * 0.0025)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-30), deg_to_rad(60))
