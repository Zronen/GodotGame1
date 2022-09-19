extends KinematicBody2D

export(int) var hp_max: float  = 5
export(int) var hp: float = hp_max



#export(int) var SPEED: int = 75
var velocity: Vector2 = Vector2.ZERO

export (int) var acceleration = 6000
export (int) var fric = 3000
export (int) var speed = 30000

export (bool) var isDamaged = false

onready var anim_sprite = $AnimatedSprite
onready var collShape = $CollisionShape2D
onready var hurtBox = $Hurtbox


func _physics_process(_delta):
	move()
	pass

func move():
	velocity = move_and_slide(velocity)
	pass
	
func die():
	queue_free()
	pass

func receive_damage(base_damage: int):
	pass

func _on_Hurtbox_area_entered(hitbox):
	var base_damage = hitbox.damage
	hp -= base_damage
	#print(hitbox.get_parent().name + "touched ")
	isDamaged = true
