extends "res://Scripts/Enemies/EnemyBase.gd"

var player_direction = null

func _ready():
	hp = 20
	hp_max = hp
	$Hitbox.position.x = 83
	$Hitbox/CollisionShape2D.shape.radius = 36
	hitBox.disabled = false			
	_esprite.set_frame(0)
	
	
func _physics_process(delta):
	
	match state:
		ATTACK:
			attack_state()
		FALLING:
			check_falling()
		MOVE:
				check_movement()
		IDLE:
				check_idle()
		DAMAGED:
			check_damage()
	
	should_flip()



func _input(event):
	#if Input.is_action_pressed("press_e") and state == MOVE:
	#	state = ATTACK
	pass


func attack_state():
	#if Input.is_action_pressed("press_e"):
		#x is -86 y is -18 for big hitbox
	
	if _esprite.flip_h == false:
		$Hitbox.position.x = -86
		$Hitbox/CollisionShape2D.shape.radius = 185
	else:
		$Hitbox.position.x = 86*2
		$Hitbox/CollisionShape2D.shape.radius = 185
	
	
	_esprite.play("Attack1")
	#hitBox.disabled = true
	velocity = Vector2.ZERO
		
	if (_esprite.frame > 12 and _esprite.frame < 24):
		#hitBox.set_deferred("disabled","false")
		hitBox.disabled = false
		_hurtBox.disabled = true
	
	else:
		_hurtBox.disabled = false
	
		
	#if hp <= 0:
		#state = FALLING
		




func _on_AnimatedSprite_animation_finished():
		if(_esprite.get_animation() == "Attack1"):
			$Hitbox.position.x = 83
			hitBox.disabled = false
			$Hitbox/CollisionShape2D.shape.radius = 36
			hitBox.disabled = true
			state = IDLE
			$atk_cooldown_timer.start()
		
		if(_esprite.get_animation() == "Fall"):
			self.queue_free()	

		if(_esprite.get_animation() == "Damaged"):
			state = MOVE
			
		_esprite.set_frame(0)

func check_idle():
	_esprite.play("Idle")

#---------------------------------------------- CHECK IF MOVING

func check_movement():
	if state == MOVE:
		
		if player_direction != null:
			if velocity >= 280 * player_direction:
				if _esprite.get_frame() == 0:
					_esprite.play("Aggro")
				pass
			else:
				if _esprite.get_frame()  == 0:
					_esprite.play("Idle")
				pass
				
	if player:
		player_direction = (player.global_position - self.global_position).normalized()
		
		if self.global_position.distance_to(player.global_position) > 400 and self.global_position.distance_to(player.global_position) < 500:
			if !isDamaged:
				state = ATTACK
		
		if self.global_position.distance_to(player.global_position) <= 350:
			move_and_slide(1 * player_direction)
			velocity = 140 * player_direction  
			
		elif self.global_position.distance_to(player.global_position) > 350 and self.global_position.distance_to(player.global_position) <= 1300:
			move_and_slide(1 * player_direction)
			velocity = 160  * player_direction 
		elif self.global_position.distance_to(player.global_position) > 1300:
			move_and_slide(-1 * player_direction)
			velocity = 80 * player_direction 
			
		elif self.global_position.distance_to(player.global_position) > 1700:
			move_and_slide(0 * player_direction)
		
		
func _on_DetectPlayer_body_entered(body):
	if body.name == "PlayerBase":
		player = body
func _on_DetectPlayer_body_exited(body):
	if body.name == "PlayerBase":
		player = body

#----------------------------------------------- FLIPPING SPRITE
func should_flip():
	if state != ATTACK:
		if(get_parent().get_parent().get_node("PlayerBase")):
			if get_parent().get_parent().get_node("PlayerBase").global_position.x > self.global_position.x:
			#yield(get_tree().create_timer(0.5), "timeout")
				_esprite.set_flip_h(true)
			else:
			#yield(get_tree().create_timer(0.5), "timeout")
				_esprite.set_flip_h(false)

#----------------------------------------------- CHECK IF FALLEN
	
func check_falling():
	_esprite.play("Fall")
	_hurtBox.disabled = true

func check_damage():
	_esprite.play("Damaged")

func _on_Behaviour1_timer_timeout():
	move_and_slide(500 * player_direction)
	$Behaviour2_timer.start()

func _on_Behaviour2_timer_timeout():
	state = MOVE
