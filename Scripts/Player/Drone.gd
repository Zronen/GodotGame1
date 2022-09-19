extends AnimatedSprite

var guntype = "pistol"
var lastx
var lasty

# Called when the node enters the scene tree for the first time.
func _ready():
	if guntype == "pistol":
		self.play("Pistol")
		$gunSmoke.lifetime = 0.3
	if guntype == "shotgun":
		self.play("Shotgun")
	if guntype == "burst":
		self.play("Laser")
	
		
	rotation_degrees = rad2deg(Vector2(lastx, lasty).angle()) 
	
	if rotation_degrees < 90 and rotation_degrees > -90:
		self.flip_v = false
		self.flip_h = false

	else:
		self.flip_v = true
		self.flip_h = false
	#self.position = Vector2(lastx * 300, lasty * 300)	
	print(rotation_degrees)



func _process(_delta):
	if guntype == "pistol" and self.frame == 4 and rotation_degrees < 90 and rotation_degrees > -90:
		rotation_degrees -= 4
	elif guntype == "pistol" and self.frame == 4:
		rotation_degrees += 4
		
	if self.frame == 7:
		$gunSmoke.emitting = false

func _on_Drone_animation_finished():
	$Gungone_timer.start()



func _on_Gungone_timer_timeout():
	queue_free()
