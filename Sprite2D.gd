extends Sprite2D

var velocidad = 333
var angulo_velocidad = PI

func _process(delta):
	var direccion = 0
	if Input.is_action_pressed("ui_left"):
		direccion = -1
	if Input.is_action_pressed("ui_right"):
		direccion = 1
		
	print("Hello, Class CUCEI!")
	rotation += angulo_velocidad  * direccion * delta
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * velocidad
	position += velocity * delta
	
	
	
