extends Area2D
@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	# hide() # Oculto para cuando apenas empiece el juego


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # El Jugador está "quieto"
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	# Si se está moviendo o no
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	# Posición del jugador luego de obtener la velocidad.
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	# Direcciones de la animación
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		if velocity.y > 0:
			$AnimatedSprite2D.animation = "down"  # Usar la animación para moverse hacia abajo.
		else:
			$AnimatedSprite2D.animation = "up"  # Usar la animación para moverse hacia arriba.


func _on_body_entered(body):
	hide() # Player dissapear after being hit
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback 
	$CollisionShape2D.set_deferred("disabeld",true)
# Función para cuando inicie el juego
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
