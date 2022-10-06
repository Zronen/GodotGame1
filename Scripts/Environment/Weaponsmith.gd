extends KinematicBody2D

onready var sprite = $AnimatedSprite

enum {
	IDLE,
	ACTIVE,
	SHOPPING,
}

var state
var player
var shopHUD

func _ready():
	state = IDLE
	#sprite.play("Idle")
	player = get_parent().get_parent().get_node("PlayerBase")
	shopHUD = get_parent().get_parent().get_node("ShopHUD")


func _process(_delta):
	
	match state:
		IDLE:
			#idle_state()
			pass
		ACTIVE:
			#active_state()
			pass
		SHOPPING:
			#shopping_state()
			pass
	
	check_player()
			
func idle_state():
	if sprite.get_frame() == 0:
		sprite.play("Idle")
	
func active_state():
	if sprite.get_frame() == 0:
		sprite.play("Ready")

func shopping_state():
	if sprite.get_frame() == 0:
		sprite.play("Forging")

func check_player():
	if self.global_position.distance_to(player.global_position) <= 500 and state != SHOPPING:
		state = ACTIVE	
	
	elif self.global_position.distance_to(player.global_position) > 500:
		if state == ACTIVE and sprite.frame >= 22 || state == SHOPPING:
			sprite.frame = 0
			state = IDLE
			shopHUD.get_node("ShopContainer").visible = false
		
func player_interaction():
	if state != SHOPPING:
		sprite.frame = 0	
	state = SHOPPING
	shopHUD.get_node("ShopContainer").visible = true
