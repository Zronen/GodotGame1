extends KinematicBody2D

#movement speed things
export (int) var speed = 30000
#var velocity = Vector2()

var acceleration = 6000
var fric = 3000
var velocity = Vector2.ZERO

#the sprite itself
onready var _animated_sprite = $AnimatedSprite

onready var _my_particles = $Particles2D

export (String) var lastDirection;

export (bool) var isDashing = false
export (bool) var dashCooldown = false

export (bool) var isAttacking = false

var lastx = 0
var lasty = 0
 
#movement
func _process(_delta):
	if (Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_left")) and isDashing == false and !isAttacking:
		
		if Input.is_action_pressed("ui_up"):
			_animated_sprite.play("BackRun2")
			_animated_sprite.set_flip_h(false)
			lastDirection = "up"
		
		elif Input.is_action_pressed("ui_left"):
			_animated_sprite.play("SideRun2")
			_animated_sprite.set_flip_h(false)
			lastDirection = "left"
			
		elif Input.is_action_pressed("ui_right"):
			_animated_sprite.play("SideRun2")
			_animated_sprite.set_flip_h(true)
			lastDirection = "right"
					
		else:
			_animated_sprite.play("Run2")
			_animated_sprite.set_flip_h(false)
			lastDirection = "down"
				
		speed = 30000
		fric = 3000
		acceleration = 6000
		#emit particles when moving
		
	elif isDashing == false and !isAttacking: 
		
		if lastDirection == "up":
			_animated_sprite.play("BackIdle2")
			_animated_sprite.set_flip_h(false)
		elif lastDirection == "left":
			_animated_sprite.play("SideIdle2")
			_animated_sprite.set_flip_h(false)
		elif lastDirection == "right":
			_animated_sprite.play("SideIdle2")
			_animated_sprite.set_flip_h(true)
		else:
			_animated_sprite.play("Idle2")
			_animated_sprite.set_flip_h(false)

		#stop emitting particles when not moving
		#_my_particles.set_rotation_degrees(270)
		_my_particles.set_emitting(false)
		#_animated_sprite.stop()

			
	if Input.is_action_just_pressed("spacebar") and isDashing == false:
		isAttacking = true
		
		if lastDirection == "up":
			#_animated_sprite.set_rotation_degrees(180)
			_animated_sprite.play("Slash2")
		else:
			_animated_sprite.set_rotation_degrees(0)
			_animated_sprite.play("Slash2")
		
		if Input.is_action_just_pressed("spacebar") and _animated_sprite.get_animation() == "Slash2":
			if _animated_sprite.frame == 6 or _animated_sprite.frame == 7 or _animated_sprite.frame == 8:
				_animated_sprite.play("Slash2pt2")
		
		_animated_sprite.set_flip_h(false)

		#if(_animated_sprite.animation_finished()):
			#isFinished = true
		speed = 0

	_dash()
	#rage_mode()

func rage_mode():
	if Input.is_action_just_pressed("press_c"):
		if _animated_sprite.get_modulate() != Color(0.72, 0.53, 0.04, 1):
			_animated_sprite.set_modulate(Color(0.72, 0.53, 0.04, 1))
		else:
			_animated_sprite.set_modulate(Color(1, 1, 1, 1))
	

#func get_input():
	#velocity = Vector2()
#	if Input.is_action_pressed("ui_right") :
#		velocity.x += 1000
#	if Input.is_action_pressed("ui_left") :
#		velocity.x -= 1000
#	if Input.is_action_pressed("ui_down") :
#		velocity.y += 1000
#	if Input.is_action_pressed("ui_up") :
#		velocity.y -= 1000
#	velocity = velocity.normalized() * speed
	

	

func _physics_process(_delta):
	#get_input()
	#velocity = move_and_slide(velocity)
	#_my_particles.set_rotation_degrees(rad2deg(velocity.angle())-180)
	var input_vector = Vector2()

	if isDashing == false:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()
		
		if input_vector.x != 0 or input_vector.y != 0:
			lastx = input_vector.x
			lasty = input_vector.y	
	
	else:
		input_vector.x = lastx
		input_vector.y = lasty

	if input_vector != Vector2.ZERO:
		velocity += input_vector * acceleration * _delta
		velocity = velocity.clamped(speed * _delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, fric * _delta)
# warning-ignore:return_value_discarded
	move_and_collide(velocity * _delta)

	if isDashing == true:
		_my_particles.set_rotation_degrees(rad2deg(velocity.angle())-180)


#on animation finishes
func _on_AnimatedSprite_animation_finished():
	if(_animated_sprite.get_animation() == "Slash2"):
		_animated_sprite.play("Idle2")
		isAttacking = false
	if(_animated_sprite.get_animation() == "Slash2pt2"):
		_animated_sprite.play("Idle2")
		isAttacking = false

#when the frame changes
func _on_AnimatedSprite_frame_changed():
	#if Input.is_action_just_pressed("spacebar"):
		#_animated_sprite.stop()
	#	_animated_sprite.play("Slash2")
		#speed = 0
	pass


func _on_ghost_timer_timeout():
	#copy of ghost object
	#if Input.is_action_pressed("press_v"):
	if isDashing == true:
		var this_ghost = preload("res://ghost.tscn").instance()
		#give parent
		get_parent().add_child(this_ghost)
		this_ghost.position = position
	
		this_ghost.texture = _animated_sprite.frames.get_frame(_animated_sprite.animation, _animated_sprite.frame)
		this_ghost.flip_h = _animated_sprite.flip_h

# warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("press_x"):
		find_and_use_dialogue()
			
func find_and_use_dialogue():
	var dialogue_player = get_node_or_null("DialoguePlayer")
	
	if dialogue_player:
		dialogue_player.play()


func _dash():
	if Input.is_action_just_pressed("press_v") and dashCooldown == false and isAttacking == false:
		
		if(lastDirection == "left" or lastDirection == "right"):
			_animated_sprite.play("SideRun2")
			_animated_sprite.set_frame(2)
			_animated_sprite.playing = false
			
		elif(lastDirection == "down"):
			_animated_sprite.play("Run2")
			_animated_sprite.set_frame(1)
			_animated_sprite.playing = false
			
		elif(lastDirection == "up"):
			_animated_sprite.play("BackRun2")
			_animated_sprite.set_frame(1)
			_animated_sprite.playing = false
		
		isDashing = true
		speed = 5000000
		fric = 800000
		acceleration = 14000
		#velocity = Vector2(0,-1)
		_my_particles.set_emitting(true)
		_my_particles.set_fixed_fps(60)
		_my_particles.set_use_local_coordinates(false)
		
		dashCooldown = true
		
		$dash_timer.start()

		
	
func _on_dash_timer_timeout():
	$dash_timer.stop()
	
	isDashing = false
	dashCooldown = true
	_my_particles.set_emitting(false)
	#_my_particles.set_use_local_coordinates(true)
	_my_particles.set_global_position(_animated_sprite.get_global_position())
	_my_particles.position.y += 100
	
	
	$dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout():
	dashCooldown = false
	$dash_cooldown_timer.stop()
	
