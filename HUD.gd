extends CanvasLayer

onready var _healthbar = $hpBar
onready var _ammoBar = $AmmoBar
onready var _specialBar = $specialBar
onready var conBar = $concentrationBar

var c_enemy_vector = Vector2()
var playerPos = Vector2()

var health = 5
var i = 1.15
var hptrigger = true

var weapon
var weaponGun
export (int) var ammo
var isShooting

var concentration

var specialCharge

var HUDList = ["Hud1-0", "Hud2-1", "Hud3-2","Hud4-3","Hud5-4","Hud0-5"]

var ammoList = [["T1 1-0","T1 2-1","T1 3-2", "T1 4-3", "T1 5-4", "T1 6-5", "Ammo Full",],
["T2 2-0","T2 3-1","T2 4-2","T2 5-3","T2 6-4", "Ammo Full", "Ammo Full",],
["T3 3-0", "T3 4-1", "T3 5-2", "T3 6-3","Ammo Full","Ammo Full","Ammo Full"]
]
var hasAmmo
var gunHudActive = false
var shotFired

func _ready():
	#_healthbar.play("Hud_R")
	$die_popup.visible = false
	_specialBar.play("SpecialHud")
	_specialBar.set_frame(0)
	_healthbar.play("Hud0-5")
	_healthbar.set_frame(3)
	$specialbarParticles.emission_rect_extents.x = 0
	$weaponBar.play("SwordHud")
	$gunBar.play("PistolHud")
	$weaponBar.frame = 7
	#_ammoBar.play("Ammo Full")
	hasAmmo = false
	ammo = 6
	shotFired = false

func _process(delta):
#---------------------------------------------------------------------------------- Health
	if health >= 1:
		if ammo > get_parent().get_node("PlayerBase").get("ammo"):
			shotFired = true
		else:
			shotFired = false
		
		health = get_parent().get_node("PlayerBase").get("hp")
		weapon = get_parent().get_node("PlayerBase").get("weapon")
		weaponGun = get_parent().get_node("PlayerBase").get("weaponGun")
		ammo = get_parent().get_node("PlayerBase").get("ammo")
		concentration = get_parent().get_node("PlayerBase").get("concentration")
	
	elif hptrigger == true:
		#get_parent().set_modulate(Color(0, 0, 0, 1))
		$fadeout_timer.start()
		hptrigger = false

	
	if Input.is_action_just_pressed("press_c") and health >= 1:
		get_parent().get_node("PlayerBase").hp = 5
		
	if health < 0:
		get_parent().get_node("PlayerBase").hp = 5
			
	_healthbar.play(HUDList[health])

#---------------------------------------------------------------------------------- Specials
	if health >= 1:
		_specialBar.play("SpecialHud2")
		_specialBar.set_frame(floor(get_parent().get_node("PlayerBase").specialCharge))
		if(floor(get_parent().get_node("PlayerBase").specialCharge) <= 0):
			$specialbarParticles.set_emitting(false)
		else:
			$specialbarParticles.set_emitting(true)
			$specialbarParticles.emission_rect_extents.x = floor(get_parent().get_node("PlayerBase").specialCharge) * 11.25 
			$specialbarParticles.global_position.x = 36 + floor(get_parent().get_node("PlayerBase").specialCharge) * 20
			$specialbarParticles.color = Color(0.04,0.75,0.84,1)
	#_specialBar.set_frame(0)
	#print(floor(get_parent().get_node("PlayerBase").specialCharge))
			

#---------------------------------------------------------------------------------- Concentration Bar
	if health >= 1:
		if concentration <= 19:
			conBar.play("base")
			conBar.set_frame(concentration)
			$concentrationParticles.emitting = false
		elif concentration >= 20:
			conBar.play("max")	
			$concentrationParticles.emitting = true
	
#---------------------------------------------------------------------------------- WeaponsHud

	if health >= 1:
		if weapon == "Sword":
			$weaponBar.play("SwordHud")

		elif weapon == "Gunblade":
			$weaponBar.play("GunbladeHud")

		elif weapon == "Scythe":	
			$weaponBar.play("ScytheHud")
			
		if weaponGun == "pistol":
			$gunBar.play("PistolHud")

		elif weaponGun == "shotgun":
			$gunBar.play("ShotgunHud")

		elif weaponGun == "burst":	
			$gunBar.play("LaserHud")
			
		
		if $weaponBar.frame == 0:
			$visibleTween.stop_all()
			$visibleTween2.interpolate_property($weaponBar, "modulate", Color(0.9,0.9,0.9,1), Color(1,1,1,1), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
			$visibleTween2.start()

		if $gunBar.frame == 0:
			$visibleTween4.stop_all()
			$visibleTween3.interpolate_property($gunBar, "modulate", Color(0.9,0.9,0.9,1), Color(1,1,1,1), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
			$visibleTween3.start()
			
#---------------------------------------------------------------------------------- Ammo
	if health >= 1:
		if weaponGun == "pistol"  and shotFired == true: 
			_ammoBar.play(ammoList[0][ammo])
			gunHudActive = true
		elif weaponGun == "burst" and shotFired == true:  
			_ammoBar.play(ammoList[1][ammo])
			gunHudActive = true
		elif weaponGun == "shotgun" and shotFired == true: 
			_ammoBar.play(ammoList[2][ammo])
			gunHudActive = true
			
		#else:
		#if gunHudActive == false and hasAmmo == true:
			#hasAmmo = get_parent().get_node("PlayerBase").get("hasAmmo")
		
		if gunHudActive == false:	
			_ammoBar.play(ammoList[0][ammo])
			_ammoBar.set_frame(5)
		#_ammoBar.set_frame(0)

		if gunHudActive == false and ammo < 3:
			#hasAmmo = get_parent().get_node("PlayerBase").get("hasAmmo")
			if hasAmmo == false:
				#_ammoBar.play("Ammo Required")
				hasAmmo = true
				gunHudActive = true
	
		#print(gunHudActive)
	
func _on_AmmoBar_animation_finished():
		gunHudActive = false
		
		if _ammoBar.animation == "Ammo Required":
			hasAmmo = true

			
func _on_fadeout_timer_timeout():
	i = i - 0.05
	#print("get this work ", i)
	
	if i > 0 and i < 1:
		get_parent().set_modulate(Color(1, i-0.1, i-0.1, 1))
		$die_popup.visible = true
		$die_popup.set_modulate(Color(1,1, 1, 1 + -i))
		#print("timer breaking apart")
		$fadeout_timer.start()
	elif i > 1:
		$fadeout_timer.start()
	else:
		$fadeout_timer.stop()




func _input(event):
	pass


func _on_weaponBar_animation_finished():
	$weaponBar_timer.start()

func _on_gunBar_animation_finished():
		$gunBar_timer.start()

func _on_weaponBar_timer_timeout():
	$visibleTween.interpolate_property($weaponBar, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$visibleTween.start()
	
	$weaponBar_timer.stop()


func _on_gunBar_timer_timeout():
	$visibleTween4.interpolate_property($gunBar, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$visibleTween4.start()
	
	$gunBar_timer.stop()






