extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var movetype = "dash"
var lastx = 0
var lasty = 0
var endpoint
var time_left

#Vector2(self.global_position.x + lastx * 200, self.global_position.y + lasty * 200)
# Called when the node enters the scene tree for the first time.
func _ready():
	if movetype == "dash":
		$alpha_tween.interpolate_property(self, "modulate", Color(0.2,0.9,1,0.90), Color(0.7,0.1,1,0), 0.85, Tween.TRANS_SINE, Tween.EASE_OUT, 0.1)
		#$alpha_tween.playback_speed = 1.3
		#$move_tween.interpolate_property(self, "global_position",self.global_position,Vector2(self.global_position.x + lastx * 20, self.global_position.y + lasty * 20), 0.2,Tween.TRANS_LINEAR, Tween.EASE_IN)
		scale.x = 1
		scale.y = 1
	
	elif movetype == "blink":
		$alpha_tween.interpolate_property(self, "modulate", Color(0.97,0.5,1,0.90), Color(0.37,0.92,1,0), 0.85, Tween.TRANS_SINE, Tween.EASE_OUT, 0.1)
		#$alpha_tween.playback_speed = 1.3
		scale.x = 1
		scale.y = 1
	
	elif movetype == "concentration":
		self.modulate = Color(0.97,0.5,1,0.4)
		$alpha_tween.interpolate_property(self, "modulate", Color(0.97,0.5,1,0.4), Color(0.37,0.92,1,0), 0.20, Tween.TRANS_SINE, Tween.EASE_OUT, 0.05)
		scale.x = 1.03
		scale.y = 1.03
	
	$alpha_tween.start()
	$move_tween.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_alpha_tween_tween_completed(object, key):
	queue_free()
