extends "res://EntityBase.gd"


#the sprite itself
onready var drone = $Drone

onready var _animated_sprite = $AnimatedSprite2

onready var _my_particles = $Particles2D2
onready var hitBox = $Hitbox/CollisionShape2D

onready var blinkTween = $BlinkTween
onready var comboTween = $ComboTween
onready var specialsTween = $SpecialsTween

onready var attackCooldown_timer = $attackCooldown_timer

onready var linkLine = $linkLine
onready var FXSprite = $FXSprite
#onready var _footsteps = $Footsteps

export (String) var lastDirection = "down";

export (bool) var isGhosting = false
export (bool) var isGhosting2 = false
export (bool) var isDashing = false
export (bool) var dashCooldown = false

export (bool) var isAttacking = false

export (bool) var isCurrentlyDamaged = false

export (bool) var attackCooldown = false
export (bool) var isSpecial = false

export (int) var specialCharge = 0

#what stage of the combo you're on
var comboCounter = 0
#knockBack strength of each hit
export (int) var knockPower = 1

#last direction user was facing
var lastx = 0
var lasty = 0

var endpoint = Vector2()
#closest enemy co-ords
var c_enemy_vector = Vector2()
var nearest_enemy = null

var comboCount = [0,0]

export (int) var concentration = 0

#special attacks is active or not (0 is sword, 1 is sythe, 2 is gunblade
var specialAttacks = [[false,false,false],[false,false,false],[false,false,false]]

var primary = ["Sword","Gunblade","Scythe"]
var primaryNum
export (String) var weapon

var primaryGun = ["pistol","shotgun","burst"]
var primaryGunAmmo = [1,2,2]
var primaryNumGun
export (String) var weaponGun
var reloadTimes = [0.45,1.5,1]
export (float) var ammo = 0
var hasAmmo = true
#for gunblade trigger attack
var gunbladeCharge = 0

#gun variables
export (PackedScene) var Bullet
signal player_shot(bullet, position, direction, type)

#interaction states
enum {
	MOVE,
	ATTACK,
	DASH,
	PARRY,
	SPECIAL,
	DAMAGED,
	SHOOTING,
	COOLDOWN

}

var state = MOVE

#----------------------------------------------------------------- READY
func _ready():
	FXSprite.play("Blank")
	primaryNum = 0
	primaryNumGun = 0
	weaponGun = primaryGun[0]
	weapon = "Sword"
	ammo = 6

	
func _process(_delta):		
#was an enemy hit/damaged
	$testIndicator.text = str(ammo)

	checkIfHit(get_parent().get_node("EnemyHolder"))
	
	_blink()
	#_dash()
	if state != DAMAGED:
		is_getting_Damaged()
	
#	if lastDirection == "left":
	#	drone.global_position = Vector2(self.global_position.x + 150, self.global_position.y - 120)
	#elif lastDirection == "right":
	#	drone.global_position = Vector2(self.global_position.x - 150, self.global_position.y - 120)
		if Input.is_action_pressed("ui_up"):
			lastDirection = "up"
		
		elif Input.is_action_pressed("ui_left"):
			lastDirection = "left"
			
		elif Input.is_action_pressed("ui_right"):
			lastDirection = "right"
					
		elif Input.is_action_pressed("ui_down"):
			lastDirection = "down"		
	
		canMovement(_delta)

#-------------------------------------------------------------------- ATTACK ANIMATIONS AND CONDITIONS
func attack_state():		
	#if (Input.is_action_just_pressed("spacebar") and isDashing == false and !isCurrentlyDamaged): #and !attackCooldown:
		isAttacking = true
		stopMoving()
		hitBox.disabled = false
		
		
		if concentration >= 15:
			$concentrationParticles.emitting = true
			isGhosting = true
		else:
			$concentrationParticles.emitting = false
			isGhosting = false

#-------------------up
		if lastDirection == "up" and Input.is_action_just_pressed("spacebar"):
			$concentrationParticles.set_rotation_degrees(180)
			if Input.is_action_pressed("press_f") and weapon == "Sword":
				baseThrust(0, -390,"Thrust3Back", "Thrust3_combo3Back", "Thrust3_combo3Back")
			
			else:
				#_animated_sprite.play("Slash3Back")
				_animated_sprite.set_flip_h(false)
				if weapon == "Gunblade":
					baseCombo(0, -25, "A1_Slash3Back", "A1_Slash3Back_combo1.1", "A1_Slash3Back" , "A1_Slash3Back_combo1.2",17,17)
				else:
					baseCombo(0, -25, "Slash3Back", "Slash3Back_combo1", "Slash3Back" , "Slash3Back_combo1",9,9)
#------------------- right			
		elif lastDirection == "right" and Input.is_action_just_pressed("spacebar"):
			$concentrationParticles.set_rotation_degrees(-90)
			if Input.is_action_pressed("press_f") and weapon == "Sword":
				_animated_sprite.set_flip_h(false)
				baseThrust(390, 0, "Thrust3Side", "Thrust3_combo3Side", "Thrust3_combo3Side")
			
			else:
				#_animated_sprite.play("Slash3Side")
				_animated_sprite.set_flip_h(false)
				if weapon == "Gunblade":
					baseCombo(30, 0, "A1_Slash3Side", "A1_Slash3Side_combo1.1", "A1_Slash3Side", "A1_Slash3Side_combo1.2",17,17)
				else:
					baseCombo(30, 0, "Slash3Side", "Slash3Side_combo1", "Slash3Side" , "Slash3Side_combo1",9,9)
#------------------- left			
		elif lastDirection == "left" and Input.is_action_just_pressed("spacebar"):
			$concentrationParticles.set_rotation_degrees(90)
			if Input.is_action_pressed("press_f") and weapon == "Sword":
				_animated_sprite.set_flip_h(true)
				baseThrust(-390, 0, "Thrust3Side", "Thrust3_combo3Side", "Thrust3_combo3Side")
			
			else:
				#_animated_sprite.play("Slash3Side")
				_animated_sprite.set_flip_h(true)
				if weapon == "Gunblade":
					baseCombo(-30, 0, "A1_Slash3Side", "A1_Slash3Side_combo1.1", "A1_Slash3Side", "A1_Slash3Side_combo1.2",17,17)
				else:
					baseCombo(-30, 0, "Slash3Side", "Slash3Side_combo1", "Slash3Side" , "Slash3Side_combo1",9,9)
#------------------- down (else)			
		elif lastDirection == "down" and Input.is_action_just_pressed("spacebar"):
			$concentrationParticles.set_rotation_degrees(0)
			if Input.is_action_pressed("press_f") and weapon == "Sword":
				baseThrust(0, 390, "Thrust3", "Thrust3_combo3", "Thrust3_combo3")
			

			elif Input.is_action_just_pressed("spacebar"):
				#_animated_sprite.play("Slash3")
				_animated_sprite.set_flip_h(false)
				if weapon == "Gunblade":
					baseCombo(0, 25, "A1_Slash3", "A1_Slash3_combo1.1", "A1_Slash3", "A1_Slash3_combo1.2",17,17)
				else:
					baseCombo(0, 25, "Slash3", "Slash3_combo1", "Slash3" , "Slash3_combo1",9,9)

#------ (gunblade Charge attack)
		if Input.is_action_pressed("press_f") and weapon == "Gunblade" and Input.is_action_pressed("spacebar") and lastDirection == "down" :
				gunbladeCharge("A1_AltCombo1_Charge")
		if (Input.is_action_just_released("spacebar") || Input.is_action_just_released("press_f")) and gunbladeCharge > 0 and weapon == "Gunblade" and lastDirection == "down":		
			gunbladeRelease(0,80,"A1_AltCombo1","A1_AltCombo1.1", "A1_AltCombo1.2")
			
		if Input.is_action_pressed("press_f") and weapon == "Gunblade" and Input.is_action_pressed("spacebar") and lastDirection == "up" :
				gunbladeCharge("A1_AltCombo1_ChargeBack")
		if (Input.is_action_just_released("spacebar") || Input.is_action_just_released("press_f")) and gunbladeCharge > 0 and weapon == "Gunblade" and lastDirection == "up":		
			gunbladeRelease(0,-90,"A1_AltCombo1Back","A1_AltCombo1.1Back", "A1_AltCombo1.2Back")

		if Input.is_action_pressed("press_f") and weapon == "Gunblade" and Input.is_action_pressed("spacebar") and lastDirection == "right" :
				_animated_sprite.set_flip_h(false)
				gunbladeCharge("A1_AltCombo1_ChargeSide")
		if (Input.is_action_just_released("spacebar") || Input.is_action_just_released("press_f")) and gunbladeCharge > 0 and weapon == "Gunblade" and lastDirection == "right":		
			_animated_sprite.set_flip_h(false)
			gunbladeRelease(85,0,"A1_AltCombo1Side","A1_AltCombo1.1Side", "A1_AltCombo1.2Side")
						
		if Input.is_action_pressed("press_f") and weapon == "Gunblade" and Input.is_action_pressed("spacebar") and lastDirection == "left" :
				_animated_sprite.set_flip_h(true)
				gunbladeCharge("A1_AltCombo1_ChargeSide")		
		if (Input.is_action_just_released("spacebar") || Input.is_action_just_released("press_f")) and gunbladeCharge > 0 and weapon == "Gunblade" and lastDirection == "left":		
			_animated_sprite.set_flip_h(true)
			gunbladeRelease(-85,0,"A1_AltCombo1Side","A1_AltCombo1.1Side", "A1_AltCombo1.2Side")
			


#-------------------------- alt combos			
		if Input.is_action_pressed("spacebar") and comboCounter == 2 and lastDirection == "down" and _animated_sprite.frame < 13 and weapon == "Sword":
			_animated_sprite.set_flip_h(false)
			baseCombo(0, 35, "Slash3_combo2", "Slash3_combo2", "Slash3_combo2", "Slash3",9,9)
			
		if Input.is_action_pressed("spacebar") and comboCounter == 2 and lastDirection == "up" and _animated_sprite.frame < 13 and weapon == "Sword":
			_animated_sprite.set_flip_h(false)
			baseCombo(0, -35, "Slash3_combo2Back", "Slash3_combo2Back","Slash3_combo2Back","Slash3Back",9,9)

		if Input.is_action_pressed("spacebar") and comboCounter == 2 and lastDirection == "left" and _animated_sprite.frame < 13 and weapon == "Sword":
			_animated_sprite.set_flip_h(true)
			baseCombo(-40, 0, "Slash3_combo2Side", "Slash3_combo2Side", "Slash3_combo2Side", "Slash3Side",9,9)
					
		if Input.is_action_pressed("spacebar") and comboCounter == 2 and lastDirection == "right" and _animated_sprite.frame < 13 and weapon == "Sword":
			_animated_sprite.set_flip_h(false)
			baseCombo(40, 0, "Slash3_combo2Side", "Slash3_combo2Side", "Slash3_combo2Side", "Slash3Side",9,9)
	
#--------------------- checking for other things			
		if _animated_sprite.get_animation() == "Slash3_combo2" ||  _animated_sprite.get_animation() == "Slash3_combo2Side" || _animated_sprite.get_animation() == "Slash3_combo2Back":
			if lastDirection == "up":
				altCombo(0,-17,"Slash3_combo2Back", "Slash3_combo2Back")
			if lastDirection == "left":
				altCombo(-20,0, "Slash3_combo2Side", "Slash3_combo2Side")
			if lastDirection == "right":
				altCombo(20,0, "Slash3_combo2Side", "Slash3_combo2Side")
			if lastDirection == "down":
				altCombo(0,17, "Slash3_combo2", "Slash3_combo2")

func gunbladeCharge(startMove):
	#if Input.is_action_pressed("spacebar"):
		if gunbladeCharge == 0:
			$TriggerCharge_timer.start()
			_animated_sprite.play(startMove)
			gunbladeCharge = 1
			
		if gunbladeCharge == 1:
			_animated_sprite.set_frame(0)
		
		if gunbladeCharge == 2:
			if _animated_sprite.frame <= 1 || _animated_sprite.frame > 5:
				_animated_sprite.frame = 2
			
		if gunbladeCharge >= 3:
			if _animated_sprite.frame < 5 || _animated_sprite.frame > 9:
				_animated_sprite.frame = 6
				

func gunbladeRelease(x,y,startMove,followup1, followup2):
		if gunbladeCharge == 1:
			_animated_sprite.play(startMove)
			blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.08,Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, 0.1)
			blinkTween.start()
		if gunbladeCharge == 2:
			blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.06,Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, 0.1)
			blinkTween.start()
			comboTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.06,Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, 0.4)
			comboTween.start()
			
			_animated_sprite.play(followup1)
		if gunbladeCharge >= 3:
			blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.06,Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, 0.1)
			blinkTween.start()
			
			comboTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + (x*2), self.global_position.y + (y*2)), 0.06,Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, 0.4)
			comboTween.start()
			_animated_sprite.play(followup2)
		
		gunbladeCharge = -1
		comboCounter = 4
		$TriggerCharge_timer.stop()


func _on_TriggerCharge_timer_timeout():
	gunbladeCharge += 1

func altCombo(x,y, startMove, followup1):
	#if comboCounter == 2: #_animated_sprite.frame == 0:
		#_animated_sprite.play(startMove)
		if _animated_sprite.frame < 1:
			blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.08,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			blinkTween.start()
		
		comboCounter = 4

		$Hitbox.damage = 0.75
		if _animated_sprite.frame % 6 == 0 || _animated_sprite.frame > 33:
			hitBox.disabled = true
			#isGhosting = false
		
		if _animated_sprite.frame > 29:
			knockPower = 5
			#isGhosting = true
		elif _animated_sprite.frame <= 29:
			knockPower = 0


	
#takes in how far the attack will carry you, and the names of the follow up aniamtions in the combo
func baseCombo(x, y, startMove, followup1, followup2, followup3, followFrame1, followFrame2):
	comboCount[1] = 0
	$Hitbox.damage = 1
	isGhosting = false
	isGhosting2 = false
	
	blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + lastx * 20, self.global_position.y + lasty * 20), 0.04,Tween.TRANS_LINEAR, Tween.EASE_OUT)

	
	if comboCounter == 0: #_animated_sprite.frame == 0:
		_animated_sprite.play(startMove)
		#blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		#blinkTween.start()
		comboCounter = 1
		knockPower = 1
		blinkTween.start()
	
	if comboCounter < 2 and comboCounter > 0:
		
		if _animated_sprite.frame > followFrame1:
			_animated_sprite.play("Idle2")
			_animated_sprite.play(followup1)
			comboCounter += 1
			hitBox.disabled = true
			knockPower = 2
			blinkTween.start()
			
	if comboCounter < 3 and comboCounter > 1:

		if _animated_sprite.frame > followFrame2:
			#blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			#blinkTween.start()
			_animated_sprite.play("Idle2")
			_animated_sprite.play(followup2)
			comboCounter += 1
			hitBox.disabled = true
			knockPower = 2
			blinkTween.start()
			
	if comboCounter < 4 and comboCounter > 2:
		if _animated_sprite.frame > followFrame1:
			_animated_sprite.play("Idle2")
			_animated_sprite.play(followup3)
			comboCounter += 1
			hitBox.disabled = true
			knockPower = 3
			$Hitbox.damage = 2
			blinkTween.start()
	

	baseComboHitbox()

func baseThrust(x,y, startMove, followup1, followup2):
	comboCounter = 0
	$Hitbox.damage = 1
	if comboCount[1] < 1: #_animated_sprite.frame == 0:
		_animated_sprite.play(startMove)
		blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + x, self.global_position.y + y), 0.15,Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.12)
		#blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(c_enemy_vector), 0.2,Tween.TRANS_LINEAR, Tween.EASE_IN)
		blinkTween.start()
		comboCount[1] = 1
		knockPower = 3
		isGhosting2 = true
		
	if comboCount[1] < 2:
		if _animated_sprite.frame > 13:
			_animated_sprite.play("Idle2")
			_animated_sprite.play(followup1)
			comboCount[1] += 1
			hitBox.disabled = true
			knockPower = 0
			isGhosting2 = true
	if comboCount[1] < 6:
		if _animated_sprite.frame > 9: 
			_animated_sprite.play("Idle2")
			_animated_sprite.play(followup2)
			comboCount[1] += 1
			hitBox.disabled = true
			knockPower = 1
			isGhosting2 = true
		if comboCount[1] == 5:
			knockPower = 6
			
	baseComboHitbox()

func baseComboHitbox():
#Down, Up, Right, Left
#[name,x,y,radius,height,rotation,damage1,knockback1]	
	var swordBaseBox = [
["Slash3",26,79,180,206,90,1,1],
["Slash3_combo1",-20,86,180,206,90,1,1],
["Slash3Back",-20,-120,180,206,90,1,1],
["Slash3Back_combo1",26,-127,180,206,90,1,1],
["Slash3Side", 79,0,180,206,0,1,1],
["Slash3Side_combo1", 86,0,180,206,0,1,1],
["Slash3_combo2",0,130,163,104,0,0.75,1],
["Slash3_combo2Back",0,-130,163,104,0,0.75,1],
["Slash3_combo2Side",130,0,163,104,0,0.75,1],
["Thrust3",0,145,205,76,0,1,3],
["Thrust3Back",0,-145,205,76,0,1,3],
["Thrust3Side",145,0,205,76,90,1,3],
["Thrust3_combo3",0,145,175,76,0,1,3],
["Thrust3_combo3Back",0,-145,175,76,0,1,3],
["Thrust3_combo3Side",145,0,175,76,90,1,3]
]
	
	if weapon == "Sword":
		for i in swordBaseBox.size():
			if _animated_sprite.animation == swordBaseBox[i][0]:
				if _animated_sprite.flip_h == true:
					swordBaseBox[i][1] = -swordBaseBox[i][1]
				hitBox.position.x = swordBaseBox[i][1]
				hitBox.position.y = swordBaseBox[i][2]
				hitBox.shape.radius = swordBaseBox[i][3]
				hitBox.shape.height = swordBaseBox[i][4]
				hitBox.rotation_degrees = swordBaseBox[i][5]
				break


		
	elif weapon == "Gunblade":
		pass
	elif weapon == "Scythe":
		pass


func _on_attackCooldown_timer_timeout():
	attackCooldown = false
	
#-------------------------------------------------------------------- ATTACK STATE

func _on_AnimatedSprite2_frame_changed():
	pass 

func _on_AnimatedSprite2_animation_finished():
	
#---------------------------------------- Sword Basic Combo
	if(_animated_sprite.get_animation() == "Slash3Back"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Slash3Back_combo1"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Slash3_combo2Back"):
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(0.4)
		attackCooldown_timer.start()
		isAttacking = false
		
		
	if(_animated_sprite.get_animation() == "Slash3"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Slash3_combo1"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Slash3_combo2"):
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(0.4)
		attackCooldown_timer.start()
		isAttacking = false
	
		
	if(_animated_sprite.get_animation() == "Slash3Side"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Slash3Side_combo1"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Slash3_combo2Side"):
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(0.4)
		attackCooldown_timer.start()
		isAttacking = false
		
#--------------------------------------- Sword Trigger Attack

	if(_animated_sprite.get_animation() == "Thrust3"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(0.5)
		attackCooldown_timer.start()
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Thrust3Back"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(0.5)
		attackCooldown_timer.start()
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Thrust3Side"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(0.5)
		attackCooldown_timer.start()
		isAttacking = false
		
#------------------------------------- Sword Trigger Combo

	if(_animated_sprite.get_animation() == "Thrust3_combo3"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(1)
		attackCooldown_timer.start()
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Thrust3_combo3Back"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(1)
		attackCooldown_timer.start()
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Thrust3_combo3Side"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		attackCooldown = true
		attackCooldown_timer.set_wait_time(1)
		attackCooldown_timer.start()
		isAttacking = false


#------------------------------------- Sword Basic Combo pt 1
		
	if(_animated_sprite.get_animation() == "Thrust3_combo1"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "Thrust3_combo2"):
		comboCount[1] = 0
		_animated_sprite.play("Idle2")
		isAttacking = false

#------------------------------------ GUNBLADE
#---------------------------------------- gunblade basic Combo
	if(_animated_sprite.get_animation() == "A1_Slash3"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "A1_Slash3Side"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "A1_Slash3Back"):
		_animated_sprite.play("Idle2")
		isAttacking = false
	
	if(_animated_sprite.get_animation() == "A1_Slash3_combo1"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_Slash3_combo1.1"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_Slash3Back_combo1.1"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_Slash3Side_combo1.1"):
		_animated_sprite.play("Idle2")
		isAttacking = false	

	if(_animated_sprite.get_animation() == "A1_Slash3_combo1.2"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_Slash3Back_combo1.2"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_Slash3Side_combo1.2"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
#-------------------------------------------------------------- Gunblade trigger combo
	if(_animated_sprite.get_animation() == "A1_AltCombo1"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1.1"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1.2"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1Back"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1.1Back"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1.2Back"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1Side"):
		_animated_sprite.play("Idle2")
		isAttacking = false	
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1.1Side"):
		_animated_sprite.play("Idle2")
		isAttacking = false
		
	if(_animated_sprite.get_animation() == "A1_AltCombo1.2Side"):
		_animated_sprite.play("Idle2")
		isAttacking = false


	gunbladeCharge = 0
	comboCounter = 0
	comboCount[1] = 0	
	isGhosting = false
	isGhosting2 = false
	#isDashing = false
	if !isAttacking and state != DAMAGED and state != SHOOTING and state != COOLDOWN:
		state = MOVE

	
	hitBox.disabled = true

#------------------------------------------------------------------------------- GUNS
func shoot():

	if $gunCooldown_timer.get_time_left() == 0 and ammo - primaryGunAmmo[primaryNumGun] >= 0:
		var bullet_instance = Bullet.instance()
		var mouse_pos = get_global_mouse_position()
		var to_mouse = Vector2(lastx * 400, lasty * 400).normalized() #self.global_position.direction_to(mouse_pos).normalized()
		#print(to_mouse)
		emit_signal("player_shot", bullet_instance, self.global_position, to_mouse, weaponGun)
		
		$gunCooldown_timer.set_wait_time(reloadTimes[primaryNumGun])
		$gunCooldown_timer.start()
		if weaponGun == "shotgun":
			$pause_timer.set_wait_time(0.4)
			ammo = ammo - primaryGunAmmo[1]
		elif weaponGun == "burst":
			$pause_timer.set_wait_time(0.35)
			ammo = ammo - primaryGunAmmo[2]
		else:
			$pause_timer.set_wait_time(0.25)
			ammo = ammo - primaryGunAmmo[0]
		state = COOLDOWN
		
		gun_summon()
		
		hasAmmo = true
		
	elif ammo - primaryGunAmmo[primaryNumGun] < 0:
		hasAmmo = false
		$pause_timer.set_wait_time(0.25)
		state = COOLDOWN
		
	#print(hasAmmo)
		
func _on_gunCooldown_timer_timeout():
	$gunCooldown_timer.stop()

func shooting_state(delta):
	#canMovement(delta)
	verySlow()
	$Reticle.position = Vector2(lastx * 800, lasty * 800)
	$Reticle.visible = true
	
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
	
#------------------------------------------------------------------------------- IS ENEMY HIT
func checkIfHit(node):
	for N in node.get_children():
		#if N.get_child_count() > 0: if you want to find children of the listed nodes
		if N.get_child_count() < 0:
			print("["+N.get_name()+"]")
			getallnodes(N)
		
		if node.get_child_count() == 0:
			pass
		
		else:
			if N.isDamaged == true:
				specialCharge += 0.020
				concentration += 0.2
				#Engine.time_scale = 0.6
				#$enemyHitSlowdown_timer.start()
				if state == ATTACK:
					ammo += 0.1
					
					if concentration >= 15:
						$Hitbox.damage = $Hitbox.damage * 1.5
				
				#print("enemy hit ", concentration, " damage: ", $Hitbox.damage)
				

		if concentration > 20:
			concentration = 20

		if specialCharge > 5:
			specialCharge = 5
		if specialCharge < 0:
			specialCharge = 0 
			
		if ammo >= 6:
			ammo = 6
	#damage modifer from concentration


func _on_enemyHitSlowdown_timer_timeout():
	#Engine.time_scale = 1
	#$enemyHitSlowdown_timer.stop()
	pass

#------------------------------------------------------------------------------- INPUT EVENTS

func _input(event):
	#dialog trigger
	if Input.is_action_just_pressed("press_x"):
		find_and_use_dialogue()
	#trigger for specials
	if Input.is_action_just_pressed("press_r") and state == MOVE: #and specialCharge >= 0: #and !Input.is_action_pressed("press_f") and !dashCooldown and !isAttacking and !isDashing and !isDamaged: #and specialCharge >= 3:
		state = SPECIAL
		concentration -= 10

	#trigger for dashing
	if Input.is_action_just_pressed("press_v") and !Input.is_action_pressed("press_f") and state == MOVE: #and dashCooldown == false and isAttacking == false :
		state = DASH
		#_dash()

	if Input.is_action_just_pressed("spacebar") and (state == MOVE || dashCooldown == true): #and isDashing == false and !isCurrentlyDamaged and !isAttacking:
		state = ATTACK

	if Input.is_action_just_pressed("press_h") and state == MOVE:
		interact()
		
	if Input.is_action_just_pressed('right_click') and !Input.is_action_pressed('press_f') and (state == MOVE or state == SHOOTING): # and $shooting_cooldown.is_stopped():
		shoot()
		
	#weapon switching
	if Input.is_action_just_pressed('press_y') and (state == MOVE or state == SHOOTING or state == COOLDOWN or state == DASH or state == DAMAGED):
		weapon_switch()
		
	if Input.is_action_just_pressed('press_i') and (state == MOVE or state == SHOOTING or state == COOLDOWN or state == DASH or state == DAMAGED):
		gun_switch()

	#gun stance
	if Input.is_action_pressed("press_c") and state == MOVE:
		state = SHOOTING
	
	if state == SHOOTING and Input.is_action_just_released("press_c") and state !=COOLDOWN:
		state = MOVE
		$Reticle.visible = false


#------------------------------------------------------------------------------- COOLDOWN
func cooldown_state():
	stopMoving()
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
	
	if $pause_timer.get_time_left() == 0:
		$pause_timer.start()

func _on_pause_timer_timeout():
	if Input.is_action_pressed("press_c"):
		state = SHOOTING
	else:
		$Reticle.visible = false
		state = MOVE
	$pause_timer.stop()
		
#------------------------------------------------------------------------------- WEAPON SWITCHING
func weapon_switch():
	if primaryNum < 2:
		primaryNum += 1
	else:
		primaryNum = 0
		
	weapon = primary[primaryNum]
	#$SpecialsTween3.interpolate_property(_animated_sprite, "modulate", Color(0.98,0.3,1,1), Color(1,1,1,1), 0.4, Tween.TRANS_SINE, Tween.EASE_OUT)
	#$SpecialsTween3.start()
	
func gun_switch():
	if primaryNumGun < 2:
		primaryNumGun += 1
	else:
		primaryNumGun = 0
		
	weaponGun = primaryGun[primaryNumGun]

#------------------------------------------------------------------------------- DIALOGUE TRIGGER
			
func find_and_use_dialogue():
	var dialogue_player = get_node_or_null("DialoguePlayer")
	
	if dialogue_player:
		dialogue_player.play()



func interact():
	closest_npc(get_parent().get_node("NPCHolder")).player_interaction()

func player_interaction():
#this is so if the player tries to interact with no npc's around it doesn't crash
	pass

func closest_npc(node):
	var lowest = 500
	var N_Node = null
	for N in node.get_children():
		
		if node.get_child_count() == 0:
			N_Node = self
		else:
			if N.get_node("AnimatedSprite").get_global_position().distance_to(_animated_sprite.get_global_position()) < lowest:
				lowest = N.get_node("AnimatedSprite").get_global_position().distance_to(_animated_sprite.get_global_position())
				N_Node = N
	
	if N_Node == null:
		N_Node = self			
	return N_Node
				
#------------------------------------------------------------------------------- MOVEMENT

func _physics_process(_delta):
	match state:
		MOVE: 
			move_state(_delta)
		ATTACK:
			attack_state()

		DASH:
			if !isDashing and !dashCooldown:
				dash_state()

		SPECIAL:
			#canMovement(_delta)
			if !isSpecial:
				special_state()
				
		DAMAGED:
			damaged_state()
			
		SHOOTING:
			shooting_state(_delta)
			
		COOLDOWN:
			cooldown_state()

func stopMoving():
	speed = 0
	acceleration = 0
	velocity = Vector2.ZERO


func defaultSpeed():
	speed = 60000
	fric = 3000
	acceleration = 6000
	
func verySlow():
	speed = 1
	fric = 30000000
	acceleration = 1
	
#---------------------------------------------------------------------------- MOVE STATE
func canMovement(delta):
	#get_input()
	#velocity = move_and_slide(velocity)
	#_my_particles.set_rotation_degrees(rad2deg(velocity.angle())-180)
	var input_vector = Vector2()

	if state == MOVE || SHOOTING: #if isDashing == false and isAttacking == false:
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
		velocity += input_vector * acceleration * delta
		velocity = velocity.clamped(speed * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, fric * delta)
# warning-ignore:return_value_discarded
	
	
	move_and_collide(velocity * delta)
	

func move_state(delta):
	#canMovement(delta)
	$concentrationParticles.emitting = false
		
	if (Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_left")):# and !isDashing and !isAttacking and !isCurrentlyDamaged and !dashCooldown:
		
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
				
		defaultSpeed()
		#verySlow()
		#_footsteps.playing = true
		
	else: #elif isDashing == false and !isAttacking: 
		
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

#----------------------------------------------------------------------------- BLINK STATE
func _blink():
	if Input.is_action_pressed("press_f"):
		getallnodes(get_parent().get_node("EnemyHolder"))
		if c_enemy_vector.distance_to(self.global_position) > 200 and !isAttacking:
			linkLine.set_modulate(Color(0.05,0.67,0.8,1))
			linkLine.visible = true
			linkLine.set_points([Vector2(0,0), Vector2(c_enemy_vector.x - self.global_position.x,c_enemy_vector.y - self.global_position.y)])
			#blinkTween.targeting_method(linkLine, "set_points",linkLine,"set_points",[Vector2(0,0), Vector2(c_enemy_vector.x - self.global_position.x,c_enemy_vector.y - self.global_position.y) ], 0.1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			#linkLine.set_points([Vector2(c_enemy_vector.x - self.global_position.x - 50,c_enemy_vector.y - self.global_position.y - 50), Vector2(c_enemy_vector.x - self.global_position.x + 50,c_enemy_vector.y - self.global_position.y - 50), Vector2(c_enemy_vector.x - self.global_position.x,c_enemy_vector.y - self.global_position.y), Vector2(c_enemy_vector.x - self.global_position.x - 50,c_enemy_vector.y - self.global_position.y - 50)])
		#linkLine.global_position = self.global_position
		else:
			#linkLine.set_modulate(Color(0.05,0.67,0.8,0.3))
			linkLine.visible = false
	else:	
		linkLine.visible = false
	
	if Input.is_action_just_pressed("press_v") and Input.is_action_pressed("press_f") and state == MOVE: #and dashCooldown == false and isAttacking == false :	
		
		#if enemies exist
		if c_enemy_vector != self.global_position:
			_dash_animations()
			stopMoving()
			isDashing = true
			dashCooldown = true

			$Hurtbox/CollisionShape2D.disabled = true

			_my_particles.set_rotation_degrees(rad2deg(Vector2(lastx, lasty).angle())-180)
			_my_particles.set_emitting(true)
			_my_particles.set_use_local_coordinates(false)
		
			_animated_sprite.set_modulate(Color(1, 1, 1, 0))
		
		#right is x-300
			if(self.global_position.x > c_enemy_vector.x and self.global_position.y -180 < c_enemy_vector.y and self.global_position.y + 180 > c_enemy_vector.y):
				blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(c_enemy_vector.x + 170 ,c_enemy_vector.y), 0.13,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			#left	
			elif (self.global_position.x < c_enemy_vector.x and self.global_position.y -180 < c_enemy_vector.y and self.global_position.y + 180 > c_enemy_vector.y):
				blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(c_enemy_vector.x - 170 ,c_enemy_vector.y), 0.13,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			#bottom
			elif(self.global_position.y > c_enemy_vector.y ):
				blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(c_enemy_vector.x  ,c_enemy_vector.y + 230), 0.13,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			#top
			elif(self.global_position.y < c_enemy_vector.y):
				blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(c_enemy_vector.x  ,c_enemy_vector.y - 260), 0.13,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			
			blinkTween.start()
		
			$dash_timer.start()
		
		#if no enemies around just dash normally
		else:
			state = DASH
			#_dash()
	
	if Input.is_action_just_pressed("press_h") and Input.is_action_pressed("press_f") and state == MOVE:
		if c_enemy_vector != self.global_position:
			blinkTween.interpolate_property(nearest_enemy, "global_position",nearest_enemy.global_position, self.global_position, 0.12,Tween.TRANS_LINEAR, Tween.EASE_IN)

			nearest_enemy.state = nearest_enemy.DAMAGED
			linkLine.set_modulate(Color(0.81,0.12,1,1))
			$dash_timer.start()	
			blinkTween.start()
		
		
func getallnodes(node):
	#finds all the enemy nodes, calculates their distance from the player and gets the vector of the closest
	var lowest = 100000
	for N in node.get_children():
		#if N.get_child_count() > 0: if you want to find children of the listed nodes
		if N.get_child_count() < 0:
			print("["+N.get_name()+"]")
			getallnodes(N)
		
		if node.get_child_count() == 0:
			c_enemy_vector = self.position
			#print("there are no kids")
		
		else:
			if N.get_node("AnimatedSprite").get_global_position().distance_to(_animated_sprite.get_global_position()) < lowest and !N.isFalling:
				lowest = N.get_node("AnimatedSprite").get_global_position().distance_to(_animated_sprite.get_global_position())
				
				if(lowest < 1400):
					c_enemy_vector = N.get_node("AnimatedSprite").get_global_position()
					nearest_enemy = N
					
					pass
				elif lowest > 1400 || lowest <= 0:
					c_enemy_vector = self.global_position
					#nearest_enemy = null
					pass
					

			#if isFacing(N.global_position):
				#c_enemy_vector = N.get_node("AnimatedSprite").get_global_position()	
		#print("- "+N.get_name() , "- " , c_enemy_vector)

	if node.get_child_count() == 0:
			c_enemy_vector = self.global_position
			#print("there are no kids")

	#print("Closest: " , c_enemy_vector)

func isFacing(target):
	var a = Vector2(lastx,lasty).direction_to(target)
	#print(a.dot(target))
	if (a > Vector2(0,0)):
		#print(a)
		return true

	else:
		return false
	pass

func gun_summon():
	var this_gun = preload("res://Drone.tscn").instance()

	this_gun.global_position = Vector2(lastx * 200, lasty * 200)	
	this_gun.guntype = weaponGun
	this_gun.lastx = lastx
	this_gun.lasty = lasty
	#this_gun.flip_h = _animated_sprite.flip_h

	self.add_child(this_gun)

 

#---------------------------------------------------------------------- DASHING

func _on_ghost_timer_timeout():
	#copy of ghost object			
	if isDashing == true || isGhosting == true || isGhosting2 == true:
		var this_ghost = preload("res://ghost.tscn").instance()
		var time_left = $dash_timer.get_time_left()
		
		#this_ghost.lastx = lastx
		#this_ghost.lasty = lasty
		this_ghost.global_position = global_position
		this_ghost.position = position
		#this_ghost.endpoint = endpoint
		#this_ghost.time_left = time_left
		

		if Input.is_action_pressed("press_f"):
			this_ghost.movetype = "blink"
		else:
			this_ghost.movetype = "dash"
		#give parent

		if concentration >= 15 and state == ATTACK:
			this_ghost.movetype = "concentration"
			this_ghost.position = position 
	
		if isGhosting2 == true:
			this_ghost.movetype = "blink"
		
		get_parent().add_child(this_ghost)
		
		#this_ghost.position = position
		#--
			
		this_ghost.texture = _animated_sprite.frames.get_frame(_animated_sprite.animation, _animated_sprite.frame)
		this_ghost.flip_h = _animated_sprite.flip_h


func _dash_animations():		
	if(lastDirection == "left"):
		_animated_sprite.play("DashSide")
		_animated_sprite.set_flip_h(true)
			
	elif(lastDirection == "right"):
		_animated_sprite.play("DashSide")
		_animated_sprite.set_flip_h(false)
			
	elif(lastDirection == "down"):
		_animated_sprite.play("Dash")
		_animated_sprite.set_frame(2)
			
	elif(lastDirection == "up"):
		_animated_sprite.play("BackRun2")
		_animated_sprite.set_frame(2)

	#_animated_sprite.playing = false

func dash_state():
	#if !isDashing:
	_dash()
	#print("hi")

func _dash():
	
	_dash_animations()
	$Hurtbox/CollisionShape2D.disabled = true
	isDashing = true
	#speed = 50000000
	#fric = 800000
	#acceleration = 20000
	#_my_particles.set_rotation_degrees(rad2deg(Vector2(lastx, lasty).angle())-180)
	#_my_particles.set_emitting(true)
	#_my_particles.set_use_local_coordinates(false)
	blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + lastx * 500, self.global_position.y + lasty * 500), 0.1,Tween.TRANS_LINEAR, Tween.EASE_IN)
	blinkTween.start()
	endpoint = Vector2(self.global_position.x + lastx * 500, self.global_position.y + lasty * 500)
	
	dashCooldown = true
	$dash_timer.start()	
	
func _on_dash_timer_timeout():
	
	isDashing = false
	dashCooldown = true
	_my_particles.set_emitting(false)
	#_my_particles.set_use_local_coordinates(true)
	_my_particles.set_global_position(_animated_sprite.get_global_position())
	_my_particles.position.y += 100
	stopMoving()
	$dash_timer.stop()

	
	
	$dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout():
	#isDashing = false
	dashCooldown = false
	$dash_cooldown_timer.stop()
	$Hurtbox/CollisionShape2D.disabled = false
	_animated_sprite.set_modulate(Color(1, 1, 1, 1))
	#print("dashing done")
	if state != ATTACK:
		state = MOVE
	
#---------------------------------------------------------------------------- HURTBOXES
func damaged_state():
		_animated_sprite.set_modulate(Color(1, -1, 0, 1))
		#print("Dmg Start")
		isDamaged = false
		stopMoving()
		
		if concentration > 0:
			concentration = concentration - 0.2
		
		$hurtParticles.emitting = true
		_animated_sprite.play("Idle2")
		if $dmgReaction_timer.get_time_left() == 0:
			$dmgReaction_timer.start()
		#_animated_sprite.material.set_shader_param("solid_color", Color.red)
		
		#staggering the player during hurt animation
		#if(lastDirection == "up"):
		#	velocity = velocity.move_toward(Vector2(_animated_sprite.position.x, _animated_sprite.position.y+300), 10000000)
		#elif(lastDirection == "right"):
		#	velocity = velocity.move_toward(Vector2(_animated_sprite.position.x-300, _animated_sprite.position.y), 10000000)
	#	elif(lastDirection == "left"):
		#	velocity = velocity.move_toward(Vector2(_animated_sprite.position.x+300, _animated_sprite.position.y), 10000000)
	#	else:
	#		velocity = velocity.move_toward(Vector2(_animated_sprite.position.x, _animated_sprite.position.y-300), 10000000)	
		pass

func is_getting_Damaged():
	if isDamaged == true:
		state = DAMAGED
			
func _on_dmgReaction_timer_timeout():
	if hp <= 0:
		#self.queue_free()
		self.visible = false

	_animated_sprite.set_modulate(Color(1, 1, 1, 1))
	#print("Dmg Done")
	$hurtParticles.emitting = false
	defaultSpeed()
	state = MOVE
	$dmgReaction_timer.stop()
	
#------------------------------------------------------------------------------------------ SPECIALS
func special_state():

	
	if Input.is_action_just_pressed("press_r") and !Input.is_action_pressed("press_f"):# and !dashCooldown and !isAttacking and !isDashing and !isDamaged: #and specialCharge >= 3:
		swordSpecialStartup()
	
	if Input.is_action_just_pressed("press_r") and Input.is_action_pressed("press_f"):# and !dashCooldown and !isAttacking and !isDashing and !isDamaged: #and specialCharge >= 3:
		swordSpecial2()	

func swordSpecial2():
	_animated_sprite.set_flip_h(false)
	specialAttacks[0][0] = true
	isSpecial = true
	
	_animated_sprite.play("S_Special1Charge")
	FXSprite.play("S_Special2FX")
	specialCharge -= 3
	cameraZoom(1.45,0.8)

	#isAttacking = true
	stopMoving()
	$SwordSpecialParticles.set_emitting(true)
	#$Hurtbox/CollisionShape2D.disabled = true
	$Hurtbox/CollisionShape2D.set_deferred("disabled",true)
	
	
	$swordSpecial_startup_timer.start()

func swordSpecialStartup():
	verySlow()
	specialAttacks[0][1] = true
	isSpecial = true
	specialCharge -= 3
	cameraZoom(1,1)
	screenModulate(Color(0.97,0.8,1,1),0.7)
	#worldModulate(Color(0.6,0.6,0.6,1),0.8)
	_animated_sprite.play("S_Special1Charge")
	
	if(lastx < 0):
		_animated_sprite.set_flip_h(true)
	else:
		_animated_sprite.set_flip_h(false)
	
	#isAttacking = true
	
	#print("test1")
	$WorldEnvironment.environment.set_glow_level(1, true)

	$SwordSpecialParticles.set_emitting(true)
	
	$swordSpecial_startup_timer.start()

func _on_swordSpecial_startup_timer_timeout():
	
	if specialAttacks[0][1] == true:
		#$WorldEnvironment.environment.set_glow_hdr_bleed_threshold(0.11)
		$SwordSpecialParticles.set_emitting(false)
	
		$Hurtbox/CollisionShape2D.disabled = true
		$swordSpecial_startup_timer.stop()
		#print("test2")
		_activate_special()
	
	elif specialAttacks[0][0] == true:
	
		$SwordSpecialParticles.set_emitting(false)
		$swordSpecial_startup_timer.stop()
		FXSprite.play("S_Special2FX2")
		cameraZoom(2,0.01)

		specialAttacks[0][0] = false
		hitBox.scale.x = 3
		hitBox.scale.y = 3
		hitBox.disabled = false
		knockPower = 4
		$Hitbox.damage = 10
		
		_animated_sprite.play("S_Special1Finish")
		$swordSpecial_timer.start()


func _activate_special():
	#specialsTween.interpolate_property(self.get_parent(), "modulate",self.get_parent().modulate, Color(0.6,0.6,0.6,1), 1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#specialsTween.start()
	
	
	
	_dash_animations()


	hitBox.disabled = false
	hitBox.scale.x = 4
	hitBox.scale.y = 2
	hitBox.position = Vector2(0,0) -  Vector2(lastx*600,lasty*600) 
	hitBox.rotation_degrees = rad2deg(Vector2(lastx, lasty).angle()) #rad2deg(velocity.angle())

	
	knockPower = 2
	
	$Particles2D3.set_emitting(true)
	$Particles2D3.rotation_degrees = rad2deg(Vector2(lastx, lasty).angle())#rad2deg(velocity.angle())
	
	$Particles2D3.position = Vector2(0,0) -  Vector2(lastx*2800,lasty*2800) 
	_my_particles.set_use_local_coordinates(false)

	#print(rad2deg(velocity.angle()))

	$swordSpecial_timer.start()
	$Hitbox.damage = 15

	blinkTween.interpolate_property(self, "global_position",self.global_position, Vector2(self.global_position.x + lastx * 1600, self.global_position.y + lasty * 1600), 0.065,Tween.TRANS_LINEAR, Tween.EASE_OUT)
	blinkTween.start()
	
	cameraZoom(2,0.01)
	
	screenModulate(Color(1,1,1,1),0.1)

	
	#worldModulate(Color(1,1,1,1),0.01)

func _on_swordSpecial_timer_timeout():
	hitBox.position = Vector2(0,0)
	hitBox.disabled = true
	hitBox.scale.x = 1
	hitBox.scale.y = 1



	$Particles2D3.set_emitting(false)
	specialAttacks[0][1] = false
	specialAttacks[0][0] = false
	$Hitbox.damage = 1
	#dashCooldown = true
	stopMoving()
	$WorldEnvironment.environment.set_glow_level(1, false)
	
	$swordSpecial_timer.stop()
	
	$swordSpecial_cooldown_timer.start()
	#_animated_sprite.play("Slash3Side")
	#_animated_sprite.set_frame(15)

	_animated_sprite.stop()
	_animated_sprite.play("Idle2")
	_animated_sprite.play("S_Special1Finish")


func _on_swordSpecial_cooldown_timer_timeout():
	
	#dashCooldown = false
	$swordSpecial_cooldown_timer.stop()
	$Hurtbox/CollisionShape2D.disabled = false
	#isAttacking = false
	isSpecial = false
	state = MOVE
	


	
#-------------------------------------------------------------------- UTILITY FUNCTIONS (camera, world modulate)

func cameraZoom(target,time):
	#how much in/out camera zooms, how long it should take
	$SpecialsTween.interpolate_property($Camera2D, "zoom", $Camera2D.zoom, Vector2(target,target), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$SpecialsTween.start()
	

func worldModulate(target, time):
	$SpecialsTween2.interpolate_property(get_parent(), "modulate", get_parent().modulate, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SpecialsTween2.start()

func screenModulate(target,time):
	$SpecialsTween3.interpolate_property($CanvasModulate, "color", $CanvasModulate.color, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$SpecialsTween3.start()









