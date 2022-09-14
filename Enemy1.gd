extends KinematicBody2D

export (int) var speed = 30000

var acceleration = 6000
var fric = 3000
var velocity = Vector2.ZERO

onready var _esprite = $AnimatedSprite

var isAttacking = false

func _process(_delta):
	if (Input.is_action_pressed("press_d") || Input.is_action_pressed("press_s") || Input.is_action_pressed("press_w") || Input.is_action_pressed("press_a")) and !isAttacking:
		_esprite.play("Aggro")
	elif !isAttacking:
		_esprite.play("Idle")
		
	if Input.is_action_pressed("press_e"):
		isAttacking = true
		_esprite.play("Attack1")	
		
	
func _physics_process(_delta):
	#get_input()
	#velocity = move_and_slide(velocity)
	#_my_particles.set_rotation_degrees(rad2deg(velocity.angle())-180)
	var input_vector = Vector2()


	input_vector.x = Input.get_action_strength("press_d") - Input.get_action_strength("press_a")
	input_vector.y = Input.get_action_strength("press_s") - Input.get_action_strength("press_w")
	input_vector = input_vector.normalized()
		

	if input_vector != Vector2.ZERO:
		velocity += input_vector * acceleration * _delta
		velocity = velocity.clamped(speed * _delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, fric * _delta)
# warning-ignore:return_value_discarded
	move_and_collide(velocity * _delta)


func _on_AnimatedSprite_animation_finished():
		if(_esprite.get_animation() == "Attack1"):
			_esprite.play("Idle")
			isAttacking = false

