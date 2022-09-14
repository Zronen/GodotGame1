extends "res://EnemyBase.gd"


func _ready():
	hp = 5
	hp_max = hp
	$Hitbox.position.x = 83
	$Hitbox/CollisionShape2D.shape.radius = 36
	hitBox.disabled = false
	
func _physics_process(delta):
	
	match state:
		ATTACK:
			attack_state()
		
	should_flip()
	check_falling()
	check_movement()


func _input(event):
	if Input.is_action_pressed("press_e") and state == MOVE:
		state = ATTACK


func attack_state():
	if Input.is_action_pressed("press_e"):
		#x is -86 y is -18 for big hitbox
		$Hitbox.position.x = -86
		$Hitbox/CollisionShape2D.shape.radius = 185
		isAttacking = true
		_esprite.play("Attack1")
		hitBox.disabled = true
		velocity = Vector2.ZERO
		
	if (_esprite.frame == 7 or _esprite.frame == 8 or _esprite.frame == 9):
		hitBox.disabled = false
	
	if isDamaged == true:
		damage_state()



func _on_AnimatedSprite_animation_finished():

			
		if(_esprite.get_animation() == "Attack1pt2"):
			isAttacking = false
			$Hitbox.position.x = 83
			hitBox.disabled = false
			$Hitbox/CollisionShape2D.shape.radius = 36
		#hitBox.disabled = true
			state = MOVE
			
		if(_esprite.get_animation() == "Attack1"):
			_esprite.play("Attack1pt2")

#---------------------------------------------- CHECK IF MOVING

func check_movement():
	if state == MOVE:
		if self.velocity != Vector2.ZERO:
			_esprite.play("Aggro")
		else:
			_esprite.play("Idle")

#----------------------------------------------- FLIPPING SPRITE
func should_flip():
	if(get_parent().get_parent().get_node("PlayerBase")):
		if get_parent().get_parent().get_node("PlayerBase").global_position.x > self.global_position.x:
		#yield(get_tree().create_timer(0.5), "timeout")
			_esprite.set_flip_h(true)
		else:
		#yield(get_tree().create_timer(0.5), "timeout")
			_esprite.set_flip_h(false)

#----------------------------------------------- CHECK IF FALLEN
	
func check_falling():
	if state == FALLING:
		_esprite.play("Fall")
		if _esprite.frame == 0:
			self.queue_free()		
