extends Control

var controller_one
var controller_two

func _ready():
	var VR = ARVRServer.find_interface("OpenVR")
	if VR and VR.initialize():
		get_viewport().arvr = true
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		var interface = ARVRServer.get_primary_interface()
		rect_size = interface.get_render_targetsize()
		rect_position = Vector2(0,0)
		controller_one = get_parent().get_node("Left_Controller")
		controller_two = get_parent().get_node("Right_Controller")
		visible = false


func _process(delta):
	if (controller_one == null or controller_two == null):
		return
	if (controller_one.directional_movement == true or controller_two.directional_movement == true):
		visible = true
	else:
		visible = false

