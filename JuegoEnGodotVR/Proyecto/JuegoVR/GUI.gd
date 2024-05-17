extends MeshInstance

func _ready():

	var viewport = get_node("GUI")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	

	var gui_img = viewport.get_texture()
	var material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.albedo_texture = gui_img
	set_surface_material(0, material)
