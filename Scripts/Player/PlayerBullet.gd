extends Node2D

export (int) var type = "pistol"
export (int) var speed = 40
var direction = Vector2.ZERO
onready var timer = $BulletTime
var velocity = 0
var rng = RandomNumberGenerator.new()
var ranNum
var ranNum2

#var bullet1 = preload("res://.import/bullets2.png-49e1be022b2a648cef9fed7402786f36.stex")
#var bullet2 = preload("res://.import/FXSlash1_02.png-9a210f368ec6236f42a3f81ae20ed2f2.stex")

func _ready():
	rng.randomize()
	ranNum = rng.randi_range(-2, 2)
	ranNum2 = rng.randi_range(0, 180)


func _physics_process(delta):
	if direction != Vector2.ZERO:

		if type == "shotgun":
			velocity = direction * ((speed * ($BulletTime.get_wait_time() * $BulletTime.get_time_left()) * 20) + ranNum - 5)
			get_parent().get_parent().get_node("PlayerBase").knockPower = 3
			$PlayerBullet.play("shotgun")
			$PlayerBullet.set_rotation_degrees(rad2deg(direction.angle())+ranNum2)
			$Hitbox.damage = 3
		
		if type == "pistol":
			$PlayerBullet.play("base")
			velocity = direction * speed * 1.5
			get_parent().get_parent().get_node("PlayerBase").knockPower = 1
			$Hitbox.damage = 4
		
		if type == "burst":
			$PlayerBullet.play("laser")
			velocity = direction * speed * 3
			
			$PlayerBullet.set_rotation_degrees(rad2deg(direction.angle())-90)
			$Hitbox.damage = 3
		
		
		global_position += velocity
		

func set_direction(direction):
	self.direction = direction
	
func set_timer(time):
	timer.start(time)

func _on_BulletTime_timeout():
	queue_free()

func _on_Hitbox_area_entered(area):
	if type == "pistol":
		queue_free()
	
	if type == "shotgun":
		type = "shotgun_blast"
		velocity = Vector2.ZERO
		$PlayerBullet.play("shotgun_hit")


func _on_PlayerBullet_animation_finished():
	if $PlayerBullet.get_animation() == "shotgun_hit":
		queue_free()
