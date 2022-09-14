extends "res://EntityBase.gd"


onready var _esprite = $AnimatedSprite
onready var hitBox = $Hitbox/CollisionShape2D
onready var _hurtBox = $Hurtbox/CollisionShape2D
onready var moveTween = $moveTween
onready var FXSprite = $FXSprite
onready var FXSprite2 = $FXSprite2

onready var hpBar = $hpBar
onready var hpBar2 = $hpBarGrey

var isAttacking = false

export (bool) var isCurrentlyDamaged = false

export (bool) var isFalling = false

#variables for the knockback function
var plastx = 0
var plasty = 0
var pknockPower
var knockBackArr = [1, 15, 60, 140, 200, 300, 400]
var rng = RandomNumberGenerator.new()

enum {
	MOVE,
	ATTACK,
	DASH,
	FALLING,
	IDLE,
	DAMAGED
}

var player = null

var state

func _ready():
	state = MOVE
	FXSprite.play("blankAnim")

	hpBar.set_scale(Vector2((0.0050 * ((hp / hp_max))*10),0.006))
	hpBar2.set_scale(Vector2((0.0050 * ((hp / hp_max))*10),0.006))
	hpBar.visible = false
	hpBar2.visible = false
	player = get_parent().get_parent().get_node("PlayerBase")
	rng.randomize()

func _process(_delta):
	
	match state:
		MOVE:
			move_state(_delta)
		FALLING:
			falling_state()
		IDLE:
			idle_state()
		DAMAGED:
			damage_state()

	hpBarGo()
	is_getting_Damaged()
	$testIndicator.text = str(hp)

func idle_state():
	velocity = Vector2.ZERO

func move_state(_delta):
	if (Input.is_action_pressed("press_d") || Input.is_action_pressed("press_s") || Input.is_action_pressed("press_w") || Input.is_action_pressed("press_a")): #and !isAttacking and !isCurrentlyDamaged:
		#_esprite.play("Aggro")
		speed = 30000
		fric = 3000
		acceleration = 6000

		
	else:# !isAttacking and !isCurrentlyDamaged and !isFalling:
		#_esprite.play("Idle")
		hitBox.disabled = true
		
	hitBox.disabled = true
	var input_vector = Vector2()


	input_vector.x = Input.get_action_strength("press_d") - Input.get_action_strength("press_a")
	input_vector.y = Input.get_action_strength("press_s") - Input.get_action_strength("press_w")
	input_vector = input_vector.normalized()
		

	if input_vector != Vector2.ZERO:
		velocity += input_vector * acceleration * _delta
		velocity = velocity.clamped(speed * _delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, fric * _delta)

	move_and_collide(velocity * _delta)

#----------------------------------------------- GETTING DAMAGED
func damage_state():
	if isDamaged:
		
		isDamaged = false
		
		hitBox.disabled = true
		acceleration = 0
		speed = 0
		_esprite.set_modulate(Color(1, -1, -1, 1))
		isCurrentlyDamaged = true
		fxTrigger()
		

		$dmg_reaction_timer.wait_time = 1

		$hp_bar_timer.start()
		
		hpBar.visible = true
		hpBar2.visible = true

		#if (get_parent().get_parent().get_node("PlayerBase").comboCounter > 1):
		if hp > 0:
			knockback()

		
		if hp <= 0:
			#$dieParticles.emitting = true
			_hurtBox.disabled = true
			hitBox.disabled = true
			#get_parent().get_parent().get_node("PlayerBase").get_node("Camera2D").zoom = Vector2(0.8,0.8)
			
			if checkIflast(get_parent()):
				get_parent().get_parent().get_node("PlayerBase").get_node("Camera2D").current = false
				$ECamera.current = true
				$ECamera.zoom = Vector2(0.8,0.8)
				Engine.time_scale = 0.25
				$dmg_reaction_timer.wait_time = 0.35
	
		$dmg_reaction_timer.start()

func checkIflast(node):
	var enemyCounter = 0
	for N in node.get_children():
		if N.state == DAMAGED and N.hp <= 0:
			enemyCounter += 1
			
	#print(enemyCounter, " ", node.get_child_count())
	if enemyCounter == node.get_child_count():
		return true
	else:
		return false	

func is_getting_Damaged():
	if isDamaged == true || isCurrentlyDamaged:
		state = DAMAGED

		

func knockback():
	pknockPower = get_parent().get_parent().get_node("PlayerBase").knockPower
	plastx = get_parent().get_parent().get_node("PlayerBase").lastx
	plasty = get_parent().get_parent().get_node("PlayerBase").lasty
	moveTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + plastx * knockBackArr[pknockPower], self.global_position.y + plasty * knockBackArr[pknockPower]), 0.06,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	moveTween.start()

		
func fxTrigger():
	if get_parent().get_parent().get_node("PlayerBase").specialAttacks[0][1] == true:
		FXSprite.play("blankAnim")
		FXSprite.play("P_SlashSpecial#2")
		$dmg_reaction_timer.wait_time = 0.8
	
	else:
		$dmg_reaction_timer.wait_time = 0.35


func _on_dmg_reaction_timer_timeout():

	_esprite.set_modulate(Color(1, 1, 1, 1))
	isCurrentlyDamaged = false
	hitBox.disabled = false
	FXSprite.play("blankAnim")

	Engine.time_scale = 1
	


	$dmg_reaction_timer.stop()

	
	if hp <= 0:
		#$dieParticles.emitting = false
		#yield(get_tree().create_timer(1.0), "timeout")
		#get_parent().get_parent().get_node("PlayerBase").get_node("Camera2D").zoom = Vector2(1.3,1.3)
		get_parent().get_parent().get_node("PlayerBase").get_node("Camera2D").current = true
		$ECamera.current = false
		$ECamera.zoom = Vector2(1.6,1.6)
		
		state = FALLING
		
	else:
		state = MOVE

func falling_state():
	if hp <= 0:
		hitBox.disabled = true
		_hurtBox.disabled = true
		velocity = Vector2.ZERO

func hpBarGo():
	if hp >= 0:
		hpBar.set_scale(Vector2((0.0050 * ((hp / hp_max))*10),0.006))


func _on_hp_bar_timer_timeout():
	hpBar.visible = false
	hpBar2.visible = false


func _on_atk_cooldown_timer_timeout():
	if hp > 0:
		state = MOVE
