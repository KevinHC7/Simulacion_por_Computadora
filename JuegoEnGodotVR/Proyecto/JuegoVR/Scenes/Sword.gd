extends RigidBody

const SWORD_DAMAGE = 20

var controller

func _ready():
	get_node("Damage_Area_01").connect("body_entered", self, "body_entered_sword", ["01"])
	get_node("Damage_Area_02").connect("body_entered", self, "body_entered_sword", ["02"])
	get_node("Damage_Area_03").connect("body_entered", self, "body_entered_sword", ["03"])
	get_node("Damage_Area_04").connect("body_entered", self, "body_entered_sword", ["04"])
func interact():
	pass
func picked_up():
	pass
func dropped():
	pass


func body_entered_sword(body, number):
	if body == self:
		pass
	else:
		
		var sword_part = null
		if number == "01":
			sword_part = get_node("Damage_Area_01")
		elif number == "02":
			sword_part = get_node("Damage_Area_02")
		elif number == "03":
			sword_part = get_node("Damage_Area_03")
		elif number == "04":
			sword_part = get_node("Damage_Area_04")
		if body.has_method("damage"):
			body.damage(sword_part.global_transform.looking_at(body.global_transform.origin, Vector3(0, 1, 0)), SWORD_DAMAGE)

			get_node("AudioStreamPlayer3D").play()
		
		elif body.has_method("apply_impulse"):
			

			var direction_vector = sword_part.global_transform.origin - body.global_transform.origin

			if controller == null:
				body.apply_impulse(direction_vector.normalized(), direction_vector.normalized() * self.linear_velocity)
			else:
				body.apply_impulse(direction_vector.normalized(), direction_vector.normalized() * controller.controller_velocity)
			get_node("AudioStreamPlayer3D").play()
			
		

