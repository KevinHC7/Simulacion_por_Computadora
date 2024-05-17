extends ARVRController

var controller_velocity = Vector3(0,0,0)
var prior_controller_position = Vector3(0,0,0)
var prior_controller_velocities = []
var held_object = null
var held_object_data = {"mode":RigidBody.MODE_RIGID, "layer":1, "mask":1}
var grab_area
var grab_raycast
var grab_mode = "AREA"
var grab_pos_node
var hand_mesh
var teleport_pos
var teleport_mesh
var teleport_button_down
var teleport_raycast
const CONTROLLER_DEADZONE = 0.65
const MOVEMENT_SPEED = 1.5
var directional_movement = false
var move_forward = false
var move_backward = false
var rotate_left = false
var rotate_right = false

func _ready():
	teleport_raycast = get_node("RayCast")
	teleport_mesh = get_tree().root.get_node("Game/Teleport_Mesh")
	teleport_button_down = false
	grab_area = get_node("Area")
	grab_raycast = get_node("GrabCast")
	grab_pos_node = get_node("Grab_Pos")
	grab_mode = "AREA"
	get_node("Sleep_Area").connect("body_entered", self, "sleep_area_entered")
	get_node("Sleep_Area").connect("body_exited", self, "sleep_area_exited")
	hand_mesh = get_node("Hand")
	connect("button_pressed", self, "button_pressed")
	connect("button_release", self, "button_released")
func _physics_process(delta):
	if teleport_button_down:  # Simplificado
		teleport_raycast.force_raycast_update()
		if teleport_raycast.is_colliding():
			if teleport_raycast.get_collider() is StaticBody and teleport_raycast.get_collision_normal().y >= 0.85:
				teleport_pos = teleport_raycast.get_collision_point()
				teleport_mesh.global_transform.origin = teleport_pos
	if get_is_active():
		controller_velocity = Vector3(0,0,0)
		if prior_controller_velocities.size() > 0:
			for vel in prior_controller_velocities:
				controller_velocity += vel
			controller_velocity = controller_velocity / prior_controller_velocities.size()
		prior_controller_velocities.append((global_transform.origin - prior_controller_position) / delta)
		controller_velocity += (global_transform.origin - prior_controller_position) / delta
		prior_controller_position = global_transform.origin
		if prior_controller_velocities.size() > 30:
			prior_controller_velocities.remove(0)
	else: 
		move_forward = Input.is_action_pressed("move_forward")
		move_backward = Input.is_action_pressed("move_backward")
		rotate_left = Input.is_action_pressed("rotate_left")
		rotate_right = Input.is_action_pressed("rotate_right")

		var direction = Vector3.FORWARD * (5 if move_forward else -5 if move_backward else 0)
		direction *= MOVEMENT_SPEED * delta

		var rotation_angle = deg2rad(70) * (1 if rotate_left else -1 if rotate_right else 0) * delta

		get_parent().translate(direction)
		get_parent().rotate_y(rotation_angle)
func button_pressed(button_index):
	if button_index == 15:
		if held_object != null:
			if held_object.has_method("interact"):
				held_object.interact()
		else:
			if teleport_mesh.visible == false and held_object == null:
				teleport_button_down = true
				teleport_mesh.visible = true
				teleport_raycast.visible = true
	if button_index == 2:
		if (teleport_button_down == true):
			return
		if held_object == null:		
			var rigid_body = null
			if (grab_mode == "AREA"):
				var bodies = grab_area.get_overlapping_bodies()
				if len(bodies) > 0:
					for body in bodies:
						if body is RigidBody:
							if !("NO_PICKUP" in body):
								rigid_body = body
								break
			elif (grab_mode == "RAYCAST"):
				grab_raycast.force_raycast_update()
				if (grab_raycast.is_colliding()):
					if grab_raycast.get_collider() is RigidBody and !("NO_PICKUP" in grab_raycast.get_collider()):
						rigid_body = grab_raycast.get_collider()
			if rigid_body != null:
				held_object = rigid_body
				held_object_data["mode"] = held_object.mode
				held_object_data["layer"] = held_object.collision_layer
				held_object_data["mask"] = held_object.collision_mask
				held_object.mode = RigidBody.MODE_STATIC
				held_object.collision_layer = 0
				held_object.collision_mask = 0
				hand_mesh.visible = false
				grab_raycast.visible = false
				if (held_object.has_method("picked_up")):
					held_object.picked_up()
				if ("controller" in held_object):
					held_object.controller = self
		else:
			held_object.collision_layer = held_object_data["layer"]
			held_object.collision_mask = held_object_data["mask"]
			held_object.apply_impulse(Vector3(0, 0, 0), controller_velocity)
			if held_object.has_method("dropped"):
				held_object.dropped()
			if "controller" in held_object:
				held_object.controller = null
			held_object = null
			hand_mesh.visible = true
			if (grab_mode == "RAYCAST"):
				grab_raycast.visible = true
		get_node("AudioStreamPlayer3D").play(0)
	if button_index == 1:
		if grab_mode == "AREA":
			grab_mode = "RAYCAST"
			if held_object == null:
				grab_raycast.visible = true
		elif grab_mode == "RAYCAST":
			grab_mode = "AREA"
			grab_raycast.visible = false
	if !get_is_active():  # Verificar si no hay controlador VR activo
		if Input.is_action_just_pressed("grab"):
			_handle_grab_input()  # Llamada a una función separada
func button_released(button_index):
	if button_index == 15:
		if (teleport_button_down == true):
			if teleport_pos != null and teleport_mesh.visible == true:
				var camera_offset = get_parent().get_node("Player_Camera").global_transform.origin - get_parent().global_transform.origin
				camera_offset.y = 0
				get_parent().global_transform.origin = teleport_pos - camera_offset
			teleport_button_down = false
			teleport_mesh.visible = false
			teleport_raycast.visible = false
			teleport_pos = null
func _handle_grab_input():
	if held_object == null:  
		grab_raycast.force_raycast_update() 

		if grab_raycast.is_colliding(): 
			var collider = grab_raycast.get_collider()  

			if collider is RigidBody and !("NO_PICKUP" in collider): 
				held_object = collider
				held_object_data["mode"] = held_object.mode
				held_object_data["layer"] = held_object.collision_layer
				held_object_data["mask"] = held_object.collision_mask
				held_object.mode = RigidBody.MODE_STATIC
				held_object.collision_layer = 0
				held_object.collision_mask = 0

				hand_mesh.visible = false
				grab_raycast.visible = false

				if held_object.has_method("picked_up"):
					held_object.picked_up()
	else: 

		held_object.mode = held_object_data["mode"]
		held_object.collision_layer = held_object_data["layer"]
		held_object.collision_mask = held_object_data["mask"]


		held_object.apply_impulse(Vector3.ZERO, global_transform.basis.z.normalized() * 10)

		if held_object.has_method("dropped"):
			held_object.dropped()

		held_object = null
		hand_mesh.visible = true
		grab_raycast.visible = true  
func sleep_area_entered(body):
	if "can_sleep" in body:
		body.can_sleep = false
		body.sleeping = false
func sleep_area_exited(body):
	if "can_sleep" in body:
		body.can_sleep = true
	
